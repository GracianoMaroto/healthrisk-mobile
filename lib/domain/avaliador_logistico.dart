import 'dart:math' as math;

import 'package:healthrisk_mobile/domain/avaliador_risco.dart';
import 'package:healthrisk_mobile/domain/respostas.dart';
import 'package:healthrisk_mobile/domain/resultado.dart';
import 'package:healthrisk_mobile/domain/tradutor_perguntas.dart';

/// Regressão logística on-device: imputação estratificada + scaler + sigmoid.
class AvaliadorLogistico implements AvaliadorRisco {
  AvaliadorLogistico(this.bundle, {TradutorPerguntas? tradutor})
      : tradutor = tradutor ?? TradutorPerguntas(bundle);

  factory AvaliadorLogistico.fromBundle(Map<String, dynamic> bundle) =>
      AvaliadorLogistico(bundle);

  final Map<String, dynamic> bundle;
  final TradutorPerguntas tradutor;

  static const _frasesAcionaveis = <String, String>{
    'idade_anos': 'Idade: a chance estimada sobe com os anos.',
    'razao_cintura_estatura': 'Cintura: medida alta em relação à altura aumenta a faixa.',
    'historico_familiar_diabetes': 'Histórico familiar: pai, mãe, irmão ou filho com diabetes.',
    'densidade_acucar': 'Bebida açucarada: consumo frequente na semana eleva o açúcar da dieta.',
    'densidade_fibra': 'Pouca hortaliça ou fruta: fibra baixa piora a qualidade da dieta.',
    'excesso_sodio': 'Embutido e salgadinho: sódio alto na semana.',
    'indice_qualidade_dieta': 'Qualidade da dieta: combinação de fibra, açúcar, sódio e gordura.',
    'refeicao_pronta': 'Comida pronta: fast-food ou refeição pronta em 3 dias ou mais.',
    'met_min_semana': 'Movimento: menos de 150 minutos de caminhada ou esforço na semana.',
    'cumpre_oms_150': 'Movimento: menos de 150 minutos de caminhada ou esforço na semana.',
    'minutos_sentado': 'Tempo sentado: 8 horas ou mais num dia típico.',
    'sedentarismo_alto': 'Tempo sentado: 8 horas ou mais num dia típico.',
    'imc': 'Peso e altura: IMC elevado entra no cálculo.',
    'pressao_alta': 'Pressão alta: 140/90 ou mais, conforme você informou.',
  };

  @override
  Resultado avaliar(Respostas respostas) {
    final features = (bundle['features'] as List).cast<String>();
    final vetor = tradutor.traduzir(respostas);
    final imputado = _imputar(vetor, features);
    final z = _padronizar(imputado, features);

    final coef = (bundle['classificador'] as Map)['coef'] as List;
    final intercept =
        ((bundle['classificador'] as Map)['intercept'] as num).toDouble();

    var logit = intercept;
    final contribuicoes = <String, double>{};
    for (var i = 0; i < features.length; i++) {
      final c = (coef[i] as num).toDouble() * z[i];
      logit += c;
      contribuicoes[features[i]] = c;
    }

    final p = _sigmoid(logit);
    final limiares = bundle['limiares'] as Map<String, dynamic>;
    final tercilInf =
        (limiares['tercil_inferior_baixo_moderado'] as num).toDouble();
    final tercilSup =
        (limiares['tercil_superior_moderado_alto'] as num).toDouble();

    return Resultado(
      faixa: _faixa(p, tercilInf, tercilSup),
      probabilidade: p,
      fatores: _fatores(contribuicoes, imputado, features),
    );
  }

  List<double> _imputar(Map<String, double?> vetor, List<String> features) {
    final imputer = bundle['imputer'] as Map<String, dynamic>;
    final medianasEstrato =
        imputer['medianas_estrato'] as Map<String, dynamic>;
    final medianasGlobais =
        imputer['medianas_globais'] as Map<String, dynamic>;

    final idade = vetor['idade_anos'] ?? 50.0;
    final sexoBruto = vetor['sexo'];
    final sexo = (sexoBruto == null || sexoBruto.isNaN) ? 1.0 : sexoBruto;
    final estrato = '${sexo.round()}_${_faixaEtaria(idade)}';

    return [
      for (final feature in features)
        vetor[feature] ??
            _mediana(medianasEstrato[feature], estrato) ??
            (medianasGlobais[feature] as num).toDouble(),
    ];
  }

  List<double> _padronizar(List<double> x, List<String> features) {
    final scaler = bundle['scaler'] as Map<String, dynamic>;
    final mean = scaler['mean'] as List;
    final scale = scaler['scale'] as List;
    return [
      for (var i = 0; i < features.length; i++)
        (x[i] - (mean[i] as num).toDouble()) / (scale[i] as num).toDouble(),
    ];
  }

  List<String> _fatores(
    Map<String, double> contribuicoes,
    List<double> imputado,
    List<String> features,
  ) {
    final ocultos = ((bundle['fatores_nao_exibidos'] as List?) ?? const [])
        .cast<String>()
        .toSet();
    final bruto = <String, double>{
      for (var i = 0; i < features.length; i++) features[i]: imputado[i],
    };
    final ranqueados = contribuicoes.entries
        .where((e) => !ocultos.contains(e.key) && e.value > 0)
        .where((e) => _frasesAcionaveis.containsKey(e.key))
        .where((e) => _falhaLimiarClinico(e.key, bruto[e.key] ?? 0))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final vistos = <String>{};
    final frases = <String>[];
    for (final entrada in ranqueados) {
      final frase = _frasesAcionaveis[entrada.key]!;
      if (vistos.add(frase)) {
        frases.add(frase);
      }
    }
    return frases;
  }

  /// Contribuição positiva vs a média do NHANES não basta: 600 MET-min ainda
  /// fica abaixo da média de treino (~3394) e listava "menos de 150 minutos"
  /// em quem já cumpre a OMS. Só aponta o fator se o valor cru falha o limiar.
  static bool _falhaLimiarClinico(String feature, double valor) {
    return switch (feature) {
      'idade_anos' => valor >= 45,
      'razao_cintura_estatura' => valor >= 0.50,
      'historico_familiar_diabetes' => valor >= 1,
      'densidade_acucar' => valor >= 50,
      'densidade_fibra' => valor < 10,
      'excesso_sodio' => valor >= 1,
      'indice_qualidade_dieta' => valor < 0,
      'refeicao_pronta' => valor >= 4,
      'met_min_semana' => valor < 600,
      'cumpre_oms_150' => valor < 1,
      'minutos_sentado' => valor >= 480,
      'sedentarismo_alto' => valor >= 1,
      'imc' => valor >= 25,
      'pressao_alta' => valor >= 1,
      'hdl' => valor < 40,
      'inseguranca_alimentar' => valor >= 1,
      _ => true,
    };
  }

  static String _faixaEtaria(double idade) {
    if (idade <= 29) return '18-29';
    if (idade <= 44) return '30-44';
    if (idade <= 59) return '45-59';
    return '60+';
  }

  static String _faixa(double p, double tercilInf, double tercilSup) {
    if (p <= tercilInf) return 'baixo';
    if (p <= tercilSup) return 'moderado';
    return 'alto';
  }

  static double? _mediana(Object? porEstrato, String estrato) {
    if (porEstrato is! Map) return null;
    final valor = porEstrato[estrato];
    if (valor is num) return valor.toDouble();
    return null;
  }

  static double _sigmoid(double x) {
    if (x >= 0) {
      final z = math.exp(-x);
      return 1.0 / (1.0 + z);
    }
    final z = math.exp(x);
    return z / (1.0 + z);
  }
}

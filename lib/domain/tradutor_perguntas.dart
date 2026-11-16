import 'package:healthrisk_mobile/domain/respostas.dart';

/// Converte o vocabulário da pessoa (frequência na semana) no vetor de 19 features.
class TradutorPerguntas {
  TradutorPerguntas(this.bundle);

  final Map<String, dynamic> bundle;

  Map<String, double?> traduzir(Respostas respostas) {
    final eq = bundle['tabela_equivalencia'] as Map<String, dynamic>;
    final dieta = bundle['parametros_dieta'] as Map<String, dynamic>;

    final kcal = _d(eq['kcal_referencia']);
    final fibra = respostas.hortalicaQuaseTodoDia
        ? _d(eq['fibra_hortalica_sim_g'])
        : _d(eq['fibra_hortalica_nao_g']);
    final acucar = respostas.bebidaAcucaradaFrequente
        ? _d(eq['acucar_bebida_frequente_g'])
        : _d(eq['acucar_bebida_rara_g']);
    final sodio = respostas.embutidoFrequente
        ? _d(eq['sodio_embutido_frequente_mg'])
        : _d(eq['sodio_embutido_raro_mg']);
    final ultraprocessado =
        respostas.comidaProntaFrequente || respostas.embutidoFrequente;
    final gsat = ultraprocessado
        ? _d(eq['gordura_sat_ultraprocessado_g'])
        : _d(eq['gordura_sat_protegido_g']);
    final refeicaoPronta = respostas.comidaProntaFrequente
        ? _d(eq['refeicoes_prontas_frequente'])
        : _d(eq['refeicoes_prontas_raro']);
    final met = respostas.cumpre150min
        ? _d(eq['met_cumpre_oms'])
        : _d(eq['met_nao_cumpre']);
    final sentado = respostas.sentado8hOuMais
        ? _d(eq['minutos_sentado_alto'])
        : _d(eq['minutos_sentado_baixo']);

    return {
      'idade_anos': respostas.idadeAnos.toDouble(),
      'sexo': respostas.sexo.toDouble(),
      'escolaridade_ord': respostas.escolaridadeOrd?.toDouble(),
      'razao_renda_pobreza': null,
      'inseguranca_alimentar': respostas.insegurancaAlimentar == null
          ? null
          : (respostas.insegurancaAlimentar! ? 1.0 : 0.0),
      'densidade_acucar': (acucar / kcal) * 1000.0,
      'densidade_fibra': (fibra / kcal) * 1000.0,
      'excesso_sodio': sodio >= 2300.0 ? 1.0 : 0.0,
      'indice_qualidade_dieta': _indiceDieta(fibra, acucar, sodio, gsat, dieta),
      'refeicao_pronta': refeicaoPronta,
      'met_min_semana': met,
      'cumpre_oms_150': met >= 600.0 ? 1.0 : 0.0,
      'minutos_sentado': sentado,
      'sedentarismo_alto': sentado >= 480.0 ? 1.0 : 0.0,
      'imc': respostas.imc,
      'razao_cintura_estatura': respostas.razaoCinturaEstatura,
      'pressao_alta': respostas.pressaoAlta ? 1.0 : 0.0,
      'hdl': respostas.hdl,
      'historico_familiar_diabetes':
          respostas.familiarPrimeiroGrau ? 1.0 : 0.0,
    };
  }

  double _indiceDieta(
    double fibra,
    double acucar,
    double sodio,
    double gsat,
    Map<String, dynamic> dieta,
  ) {
    double z(String col, double valor) {
      final params = dieta[col] as Map<String, dynamic>;
      return (valor - _d(params['media_treino'])) / _d(params['std_treino']);
    }

    return (z('fibra_g_dia', fibra) -
            z('acucar_g_dia', acucar) -
            z('sodio_mg_dia', sodio) -
            z('gordura_sat_g_dia', gsat)) /
        4.0;
  }

  static double _d(Object? valor) => (valor as num).toDouble();
}

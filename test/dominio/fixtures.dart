import 'dart:convert';
import 'dart:io';

import 'package:healthrisk_mobile/domain/respostas.dart';

final Map<String, dynamic> bundleLr = jsonDecode(
  File('assets/models/mobile_lr_bundle.json').readAsStringSync(),
) as Map<String, dynamic>;

Map<String, dynamic> golden(String id) {
  final lista = (bundleLr['goldens'] as List).cast<Map<String, dynamic>>();
  return lista.firstWhere((item) => item['id'] == id);
}

Respostas respostasDeJson(Map<String, dynamic> json) {
  return Respostas(
    idadeAnos: (json['idade_anos'] as num).toInt(),
    sexo: (json['sexo'] as num).toInt(),
    pesoKg: (json['peso_kg'] as num).toDouble(),
    alturaCm: (json['altura_cm'] as num).toDouble(),
    cinturaCm: (json['cintura_cm'] as num).toDouble(),
    familiarPrimeiroGrau: json['familiar_primeiro_grau'] == true,
    pressaoAlta: json['pressao_alta'] == true,
    diagnosticoInformado: json['diagnostico_informado'] == true,
    cumpre150min: json['cumpre_150_min'] == true,
    sentado8hOuMais: json['sentado_8h_ou_mais'] == true,
    hortalicaQuaseTodoDia: json['hortalica_quase_todo_dia'] == true,
    comidaProntaFrequente: json['comida_pronta_frequente'] == true,
    bebidaAcucaradaFrequente: json['bebida_acucarada_frequente'] == true,
    embutidoFrequente: json['embutido_frequente'] == true,
    escolaridadeOrd: json['escolaridade_ord'] == null
        ? null
        : (json['escolaridade_ord'] as num).toInt(),
    hdl: json['hdl'] == null ? null : (json['hdl'] as num).toDouble(),
    insegurancaAlimentar: json['inseguranca_alimentar'] == null
        ? null
        : (json['inseguranca_alimentar'] as num) >= 1,
  );
}

Respostas respostasGolden(String id) =>
    respostasDeJson(golden(id)['respostas_tela'] as Map<String, dynamic>);

/// Exemplo da seção 3.5: 58 anos, IMC 32, RCE 0,58 → soma 18.
Respostas respostasChecklist18() {
  const altura = 170.0;
  return const Respostas(
    idadeAnos: 58,
    sexo: 1,
    pesoKg: 92.48, // IMC = 32,0
    alturaCm: altura,
    cinturaCm: 98.6, // RCE = 0,58
    familiarPrimeiroGrau: true,
    pressaoAlta: true,
    diagnosticoInformado: false,
    cumpre150min: false,
    sentado8hOuMais: true, // ~540 min ≥ 480
    hortalicaQuaseTodoDia: false,
    comidaProntaFrequente: true,
    bebidaAcucaradaFrequente: false,
    embutidoFrequente: false,
  );
}

/// Caso protetor da seção 3.5: soma 0.
Respostas respostasChecklist0() {
  return const Respostas(
    idadeAnos: 29,
    sexo: 2,
    pesoKg: 61.0,
    alturaCm: 165.0,
    cinturaCm: 74.0,
    familiarPrimeiroGrau: false,
    pressaoAlta: false,
    diagnosticoInformado: false,
    cumpre150min: true,
    sentado8hOuMais: false,
    hortalicaQuaseTodoDia: true,
    comidaProntaFrequente: false,
    bebidaAcucaradaFrequente: false,
    embutidoFrequente: false,
    escolaridadeOrd: 5,
    hdl: 62.0,
    insegurancaAlimentar: false,
  );
}

/// Objeto de exame **fora** de [Respostas]. Existe só para o teste de vazamento.
class ExameAoLado {
  const ExameAoLado({required this.glicemia, required this.hba1c});

  final double glicemia;
  final double hba1c;
}

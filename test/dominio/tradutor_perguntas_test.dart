import 'package:flutter_test/flutter_test.dart';
import 'package:healthrisk_mobile/domain/tradutor_perguntas.dart';

import 'fixtures.dart';

void main() {
  final tradutor = TradutorPerguntas(bundleLr);
  const tolerancia = 1e-4;

  for (final id in ['alto', 'moderado', 'baixo']) {
    test('mesmas respostas de tela → mesmo vetor de 19 ($id)', () {
      final esperado = Map<String, dynamic>.from(golden(id)['vetor_19'] as Map);
      final obtido = tradutor.traduzir(respostasGolden(id));

      expect(obtido.keys.toSet(), esperado.keys.toSet());
      for (final feature in esperado.keys) {
        final valorEsperado = esperado[feature];
        final valorObtido = obtido[feature];
        if (valorEsperado == null) {
          expect(valorObtido, isNull, reason: feature);
        } else {
          expect(valorObtido, isNotNull, reason: feature);
          expect(
            valorObtido!,
            closeTo((valorEsperado as num).toDouble(), tolerancia),
            reason: feature,
          );
        }
      }
    });
  }

  test('hortaliça sim → ~28 g de fibra; refrigerante frequente → ~145 g de açúcar; kcal ~2000', () {
    final eq = bundleLr['tabela_equivalencia'] as Map<String, dynamic>;
    expect(eq['kcal_referencia'], 2000.0);
    expect(eq['fibra_hortalica_sim_g'], 28.0);
    expect(eq['acucar_bebida_frequente_g'], 145.0);

    final vetorAlto = tradutor.traduzir(respostasGolden('alto'));
    // 145 g / 2000 kcal * 1000 = 72,5 g/1000 kcal
    expect(vetorAlto['densidade_acucar'], closeTo(72.5, tolerancia));
    // 10 g (sem hortaliça) / 2000 * 1000 = 5,0
    expect(vetorAlto['densidade_fibra'], closeTo(5.0, tolerancia));

    final vetorBaixo = tradutor.traduzir(respostasGolden('baixo'));
    // 28 g / 2000 * 1000 = 14,0
    expect(vetorBaixo['densidade_fibra'], closeTo(14.0, tolerancia));
  });

  test('renda não perguntada → NaN/null para o imputador', () {
    for (final id in ['alto', 'moderado', 'baixo']) {
      final vetor = tradutor.traduzir(respostasGolden(id));
      expect(vetor['razao_renda_pobreza'], isNull, reason: id);
    }
  });

  test('não sei em escolaridade, HDL e insegurança deixa nulo para imputar', () {
    final respostas = respostasGolden('alto').copyWith(
      limparEscolaridade: true,
      limparHdl: true,
      limparInseguranca: true,
    );
    final vetor = tradutor.traduzir(respostas);
    expect(vetor['escolaridade_ord'], isNull);
    expect(vetor['hdl'], isNull);
    expect(vetor['inseguranca_alimentar'], isNull);
    expect(vetor['razao_renda_pobreza'], isNull);
  });
}

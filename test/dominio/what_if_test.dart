import 'package:flutter_test/flutter_test.dart';
import 'package:healthrisk_mobile/domain/avaliador_logistico.dart';
import 'package:healthrisk_mobile/domain/simulador_what_if.dart';

import 'fixtures.dart';

void main() {
  final avaliador = AvaliadorLogistico.fromBundle(bundleLr);

  test('150 min + menor cintura reduz p no perfil alto, sem ler exame', () {
    final alto = respostasGolden('alto');
    final intervencao = alto.copyWith(
      cumpre150min: true,
      cinturaCm: alto.cinturaCm - 6,
    );

    final pAntes = avaliador.avaliar(alto).probabilidade!;
    final pDepois = avaliador.avaliar(intervencao).probabilidade!;

    expect(pAntes, greaterThan(0.5));
    expect(pDepois, lessThan(pAntes));
    expect(alto.toMap().containsKey('glicemia'), isFalse);
    expect(intervencao.toMap().containsKey('hba1c'), isFalse);
  });

  test('cada hábito protetor das 6 perguntas reduz p', () {
    final ruim = respostasGolden('alto');
    final pRuim = avaliador.avaliar(ruim).probabilidade!;

    final variantes = [
      ruim.copyWith(cumpre150min: true),
      ruim.copyWith(sentado8hOuMais: false),
      ruim.copyWith(hortalicaQuaseTodoDia: true),
      ruim.copyWith(comidaProntaFrequente: false),
      ruim.copyWith(bebidaAcucaradaFrequente: false),
      ruim.copyWith(embutidoFrequente: false),
    ];

    for (final alt in variantes) {
      expect(avaliador.avaliar(alt).probabilidade!, lessThan(pRuim));
    }
  });

  test('What-If completo no perfil alto reduz p', () {
    final alto = respostasGolden('alto');
    final pAntes = avaliador.avaliar(alto).probabilidade!;
    final pDepois = avaliador.avaliar(SimuladorWhatIf.aplicar(alto)).probabilidade!;
    expect(pDepois, lessThan(pAntes));
  });

  test('What-If em perfil baixo não aumenta p nem infla a cintura', () {
    final baixo = respostasGolden('baixo');
    final intervencao = SimuladorWhatIf.aplicar(baixo);
    expect(intervencao.cinturaCm, lessThanOrEqualTo(baixo.cinturaCm));
    final pAntes = avaliador.avaliar(baixo).probabilidade!;
    final pDepois = avaliador.avaliar(intervencao).probabilidade!;
    expect(pDepois, lessThanOrEqualTo(pAntes));
  });

  test('cumprir 150 min não lista "menos de 150 minutos"', () {
    final comExercicio = respostasGolden('alto').copyWith(cumpre150min: true);
    final fatores = avaliador.avaliar(comExercicio).fatores.join(' | ').toLowerCase();
    expect(fatores, isNot(contains('menos de 150')));
  });
}

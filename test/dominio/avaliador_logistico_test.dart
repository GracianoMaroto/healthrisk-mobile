import 'package:flutter_test/flutter_test.dart';
import 'package:healthrisk_mobile/domain/avaliador_logistico.dart';

import 'fixtures.dart';

void main() {
  final avaliador = AvaliadorLogistico.fromBundle(bundleLr);
  const tolerancia = 1e-4;

  for (final id in ['alto', 'moderado', 'baixo']) {
    test('golden $id: p e faixa pelos tercis', () {
      final esperado = golden(id);
      final resultado = avaliador.avaliar(respostasGolden(id));
      expect(resultado.probabilidade, isNotNull);
      expect(
        resultado.probabilidade!,
        closeTo((esperado['p'] as num).toDouble(), tolerancia),
      );
      expect(resultado.faixa, esperado['faixa']);
    });
  }

  test('sexo, escolaridade e renda não entram na frase de fatores', () {
    final fatores = avaliador.avaliar(respostasGolden('alto')).fatores.join(' | ').toLowerCase();
    expect(fatores, isNot(contains('sexo')));
    expect(fatores, isNot(contains('escolaridade')));
    expect(fatores, isNot(contains('renda')));
  });

  test('fatores começam com maiúscula e trazem observação', () {
    final fatores = avaliador.avaliar(respostasGolden('alto')).fatores;
    expect(fatores, isNotEmpty);
    for (final f in fatores) {
      expect(f.substring(0, 1), matches(RegExp(r'[A-ZÁÉÍÓÚÂÊÔÃÕ]')));
      expect(f, contains(':'));
    }
  });

  test('avaliar duas vezes com as mesmas respostas devolve a mesma probabilidade', () {
    final r = respostasGolden('alto');
    final a = avaliador.avaliar(r).probabilidade!;
    final b = avaliador.avaliar(r).probabilidade!;
    expect(b, closeTo(a, 1e-12));
  });

  test('cumprir hortaliça e 150 min não lista fibra baixa nem falta de movimento', () {
    final protetor = respostasGolden('alto').copyWith(
      hortalicaQuaseTodoDia: true,
      cumpre150min: true,
      sentado8hOuMais: false,
    );
    final fatores = avaliador.avaliar(protetor).fatores.join(' | ').toLowerCase();
    expect(fatores, isNot(contains('pouca hortaliça')));
    expect(fatores, isNot(contains('menos de 150')));
    expect(fatores, isNot(contains('8 horas ou mais')));
  });

  test('diagnóstico informado não altera a probabilidade', () {
    final base = respostasGolden('alto');
    final comDiagnostico = base.copyWith(diagnosticoInformado: true);
    final pBase = avaliador.avaliar(base).probabilidade!;
    final pDiag = avaliador.avaliar(comDiagnostico).probabilidade!;
    expect(pDiag, closeTo(pBase, 1e-12));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:healthrisk_mobile/domain/avaliador_checklist.dart';

import 'fixtures.dart';

void main() {
  final avaliador = AvaliadorChecklist();

  test('exemplo da seção 3.5 soma 18 e faixa alto', () {
    final r = respostasChecklist18();
    expect(r.imc, closeTo(32.0, 1e-9));
    expect(r.razaoCinturaEstatura, closeTo(0.58, 1e-9));

    final resultado = avaliador.avaliar(r);
    expect(resultado.pontos, 18);
    expect(resultado.faixa, 'alto');
  });

  test('caso protetor soma 0 e faixa baixo', () {
    final resultado = avaliador.avaliar(respostasChecklist0());
    expect(resultado.pontos, 0);
    expect(resultado.faixa, 'baixo');
  });
}

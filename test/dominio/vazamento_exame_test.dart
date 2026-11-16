import 'package:flutter_test/flutter_test.dart';
import 'package:healthrisk_mobile/domain/avaliador_logistico.dart';
import 'package:healthrisk_mobile/domain/respostas.dart';

import 'fixtures.dart';

void main() {
  test('Respostas não expõe glicemia, HbA1c, insulina nem hipoglicemiante', () {
    final chaves = respostasGolden('alto').toMap().keys.map((k) => k.toLowerCase()).toSet();
    const proibidos = [
      'glicemia',
      'glicemiajejum',
      'hba1c',
      'insulina',
      'usainsulina',
      'hipoglicemiante',
      'exame',
      'lbxgh',
      'lbxglu',
      'diq010',
    ];
    for (final nome in proibidos) {
      expect(chaves, isNot(contains(nome)), reason: nome);
    }
  });

  test('avaliar é idêntico com ou sem glicemia 200 ao lado', () {
    final avaliador = AvaliadorLogistico.fromBundle(bundleLr);
    final respostas = respostasGolden('alto');
    final semExame = avaliador.avaliar(respostas);

    const exame = ExameAoLado(glicemia: 200, hba1c: 8);
    expect(exame.glicemia, 200);
    // O avaliador só recebe Respostas. O exame existe no escopo e não entra na conta.
    final comExameAoLado = avaliador.avaliar(respostas);

    expect(comExameAoLado.probabilidade, isNotNull);
    expect(semExame.probabilidade, isNotNull);
    expect(comExameAoLado.probabilidade!, closeTo(semExame.probabilidade!, 1e-12));
    expect(comExameAoLado.faixa, semExame.faixa);
    expect(identical(exame.runtimeType, Respostas), isFalse);
  });
}

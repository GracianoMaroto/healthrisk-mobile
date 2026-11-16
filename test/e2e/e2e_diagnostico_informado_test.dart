import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthrisk_mobile/app/copy.dart';
import 'package:healthrisk_mobile/data/modelos.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('home prioriza rotina e frase não vende chance de ter diabetes', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await h.deps.repos.medicamento.salvar(const Medicamento(
      nome: 'Metformina',
      dose: '500 mg',
      horarios: ['08:00'],
      diasSemana: [1, 2, 3, 4, 5, 6, 7],
    ));
    await pumpApp(tester, h);
    await fluxoAlto(tester, diagnostico: true);
    expect(find.text(Copy.fraseRisco), findsNothing);
    expect(find.text(Copy.fraseCuidado), findsOneWidget);
    await tocar(tester, const Key('btn_inicio'));
    final rotina = tester.getTopLeft(find.byKey(const Key('bloco_rotina')));
    final faixa = tester.getTopLeft(find.byKey(const Key('bloco_faixa')));
    expect(rotina.dy, lessThan(faixa.dy));
    expect(find.textContaining('Metformina'), findsOneWidget);
    expect(find.text(Copy.tomei), findsOneWidget);
  });
}

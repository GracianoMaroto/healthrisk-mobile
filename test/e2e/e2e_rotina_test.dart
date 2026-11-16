import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthrisk_mobile/app/copy.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('medicamento, tomei e consulta futura com 24h/2h', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await fluxoAlto(tester);
    await tocar(tester, const Key('btn_inicio'));

    await tocar(tester, const Key('btn_nav_medicamentos'));
    await escrever(tester, const Key('campo_med_nome'), 'Metformina');
    await escrever(tester, const Key('campo_med_dose'), '500 mg');
    await tocar(tester, const Key('btn_salvar_med'));
    await tocar(tester, const Key('btn_voltar'));
    expect(find.textContaining('Metformina'), findsOneWidget);
    await tester.tap(find.text(Copy.tomei));
    await aguardar(tester);
    expect(find.text('Ok'), findsOneWidget);

    await tocar(tester, const Key('btn_nav_consultas'));
    await escrever(tester, const Key('campo_consulta_quando'), '16/11/2026 14:00');
    await escrever(tester, const Key('campo_consulta_profissional'), 'Dra. Ana');
    await tocar(tester, const Key('btn_salvar_consulta'));
    final consultas = h.agenda.registrados.where((a) => a.canal == 'consultas').toList();
    expect(consultas.length, 2);
    expect(consultas.any((a) => a.texto.contains('24 horas')), isTrue);
    expect(consultas.any((a) => a.texto.contains('2 horas')), isTrue);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('glicemia 200 / HbA1c 8 não mudam a probabilidade', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await fluxoAlto(tester);
    final p1 = (find.byKey(const Key('txt_probabilidade')).evaluate().single.widget as Text).data;
    await tocar(tester, const Key('btn_inicio'));
    await tocar(tester, const Key('btn_nav_exames'));
    await tocar(tester, const Key('btn_tipo_glicemia'));
    await escrever(tester, const Key('campo_exame_valor'), '200');
    await escrever(tester, const Key('campo_exame_data'), '15/11/2026');
    await tocar(tester, const Key('btn_salvar_exame'));
    await tocar(tester, const Key('btn_tipo_hba1c'));
    await escrever(tester, const Key('campo_exame_valor'), '8');
    await tocar(tester, const Key('btn_salvar_exame'));
    await tocar(tester, const Key('btn_voltar'));
    await tocar(tester, const Key('btn_nav_questionario'));
    await responderQuiz(tester, const [false, true, true, true, false, true]);
    final p2 = (find.byKey(const Key('txt_probabilidade')).evaluate().single.widget as Text).data;
    expect(p2, p1);
  });
}

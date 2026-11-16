import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthrisk_mobile/app/copy.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('apagar tudo zera perfil, questionário e remédio', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await fluxoAlto(tester);
    await tocar(tester, const Key('btn_inicio'));
    await tocar(tester, const Key('btn_nav_medicamentos'));
    await escrever(tester, const Key('campo_med_nome'), 'Metformina');
    await tocar(tester, const Key('btn_salvar_med'));
    await tocar(tester, const Key('btn_voltar'));
    await tocar(tester, const Key('btn_nav_ajustes'));
    await tocar(tester, const Key('btn_apagar_tudo'));
    await tocar(tester, const Key('btn_confirmar_apagar'));
    expect(find.textContaining('somente neste celular'), findsOneWidget);
    expect(await h.deps.repos.perfil.obter(), isNull);
    expect(await h.deps.repos.questionario.listar(), isEmpty);
    expect(await h.deps.repos.medicamento.listar(), isEmpty);
    expect(h.agenda.cancelarTodosChamadas, greaterThan(0));
    expect(find.text(Copy.termoTitulo), findsOneWidget);
  });
}

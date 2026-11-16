import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthrisk_mobile/app/copy.dart';
import 'package:healthrisk_mobile/data/modelos.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('termo só segue se aceitar', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    expect(find.textContaining('somente neste celular'), findsOneWidget);
    await tocar(tester, const Key('btn_nao_aceitar'));
    expect(find.byKey(const Key('campo_nascimento')), findsNothing);
    await aceitarTermo(tester);
    expect(find.byKey(const Key('campo_nascimento')), findsOneWidget);
  });

  testWidgets('questionário um passo por vez', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await aceitarTermo(tester);
    await preencherPerfil(
      tester,
      nascimento: '15/01/1968',
      masculino: true,
      peso: '96',
      altura: '170',
      cintura: '112',
      familiar: true,
      pressao: true,
      diagnostico: false,
    );
    expect(find.text(Copy.qHortalica), findsOneWidget);
    expect(find.text(Copy.q150), findsNothing);
    await tocar(tester, const Key('btn_nao'));
    expect(find.text(Copy.qComidaPronta), findsOneWidget);
    expect(find.text(Copy.qHortalica), findsNothing);
  });

  testWidgets('resultado mostra faixa Alto e não é diagnóstico', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await fluxoAlto(tester);
    expect(find.byKey(const Key('txt_faixa')), findsOneWidget);
    expect(find.text(Copy.faixaAlto), findsWidgets);
    expect(find.byKey(const Key('txt_disclaimer')), findsOneWidget);
    expect(find.textContaining('não é diagnóstico'), findsWidgets);
  });

  testWidgets('diagnóstico informado troca a frase e não apaga remédio', (tester) async {
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
    expect(find.textContaining('Metformina'), findsOneWidget);
  });

  testWidgets('hipótese de mudança de hábito não usa o nome What-If', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await fluxoAlto(tester);
    await tocar(tester, const Key('btn_whatif'));
    expect(find.byKey(const Key('txt_whatif')), findsOneWidget);
    expect(find.text(Copy.hipoteseHabito), findsOneWidget);
    expect(find.textContaining('What-If'), findsNothing);
    expect(find.textContaining('What If'), findsNothing);
  });

  testWidgets('home lista doses do dia', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await fluxoAlto(tester);
    await tocar(tester, const Key('btn_inicio'));
    await tocar(tester, const Key('btn_nav_medicamentos'));
    await escrever(tester, const Key('campo_med_nome'), 'Losartana');
    await escrever(tester, const Key('campo_med_dose'), '50 mg');
    await tocar(tester, const Key('btn_salvar_med'));
    await tocar(tester, const Key('btn_voltar'));
    expect(find.textContaining('Losartana'), findsOneWidget);
    expect(find.text(Copy.tomei), findsOneWidget);
  });
}

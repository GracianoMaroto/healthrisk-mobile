import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthrisk_mobile/app/copy.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('questionário não mostra texto técnico e progresso é 6', (tester) async {
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
    expect(find.byKey(const Key('txt_q_base')), findsNothing);
    expect(find.textContaining('NHANES'), findsNothing);
    expect(find.textContaining('não é um chute'), findsNothing);
    expect(find.text('Pergunta 1 de 6'), findsOneWidget);
    expect(find.textContaining('de 11'), findsNothing);
    expect(find.textContaining('de 12'), findsNothing);
    await tocar(tester, const Key('btn_nao'));
    expect(find.text('Pergunta 2 de 6'), findsOneWidget);
    expect(find.text(Copy.qComidaPronta), findsOneWidget);
  });

  testWidgets('refazer são 6 hábitos, perfil entra no cálculo e p não muda', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await fluxoAlto(tester);
    final p1 = h.sessao.ultimoResultado!.probabilidade;
    expect(p1, isNotNull);
    await tocar(tester, const Key('btn_inicio'));
    await tocar(tester, const Key('btn_nav_questionario'));
    expect(find.text('Pergunta 1 de 6'), findsOneWidget);
    expect(find.text(Copy.qHortalica), findsOneWidget);
    await responderQuiz(tester, const [false, true, true, true, false, true]);
    expect(find.byKey(const Key('txt_faixa')), findsOneWidget);
    final p2 = h.sessao.ultimoResultado!.probabilidade;
    expect(p2, closeTo(p1!, 1e-12));

    final avaliacoes = await h.deps.repos.questionario.listar();
    expect(avaliacoes.length, 2);
    final mapa = jsonDecode(avaliacoes.first.respostasJson) as Map<String, dynamic>;
    expect(mapa['cinturaCm'], 112);
    expect(mapa['hdl'], 38);
    expect(mapa['escolaridadeOrd'], 2);
    expect(mapa['hortalicaQuaseTodoDia'], isFalse);
    expect(mapa['comidaProntaFrequente'], isTrue);
    expect(mapa['cumpre150min'], isFalse);
    expect(mapa['sentado8hOuMais'], isTrue);
  });
}

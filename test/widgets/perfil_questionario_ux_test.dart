import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthrisk_mobile/app/copy.dart';
import 'package:healthrisk_mobile/ui/mascaras.dart';
import 'package:healthrisk_mobile/ui/widgets.dart';

import '../helpers/harness.dart';

void main() {
  test('máscara de data formata oito dígitos', () {
    const mascara = MascaraData();
    final saida = mascara.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '15011968'),
    );
    expect(saida.text, '15/01/1968');
  });

  test('perguntas de dieta citam a última semana e sentado é neutro', () {
    expect(Copy.qHortalica, contains('Na última semana'));
    expect(Copy.qComidaPronta, contains('Na última semana'));
    expect(Copy.qBebida, contains('Na última semana'));
    expect(Copy.qEmbutido, contains('Na última semana'));
    expect(Copy.qSentado, contains('sentado(a)'));
  });

  testWidgets('nascimento aplica máscara dd/mm/aaaa', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await aceitarTermo(tester);
    await escrever(tester, const Key('campo_nascimento'), '15011968');
    final campo = tester.widget<CampoGrande>(find.byKey(const Key('campo_nascimento')));
    expect(campo.controller.text, '15/01/1968');
  });

  testWidgets('peso mostra asterisco e HDL mostra opcional', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await aceitarTermo(tester);
    await escrever(tester, const Key('campo_nascimento'), '15/01/1968');
    await tocar(tester, const Key('btn_continuar'));
    await tocar(tester, const Key('btn_sexo_m'));
    expect(find.text(Copy.obrigatorio), findsNothing);
    final peso = tester.widget<TextField>(
      find.descendant(of: find.byKey(const Key('campo_peso')), matching: find.byType(TextField)),
    );
    expect(peso.decoration?.label, isA<Text>());
    await escrever(tester, const Key('campo_peso'), '96');
    await tocar(tester, const Key('btn_continuar'));
    await escrever(tester, const Key('campo_altura'), '170');
    await tocar(tester, const Key('btn_continuar'));
    await escrever(tester, const Key('campo_cintura'), '112');
    await tocar(tester, const Key('btn_continuar'));
    await tocar(tester, const Key('btn_sim'));
    await tocar(tester, const Key('btn_sim'));
    await tocar(tester, const Key('btn_nao'));
    await tocar(tester, const Key('btn_pular'));
    expect(find.text(Copy.opcional), findsWidgets);
    expect(find.byKey(const Key('campo_hdl')), findsOneWidget);
  });

  testWidgets('escolaridade mostra níveis com texto, não 1 a 5', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await aceitarTermo(tester);
    await escrever(tester, const Key('campo_nascimento'), '15/01/1968');
    await tocar(tester, const Key('btn_continuar'));
    await tocar(tester, const Key('btn_sexo_m'));
    await escrever(tester, const Key('campo_peso'), '96');
    await tocar(tester, const Key('btn_continuar'));
    await escrever(tester, const Key('campo_altura'), '170');
    await tocar(tester, const Key('btn_continuar'));
    await escrever(tester, const Key('campo_cintura'), '112');
    await tocar(tester, const Key('btn_continuar'));
    await tocar(tester, const Key('btn_sim'));
    await tocar(tester, const Key('btn_sim'));
    await tocar(tester, const Key('btn_nao'));
    expect(find.text(Copy.escMedio), findsOneWidget);
    expect(find.textContaining('1–5'), findsNothing);
    expect(find.textContaining('1-5'), findsNothing);
    expect(find.byKey(const Key('campo_escolaridade')), findsNothing);
    expect(find.byKey(const Key('btn_esc_3')), findsOneWidget);
  });

  testWidgets('questionário volta e permite mudar a resposta', (tester) async {
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
    await tocar(tester, const Key('btn_nao'));
    expect(find.text(Copy.qComidaPronta), findsOneWidget);
    await tocar(tester, const Key('btn_voltar_passo'));
    expect(find.text(Copy.qHortalica), findsOneWidget);
    await tocar(tester, const Key('btn_sim'));
    expect(find.text(Copy.qComidaPronta), findsOneWidget);
    await tocar(tester, const Key('btn_voltar_passo'));
    expect(find.text(Copy.qHortalica), findsOneWidget);
    expect(
      find.descendant(of: find.byKey(const Key('btn_sim')), matching: find.byType(FilledButton)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byKey(const Key('btn_nao')), matching: find.byType(OutlinedButton)),
      findsOneWidget,
    );
  });
}

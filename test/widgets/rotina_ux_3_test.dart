import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthrisk_mobile/app/copy.dart';
import 'package:healthrisk_mobile/app/sessao.dart';
import 'package:healthrisk_mobile/data/agenda.dart';
import 'package:healthrisk_mobile/data/modelos.dart';
import 'package:healthrisk_mobile/data/repositorios_memoria.dart';
import '../helpers/harness.dart';

class _AgendaQuebra extends AgendaMemoria {
  @override
  Future<void> agendar({
    required int id,
    required DateTime quando,
    required String canal,
    required String texto,
  }) async {
    throw Exception('alarme');
  }
}

void main() {
  testWidgets('app não mostra faixa DEBUG', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.debugShowCheckedModeBanner, isFalse);
  });

  testWidgets('PIN mostra benefício, status ativo e campo vazio depois de salvar', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await fluxoAlto(tester);
    await tocar(tester, const Key('btn_inicio'));
    await tocar(tester, const Key('btn_nav_ajustes'));
    expect(find.text(Copy.pinBeneficio), findsOneWidget);
    expect(find.textContaining('SQLite'), findsNothing);
    await escrever(tester, const Key('campo_pin'), '1234');
    await tocar(tester, const Key('btn_salvar_pin'));
    expect(await h.deps.cofre.temPin(), isTrue);
    expect(find.byKey(const Key('txt_pin_status')), findsOneWidget);
    expect(find.text(Copy.pinAtivo), findsOneWidget);
    expect(find.text(Copy.pinSalvo), findsOneWidget);
    final campo = tester.widget<TextField>(
      find.descendant(of: find.byKey(const Key('campo_pin')), matching: find.byType(TextField)),
    );
    expect(campo.controller?.text, isEmpty);
  });

  testWidgets('desbloqueio não mostra obrigatório acima do PIN', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await h.deps.cofre.salvar('1234');
    await h.sessao.iniciar();
    await pumpApp(tester, h);
    expect(h.sessao.tela, TelaApp.pin);
    expect(find.text(Copy.obrigatorio), findsNothing);
    expect(find.byKey(const Key('txt_indicador_campo')), findsNothing);
  });

  testWidgets('consulta passada vai ao histórico e pode ser marcada realizada', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await fluxoAlto(tester);
    await tocar(tester, const Key('btn_inicio'));
    await tocar(tester, const Key('btn_nav_consultas'));
    await escrever(tester, const Key('campo_consulta_quando'), '10/11/2026 09:00');
    await escrever(tester, const Key('campo_consulta_profissional'), 'Dr. Paulo');
    await escrever(tester, const Key('campo_consulta_especialidade'), 'Cardiologia');
    await escrever(tester, const Key('campo_consulta_local'), 'UBS Centro');
    await tocar(tester, const Key('btn_salvar_consulta'));
    final id = (await h.deps.repos.consulta.listar()).single.id!;
    expect(find.byKey(Key('btn_consulta_realizada_$id')), findsNothing);
    expect(find.byKey(const Key('campo_busca_consulta')), findsNothing);
    await tocar(tester, const Key('btn_historico_consulta'));
    expect(find.byKey(const Key('campo_busca_consulta')), findsOneWidget);
    expect(find.byKey(Key('btn_consulta_realizada_$id')), findsOneWidget);
    expect(find.textContaining('Dr. Paulo'), findsWidgets);
    await escrever(tester, const Key('campo_busca_consulta'), 'Cardiologia');
    expect(find.textContaining('Dr. Paulo'), findsWidgets);
    await escrever(tester, const Key('campo_busca_consulta'), 'xyz');
    expect(find.textContaining('Dr. Paulo'), findsNothing);
    await escrever(tester, const Key('campo_busca_consulta'), '');
    await tocar(tester, Key('btn_consulta_realizada_$id'));
    expect((await h.deps.repos.consulta.listar()).single.situacao, 'realizada');
    expect(find.textContaining('realizada'), findsWidgets);
    await tocar(tester, Key('btn_excluir_consulta_$id'));
    expect(await h.deps.repos.consulta.listar(), isEmpty);
  });

  testWidgets('exame recente fica na tela e o histórico filtra pelo tipo', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await fluxoAlto(tester);
    await tocar(tester, const Key('btn_inicio'));
    await tocar(tester, const Key('btn_nav_exames'));
    await escrever(tester, const Key('campo_exame_valor'), '98');
    await escrever(tester, const Key('campo_exame_data'), '10/11/2026');
    await tocar(tester, const Key('btn_salvar_exame'));
    await escrever(tester, const Key('campo_exame_valor'), '110');
    await escrever(tester, const Key('campo_exame_data'), '15/11/2026');
    await tocar(tester, const Key('btn_salvar_exame'));
    await tocar(tester, const Key('btn_tipo_hba1c'));
    await escrever(tester, const Key('campo_exame_valor'), '5,6');
    await escrever(tester, const Key('campo_exame_data'), '12/11/2026');
    await tocar(tester, const Key('btn_salvar_exame'));
    expect(find.textContaining('glicemia_jejum'), findsNothing);
    expect(find.textContaining('110'), findsWidgets);
    expect(find.textContaining('98'), findsNothing);
    expect(find.textContaining('5,6'), findsWidgets);
    expect(find.byKey(const Key('campo_busca_exame')), findsNothing);
    final histExame = tester.getBottomLeft(find.byKey(const Key('btn_historico_exame')));
    final recente = tester.getTopLeft(find.textContaining('110').first);
    expect(recente.dy, greaterThan(histExame.dy));

    await tocar(tester, const Key('btn_tipo_glicemia'));
    await tocar(tester, const Key('btn_historico_exame'));
    expect(find.byKey(const Key('campo_busca_exame')), findsOneWidget);
    expect(find.textContaining('110'), findsWidgets);
    expect(find.textContaining('98'), findsWidgets);
    expect(find.textContaining('5,6'), findsNothing);
    await escrever(tester, const Key('campo_busca_exame'), '98');
    expect(find.textContaining('110'), findsNothing);
    expect(find.textContaining('98'), findsWidgets);
    await tocar(tester, const Key('btn_voltar'));

    await tocar(tester, const Key('btn_tipo_hba1c'));
    await tocar(tester, const Key('btn_historico_exame'));
    expect(find.textContaining('5,6'), findsWidgets);
    expect(find.textContaining('110'), findsNothing);
  });

  testWidgets('medicamentos ficam empilhados abaixo do salvar, sem busca', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await fluxoAlto(tester);
    await tocar(tester, const Key('btn_inicio'));
    await tocar(tester, const Key('btn_nav_medicamentos'));
    await escrever(tester, const Key('campo_med_nome'), 'Losartana');
    await tocar(tester, const Key('btn_salvar_med'));
    await escrever(tester, const Key('campo_med_nome'), 'Enalapril');
    await tocar(tester, const Key('btn_salvar_med'));
    expect(find.byKey(const Key('campo_busca_med')), findsNothing);
    expect(find.textContaining('Losartana'), findsWidgets);
    expect(find.textContaining('Enalapril'), findsWidgets);
    final salvar = tester.getBottomLeft(find.byKey(const Key('btn_salvar_med')));
    final losa = tester.getTopLeft(find.textContaining('Losartana').first);
    expect(losa.dy, greaterThan(salvar.dy));
  });

  testWidgets('consulta futura fica abaixo do histórico, sem busca na tela', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await fluxoAlto(tester);
    await tocar(tester, const Key('btn_inicio'));
    await tocar(tester, const Key('btn_nav_consultas'));
    await escrever(tester, const Key('campo_consulta_quando'), '16/11/2026 14:00');
    await escrever(tester, const Key('campo_consulta_profissional'), 'Dra. Ana');
    await tocar(tester, const Key('btn_salvar_consulta'));
    expect(find.byKey(const Key('campo_busca_consulta')), findsNothing);
    final histConsulta = tester.getBottomLeft(find.byKey(const Key('btn_historico_consulta')));
    final futura = tester.getTopLeft(find.textContaining('Dra. Ana').first);
    expect(futura.dy, greaterThan(histConsulta.dy));
  });

  test('consulta persiste mesmo se o alarme falhar', () async {
    final memoria = RepositoriosMemoria(_AgendaQuebra());
    await memoria.repos.consulta.salvar(Consulta(
      quando: DateTime(2026, 11, 16, 14),
      profissional: 'Dra. Ana',
      especialidade: 'Clínico',
      local: 'UBS',
    ));
    expect((await memoria.repos.consulta.listar()).single.profissional, 'Dra. Ana');
  });
}

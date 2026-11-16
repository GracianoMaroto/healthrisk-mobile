import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthrisk_mobile/app/copy.dart';
import 'package:healthrisk_mobile/app/datas.dart';
import 'package:healthrisk_mobile/app/probabilidade.dart';
import 'package:healthrisk_mobile/app/sessao.dart';
import 'package:healthrisk_mobile/data/modelos.dart';

import '../helpers/harness.dart';

void main() {
  test('porcentagem em destaque e dízima com vírgula', () {
    expect(FormatoProbabilidade.porcentagem(0.7965), '79,7%');
    expect(FormatoProbabilidade.decimal(0.7965), '0,7965');
  });

  test('consulta aceita data passada com ou sem hora', () {
    expect(parseQuandoConsulta('10/11/2026 14:00'), DateTime(2026, 11, 10, 14));
    expect(parseQuandoConsulta('10/11/2026'), DateTime(2026, 11, 10));
  });

  testWidgets('obrigatório é asterisco no campo, sem o texto entre parênteses', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await aceitarTermo(tester);
    expect(find.text('(obrigatório)'), findsNothing);
    expect(find.byKey(const Key('txt_indicador_campo')), findsNothing);
    final campo = tester.widget<TextField>(
      find.descendant(of: find.byKey(const Key('campo_nascimento')), matching: find.byType(TextField)),
    );
    expect(campo.decoration?.hintText, contains('*'));
  });

  testWidgets('home mostra faixa e porcentagem juntas', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await fluxoAlto(tester);
    expect(find.byKey(const Key('txt_probabilidade')), findsOneWidget);
    expect(find.byKey(const Key('txt_probabilidade_dec')), findsOneWidget);
    await tocar(tester, const Key('btn_inicio'));
    expect(find.byKey(const Key('txt_faixa_home')), findsOneWidget);
    expect(find.byKey(const Key('txt_probabilidade_home')), findsOneWidget);
    expect(find.byKey(const Key('txt_probabilidade_dec_home')), findsOneWidget);
  });

  testWidgets('exame explica glicemia em jejum só com exemplo abaixo do valor', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await fluxoAlto(tester);
    await tocar(tester, const Key('btn_inicio'));
    await tocar(tester, const Key('btn_nav_exames'));
    expect(find.text('Glicemia em jejum'), findsWidgets);
    expect(find.byKey(const Key('btn_historico_exame')), findsOneWidget);
    expect(find.text(Copy.exameGlicemiaAjuda), findsOneWidget);
    final valor = find.byKey(const Key('campo_exame_valor'));
    final ajuda = find.byKey(const Key('txt_exame_valor_ajuda'));
    expect(tester.getTopLeft(ajuda).dy, greaterThan(tester.getTopLeft(valor).dy));
    expect(find.textContaining('Exemplo: 98 ou 126'), findsOneWidget);
    await tocar(tester, const Key('btn_tipo_hba1c'));
    expect(find.textContaining('Exemplo: 5,6 ou 7,0'), findsOneWidget);
  });

  testWidgets('editar e excluir medicamento', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await fluxoAlto(tester);
    await tocar(tester, const Key('btn_inicio'));
    await tocar(tester, const Key('btn_nav_medicamentos'));
    await escrever(tester, const Key('campo_med_nome'), 'Losartana');
    await escrever(tester, const Key('campo_med_dose'), '50 mg');
    await tocar(tester, const Key('btn_salvar_med'));
    final meds = await h.deps.repos.medicamento.listar();
    expect(meds.single.nome, 'Losartana');
    await tocar(tester, Key('btn_editar_med_${meds.single.id}'));
    await escrever(tester, const Key('campo_med_nome'), 'Enalapril');
    await tocar(tester, const Key('btn_salvar_med'));
    expect((await h.deps.repos.medicamento.listar()).single.nome, 'Enalapril');
    await tocar(tester, Key('btn_excluir_med_${meds.single.id}'));
    expect(await h.deps.repos.medicamento.listar(), isEmpty);
  });

  testWidgets('consulta anterior à data atual nasce agendada', (tester) async {
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
    final lista = await h.deps.repos.consulta.listar();
    expect(lista.single.profissional, 'Dr. Paulo');
    expect(lista.single.situacao, 'agendada');
    await tocar(tester, const Key('btn_historico_consulta'));
    expect(find.textContaining('Dr. Paulo'), findsWidgets);
    expect(find.textContaining('Cardiologia'), findsWidgets);
    expect(find.textContaining('UBS Centro'), findsWidgets);
  });

  testWidgets('continuar com HDL em branco grava nulo como não sei', (tester) async {
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
      escolaridade: '2',
      hdl: '',
    );
    expect((await h.deps.repos.perfil.obter())!.hdl, isNull);
  });

  test('sessão vai para home se o questionário já foi respondido', () async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await h.deps.repos.perfil.salvar(Perfil(
      nascimento: DateTime(1968, 1, 15),
      sexo: 1,
      pesoKg: 96,
      alturaCm: 170,
      cinturaCm: 112,
      familiarPrimeiroGrau: true,
      pressaoAlta: true,
      diagnosticoInformado: false,
    ));
    await h.sessao.iniciar();
    expect(h.sessao.tela, TelaApp.questionario);
    await h.deps.repos.questionario.salvar(Avaliacao(
      data: DateTime(2026, 11, 15),
      faixa: 'alto',
      fatores: const ['Cintura: medida alta em relação à altura aumenta a faixa.'],
      respostasJson: '{}',
      probabilidade: 0.8,
    ));
    await h.sessao.iniciar();
    expect(h.sessao.tela, TelaApp.home);
    expect(h.sessao.ultimoResultado?.faixa, 'alto');
  });
}

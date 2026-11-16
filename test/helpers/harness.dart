import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthrisk_mobile/app/app.dart';
import 'package:healthrisk_mobile/app/dependencias.dart';
import 'package:healthrisk_mobile/app/sessao.dart';
import 'package:healthrisk_mobile/data/agenda.dart';
import 'package:healthrisk_mobile/data/cofre.dart';
import 'package:healthrisk_mobile/data/modelos.dart';
import 'package:healthrisk_mobile/data/repositorios_memoria.dart';
import 'package:healthrisk_mobile/domain/avaliador_logistico.dart';

class Harness {
  Harness({
    required this.deps,
    required this.sessao,
    required this.agenda,
  });

  final Dependencias deps;
  final Sessao sessao;
  final AgendaMemoria agenda;

  Widget get app => HealthRiskApp(sessao: sessao);

  Future<void> fechar() async {}
}

Future<Harness> montarHarness() async {
  final agenda = AgendaMemoria();
  final bundle = jsonDecode(
    File('assets/models/mobile_lr_bundle.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final memoria = RepositoriosMemoria(agenda);
  final deps = Dependencias(
    repos: memoria.repos,
    agenda: agenda,
    avaliador: AvaliadorLogistico.fromBundle(bundle),
    cofre: CofreMemoria(),
    relogio: RelogioFixo(DateTime(2026, 11, 15, 10, 0)),
  );
  final sessao = Sessao(deps);
  await sessao.iniciar();
  return Harness(deps: deps, sessao: sessao, agenda: agenda);
}

Future<void> aguardar(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 20));
  await tester.pump(const Duration(milliseconds: 20));
}

Future<void> pumpApp(WidgetTester tester, Harness h) async {
  await tester.pumpWidget(h.app);
  await aguardar(tester);
}

Future<void> tocar(WidgetTester tester, Key key) async {
  final finder = find.byKey(key);
  expect(finder, findsWidgets);
  final naLista = find.ancestor(of: finder, matching: find.byType(Scrollable));
  if (naLista.evaluate().isNotEmpty) {
    await tester.scrollUntilVisible(
      finder.first,
      80,
      scrollable: naLista.first,
      maxScrolls: 16,
    );
  }
  await tester.pump();
  await tester.tap(finder.first, warnIfMissed: false);
  await aguardar(tester);
}

Future<void> escrever(WidgetTester tester, Key key, String texto) async {
  await tester.enterText(find.byKey(key), texto);
  await aguardar(tester);
}

Future<void> aceitarTermo(WidgetTester tester) async {
  await tocar(tester, const Key('btn_aceitar'));
}

Future<void> preencherPerfil(
  WidgetTester tester, {
  required String nascimento,
  required bool masculino,
  required String peso,
  required String altura,
  required String cintura,
  required bool familiar,
  required bool pressao,
  required bool diagnostico,
  String? escolaridade,
  String? hdl,
  bool? inseguranca,
}) async {
  await escrever(tester, const Key('campo_nascimento'), nascimento);
  await tocar(tester, const Key('btn_continuar'));
  await tocar(tester, Key(masculino ? 'btn_sexo_m' : 'btn_sexo_f'));
  await escrever(tester, const Key('campo_peso'), peso);
  await tocar(tester, const Key('btn_continuar'));
  await escrever(tester, const Key('campo_altura'), altura);
  await tocar(tester, const Key('btn_continuar'));
  await escrever(tester, const Key('campo_cintura'), cintura);
  await tocar(tester, const Key('btn_continuar'));
  await tocar(tester, Key(familiar ? 'btn_sim' : 'btn_nao'));
  await tocar(tester, Key(pressao ? 'btn_sim' : 'btn_nao'));
  await tocar(tester, Key(diagnostico ? 'btn_sim' : 'btn_nao'));
  if (escolaridade == null) {
    await tocar(tester, const Key('btn_pular'));
  } else {
    await tocar(tester, Key('btn_esc_$escolaridade'));
  }
  if (hdl == null) {
    await tocar(tester, const Key('btn_pular'));
  } else {
    await escrever(tester, const Key('campo_hdl'), hdl);
    await tocar(tester, const Key('btn_continuar'));
  }
  if (inseguranca == null) {
    await tocar(tester, const Key('btn_pular'));
  } else {
    await tocar(tester, Key(inseguranca ? 'btn_sim' : 'btn_nao'));
  }
}

Future<void> responderQuiz(WidgetTester tester, List<bool> respostas) async {
  for (final sim in respostas) {
    await tocar(tester, Key(sim ? 'btn_sim' : 'btn_nao'));
  }
}

Future<void> fluxoAlto(WidgetTester tester, {bool diagnostico = false}) async {
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
    diagnostico: diagnostico,
    escolaridade: '2',
    hdl: '38',
    inseguranca: true,
  );
  await responderQuiz(tester, const [false, true, true, true, false, true]);
  await aguardar(tester);
}

Future<void> fluxoBaixo(WidgetTester tester) async {
  await aceitarTermo(tester);
  await preencherPerfil(
    tester,
    nascimento: '15/06/1997',
    masculino: false,
    peso: '61',
    altura: '165',
    cintura: '74',
    familiar: false,
    pressao: false,
    diagnostico: false,
    escolaridade: '5',
    hdl: '62',
    inseguranca: false,
  );
  await responderQuiz(tester, const [true, false, false, false, true, false]);
  await aguardar(tester);
}

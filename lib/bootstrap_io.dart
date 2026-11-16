import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healthrisk_mobile/app/app.dart';
import 'package:healthrisk_mobile/app/dependencias.dart';
import 'package:healthrisk_mobile/app/sessao.dart';
import 'package:healthrisk_mobile/data/agenda.dart';
import 'package:healthrisk_mobile/data/agenda_local.dart';
import 'package:healthrisk_mobile/data/banco.dart';
import 'package:healthrisk_mobile/data/cofre.dart';
import 'package:healthrisk_mobile/data/modelos.dart';
import 'package:healthrisk_mobile/data/repositorios_sqlite.dart';
import 'package:healthrisk_mobile/domain/avaliador_logistico.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Widget> criarApp() async {
  if (!Platform.isAndroid && !Platform.isIOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  final dir = await getApplicationDocumentsDirectory();
  final agenda = await _criarAgenda();
  final banco = await Banco.abrir(
    caminho: p.join(dir.path, 'healthrisk.db'),
    agenda: agenda,
  );
  final raw = await rootBundle.loadString('assets/models/mobile_lr_bundle.json');
  final deps = Dependencias(
    repos: repositoriosSqlite(banco),
    agenda: agenda,
    avaliador: AvaliadorLogistico.fromBundle(jsonDecode(raw) as Map<String, dynamic>),
    cofre: CofreSeguro(),
    relogio: RelogioSistema(),
  );
  final sessao = Sessao(deps);
  await sessao.iniciar();
  return HealthRiskApp(sessao: sessao);
}

Future<AgendaAlarmes> _criarAgenda() async {
  if (!Platform.isAndroid && !Platform.isIOS) {
    return AgendaMemoria();
  }
  try {
    return await AgendaLocal.criar();
  } catch (_) {
    return AgendaMemoria();
  }
}

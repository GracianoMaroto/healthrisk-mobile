import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healthrisk_mobile/app/app.dart';
import 'package:healthrisk_mobile/app/dependencias.dart';
import 'package:healthrisk_mobile/app/sessao.dart';
import 'package:healthrisk_mobile/data/agenda.dart';
import 'package:healthrisk_mobile/data/cofre.dart';
import 'package:healthrisk_mobile/data/modelos.dart';
import 'package:healthrisk_mobile/data/persistencia_web.dart';
import 'package:healthrisk_mobile/data/repositorios_memoria.dart';
import 'package:healthrisk_mobile/domain/avaliador_logistico.dart';

/// Preview no Chrome: estado no localStorage para sobreviver ao recarregar a aba.
Future<Widget> criarApp() async {
  final agenda = AgendaMemoria();
  final memoria = RepositoriosMemoria(agenda);
  final bruto = lerEstadoWeb();
  if (bruto != null && bruto.isNotEmpty) {
    try {
      memoria.load(jsonDecode(bruto) as Map<String, dynamic>);
    } catch (_) {}
  }
  memoria.aoMudar = (estado) => gravarEstadoWeb(jsonEncode(estado));
  final raw = await rootBundle.loadString('assets/models/mobile_lr_bundle.json');
  final deps = Dependencias(
    repos: memoria.repos,
    agenda: agenda,
    avaliador: AvaliadorLogistico.fromBundle(jsonDecode(raw) as Map<String, dynamic>),
    cofre: CofreMemoria(),
    relogio: RelogioSistema(),
  );
  final sessao = Sessao(deps);
  await sessao.iniciar();
  return HealthRiskApp(sessao: sessao);
}

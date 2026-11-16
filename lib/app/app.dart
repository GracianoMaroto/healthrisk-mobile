import 'package:flutter/material.dart';
import 'package:healthrisk_mobile/app/copy.dart';
import 'package:healthrisk_mobile/app/sessao.dart';
import 'package:healthrisk_mobile/app/tema.dart';
import 'package:provider/provider.dart';
import 'package:healthrisk_mobile/ui/ajustes_page.dart';
import 'package:healthrisk_mobile/ui/consultas_historico_page.dart';
import 'package:healthrisk_mobile/ui/consultas_page.dart';
import 'package:healthrisk_mobile/ui/exames_historico_page.dart';
import 'package:healthrisk_mobile/ui/exames_page.dart';
import 'package:healthrisk_mobile/ui/home_page.dart';
import 'package:healthrisk_mobile/ui/medicamentos_page.dart';
import 'package:healthrisk_mobile/ui/perfil_page.dart';
import 'package:healthrisk_mobile/ui/pin_page.dart';
import 'package:healthrisk_mobile/ui/questionario_page.dart';
import 'package:healthrisk_mobile/ui/resultado_page.dart';
import 'package:healthrisk_mobile/ui/termo_page.dart';

class HealthRiskApp extends StatelessWidget {
  const HealthRiskApp({super.key, required this.sessao});

  final Sessao sessao;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Sessao>.value(
      value: sessao,
      child: MaterialApp(
      title: Copy.appNome,
      debugShowCheckedModeBanner: false,
      theme: TemaSaude.theme,
      home: ListenableBuilder(
        listenable: sessao,
        builder: (context, _) {
          return switch (sessao.tela) {
            TelaApp.termo => TermoPage(sessao: sessao),
            TelaApp.pin => PinPage(sessao: sessao),
            TelaApp.perfil => PerfilPage(sessao: sessao),
            TelaApp.questionario => QuestionarioPage(sessao: sessao),
            TelaApp.resultado => ResultadoPage(sessao: sessao),
            TelaApp.home => HomePage(sessao: sessao),
            TelaApp.medicamentos => MedicamentosPage(sessao: sessao),
            TelaApp.consultas => ConsultasPage(sessao: sessao),
            TelaApp.consultasHistorico => ConsultasHistoricoPage(sessao: sessao),
            TelaApp.exames => ExamesPage(sessao: sessao),
            TelaApp.examesHistorico => ExamesHistoricoPage(sessao: sessao),
            TelaApp.ajustes => AjustesPage(sessao: sessao),
          };
        },
      ),
    ),
    );
  }
}

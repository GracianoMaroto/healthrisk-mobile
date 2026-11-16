import 'package:healthrisk_mobile/data/agenda.dart';
import 'package:healthrisk_mobile/data/cofre.dart';
import 'package:healthrisk_mobile/data/modelos.dart';
import 'package:healthrisk_mobile/data/repositorios.dart';
import 'package:healthrisk_mobile/domain/avaliador_risco.dart';

class Dependencias {
  Dependencias({
    required this.repos,
    required this.agenda,
    required this.avaliador,
    required this.cofre,
    required this.relogio,
  });

  final Repositorios repos;
  final AgendaAlarmes agenda;
  final AvaliadorRisco avaliador;
  final CofrePin cofre;
  final Relogio relogio;
}

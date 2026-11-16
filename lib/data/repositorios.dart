import 'package:healthrisk_mobile/data/agenda.dart';
import 'package:healthrisk_mobile/data/modelos.dart';

abstract class PerfilRepositorio {
  Future<void> salvar(Perfil perfil);
  Future<Perfil?> obter();
}

abstract class QuestionarioRepositorio {
  Future<int> salvar(Avaliacao a);
  Future<Avaliacao?> ultima();
  Future<List<Avaliacao>> listar();
}

abstract class MedicamentoRepositorio {
  Future<int> salvar(Medicamento m);
  Future<void> excluir(int id);
  Future<List<Medicamento>> listar();
  Future<void> marcarTomada({required int medicamentoId, required String data});
  Future<bool> tomada({required int medicamentoId, required String data});
  Future<List<Dose>> dosesDoDia(String data);
}

abstract class ConsultaRepositorio {
  Future<int> salvar(Consulta c);
  Future<void> excluir(int id);
  Future<List<Consulta>> listar();
  Future<Consulta?> proxima(DateTime agora);
}

abstract class ExameRepositorio {
  Future<int> salvar(Exame e);
  Future<void> excluir(int id);
  Future<List<Exame>> listar();
}

void garantirAltura(Perfil perfil) {
  if (perfil.alturaCm <= 0) {
    throw ArgumentError('Altura zerada não entra na conta');
  }
}

class Repositorios {
  Repositorios({
    required this.perfil,
    required this.questionario,
    required this.medicamento,
    required this.consulta,
    required this.exame,
    required Future<void> Function() apagarTudo,
  }) : _apagarTudo = apagarTudo;

  final PerfilRepositorio perfil;
  final QuestionarioRepositorio questionario;
  final MedicamentoRepositorio medicamento;
  final ConsultaRepositorio consulta;
  final ExameRepositorio exame;
  final Future<void> Function() _apagarTudo;

  Future<void> apagarTudo() => _apagarTudo();
}

Future<void> tentarAgendar(
  AgendaAlarmes agenda, {
  required int id,
  required DateTime quando,
  required String canal,
  required String texto,
}) async {
  try {
    await agenda.agendar(id: id, quando: quando, canal: canal, texto: texto);
  } catch (_) {}
}

Future<void> tentarCancelar(AgendaAlarmes agenda, int id) async {
  try {
    await agenda.cancelar(id);
  } catch (_) {}
}

Future<void> agendarLembretesConsulta(AgendaAlarmes agenda, int id, Consulta c) async {
  if (c.situacao != 'agendada') return;
  await tentarAgendar(
    agenda,
    id: id * 10 + 24,
    quando: c.quando.subtract(const Duration(hours: 24)),
    canal: 'consultas',
    texto: 'Consulta em 24 horas com ${c.profissional}',
  );
  await tentarAgendar(
    agenda,
    id: id * 10 + 2,
    quando: c.quando.subtract(const Duration(hours: 2)),
    canal: 'consultas',
    texto: 'Consulta em 2 horas com ${c.profissional}',
  );
}

Future<void> cancelarLembretesConsulta(AgendaAlarmes agenda, int id) async {
  await tentarCancelar(agenda, id * 10 + 24);
  await tentarCancelar(agenda, id * 10 + 2);
}

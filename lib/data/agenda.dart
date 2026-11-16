import 'package:healthrisk_mobile/data/modelos.dart';

abstract class AgendaAlarmes {
  Future<void> agendar({
    required int id,
    required DateTime quando,
    required String canal,
    required String texto,
  });

  Future<void> cancelar(int id);
  Future<void> cancelarTodos();
}

DateTime proximaOcorrencia(DateTime agora, String horarioHhMm) {
  final partes = horarioHhMm.split(':');
  final hora = int.tryParse(partes[0]) ?? 8;
  final minuto = partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0;
  var quando = DateTime(agora.year, agora.month, agora.day, hora, minuto);
  if (!quando.isAfter(agora)) {
    quando = quando.add(const Duration(days: 1));
  }
  return quando;
}

class AgendaMemoria implements AgendaAlarmes {
  final List<AgendamentoRegistrado> registrados = [];
  int cancelarTodosChamadas = 0;

  @override
  Future<void> agendar({
    required int id,
    required DateTime quando,
    required String canal,
    required String texto,
  }) async {
    registrados.removeWhere((a) => a.id == id);
    registrados.add(AgendamentoRegistrado(id: id, quando: quando, canal: canal, texto: texto));
  }

  @override
  Future<void> cancelar(int id) async {
    registrados.removeWhere((a) => a.id == id);
  }

  @override
  Future<void> cancelarTodos() async {
    cancelarTodosChamadas += 1;
    registrados.clear();
  }
}

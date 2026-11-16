import 'package:flutter/foundation.dart';
import 'package:healthrisk_mobile/app/dependencias.dart';
import 'package:healthrisk_mobile/data/modelos.dart';
import 'package:healthrisk_mobile/domain/resultado.dart';

enum TelaApp {
  termo,
  pin,
  perfil,
  questionario,
  resultado,
  home,
  medicamentos,
  consultas,
  consultasHistorico,
  exames,
  examesHistorico,
  ajustes,
}

class Sessao extends ChangeNotifier {
  Sessao(this.deps);

  final Dependencias deps;
  TelaApp tela = TelaApp.termo;
  Resultado? ultimoResultado;
  Perfil? perfil;
  bool desbloqueado = false;
  String tipoExameHistorico = 'glicemia_jejum';
  Consulta? consultaEmEdicao;
  Exame? exameEmEdicao;

  Future<void> iniciar() async {
    perfil = await deps.repos.perfil.obter();
    if (await deps.cofre.temPin() && !desbloqueado) {
      tela = TelaApp.pin;
    } else if (perfil != null) {
      ultimoResultado = _deAvaliacao(await deps.repos.questionario.ultima());
      tela = ultimoResultado == null ? TelaApp.questionario : TelaApp.home;
    } else {
      tela = TelaApp.termo;
    }
    notifyListeners();
  }

  void ir(TelaApp destino) {
    tela = destino;
    notifyListeners();
  }

  void irHistoricoExames(String tipo) {
    tipoExameHistorico = tipo;
    ir(TelaApp.examesHistorico);
  }

  void irEditarConsulta(Consulta c) {
    consultaEmEdicao = c;
    ir(TelaApp.consultas);
  }

  void irEditarExame(Exame e) {
    exameEmEdicao = e;
    ir(TelaApp.exames);
  }

  void publicarResultado(Resultado resultado) {
    ultimoResultado = resultado;
    tela = TelaApp.resultado;
    notifyListeners();
  }

  Resultado? _deAvaliacao(Avaliacao? a) {
    if (a == null) return null;
    return Resultado(
      faixa: a.faixa,
      probabilidade: a.probabilidade,
      pontos: a.pontos,
      fatores: a.fatores,
    );
  }
}

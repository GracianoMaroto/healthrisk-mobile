import 'package:healthrisk_mobile/data/agenda.dart';
import 'package:healthrisk_mobile/data/modelos.dart';
import 'package:healthrisk_mobile/data/repositorios.dart';

/// Persistência em RAM para testes de widget/E2E no Windows, sem sqlite3.dll.
class RepositoriosMemoria {
  RepositoriosMemoria(this.agenda, {this.aoMudar})
      : perfil = _PerfilMemoria(),
        questionario = _QuestionarioMemoria(),
        medicamento = _MedicamentoMemoria(),
        consulta = _ConsultaMemoria(agenda),
        exame = _ExameMemoria() {
    perfil.aoMudar = _avisar;
    questionario.aoMudar = _avisar;
    medicamento.aoMudar = _avisar;
    consulta.aoMudar = _avisar;
    exame.aoMudar = _avisar;
  }

  final AgendaAlarmes agenda;
  void Function(Map<String, dynamic> estado)? aoMudar;
  final _PerfilMemoria perfil;
  final _QuestionarioMemoria questionario;
  final _MedicamentoMemoria medicamento;
  final _ConsultaMemoria consulta;
  final _ExameMemoria exame;

  void _avisar() => aoMudar?.call(dump());

  Repositorios get repos => Repositorios(
        perfil: perfil,
        questionario: questionario,
        medicamento: medicamento,
        consulta: consulta,
        exame: exame,
        apagarTudo: apagarTudo,
      );

  Map<String, dynamic> dump() => {
        'perfil': perfil.dado == null ? null : _perfilMap(perfil.dado!),
        'questionario': [for (final a in questionario.itens) _avaliacaoMap(a)],
        'medicamento': [for (final m in medicamento.itens) _medMap(m)],
        'doses': [for (final d in medicamento.doses) _doseMap(d)],
        'consulta': [for (final c in consulta.itens) _consultaMap(c)],
        'exame': [for (final e in exame.itens) _exameMap(e)],
      };

  void load(Map<String, dynamic> estado) {
    perfil.dado = estado['perfil'] == null ? null : _perfilDe(estado['perfil'] as Map);
    questionario.itens
      ..clear()
      ..addAll([
        for (final a in (estado['questionario'] as List? ?? const []))
          _avaliacaoDe(a as Map),
      ]);
    questionario._seq = questionario.itens.fold<int>(0, (m, a) => a.id != null && a.id! > m ? a.id! : m);
    medicamento.itens
      ..clear()
      ..addAll([
        for (final m in (estado['medicamento'] as List? ?? const [])) _medDe(m as Map),
      ]);
    medicamento.doses
      ..clear()
      ..addAll([
        for (final d in (estado['doses'] as List? ?? const [])) _doseDe(d as Map),
      ]);
    medicamento._seq = medicamento.itens.fold<int>(0, (m, x) => x.id != null && x.id! > m ? x.id! : m);
    medicamento._doseSeq = medicamento.doses.fold<int>(0, (m, x) => x.id != null && x.id! > m ? x.id! : m);
    consulta.itens
      ..clear()
      ..addAll([
        for (final c in (estado['consulta'] as List? ?? const [])) _consultaDe(c as Map),
      ]);
    consulta._seq = consulta.itens.fold<int>(0, (m, c) => c.id != null && c.id! > m ? c.id! : m);
    exame.itens
      ..clear()
      ..addAll([
        for (final e in (estado['exame'] as List? ?? const [])) _exameDe(e as Map),
      ]);
    exame._seq = exame.itens.fold<int>(0, (m, e) => e.id != null && e.id! > m ? e.id! : m);
  }

  Future<void> apagarTudo() async {
    perfil.dado = null;
    questionario.itens.clear();
    medicamento.itens.clear();
    medicamento.doses.clear();
    consulta.itens.clear();
    exame.itens.clear();
    await agenda.cancelarTodos();
    _avisar();
  }
}

Map<String, dynamic> _perfilMap(Perfil p) => {
      'nascimento': p.nascimento.toIso8601String(),
      'sexo': p.sexo,
      'pesoKg': p.pesoKg,
      'alturaCm': p.alturaCm,
      'cinturaCm': p.cinturaCm,
      'familiarPrimeiroGrau': p.familiarPrimeiroGrau,
      'pressaoAlta': p.pressaoAlta,
      'diagnosticoInformado': p.diagnosticoInformado,
      'escolaridadeOrd': p.escolaridadeOrd,
      'hdl': p.hdl,
      'insegurancaAlimentar': p.insegurancaAlimentar,
      'termoAceito': p.termoAceito,
    };

Perfil _perfilDe(Map m) => Perfil(
      nascimento: DateTime.parse(m['nascimento'] as String),
      sexo: m['sexo'] as int,
      pesoKg: (m['pesoKg'] as num).toDouble(),
      alturaCm: (m['alturaCm'] as num).toDouble(),
      cinturaCm: (m['cinturaCm'] as num).toDouble(),
      familiarPrimeiroGrau: m['familiarPrimeiroGrau'] as bool,
      pressaoAlta: m['pressaoAlta'] as bool,
      diagnosticoInformado: m['diagnosticoInformado'] as bool,
      escolaridadeOrd: m['escolaridadeOrd'] as int?,
      hdl: (m['hdl'] as num?)?.toDouble(),
      insegurancaAlimentar: m['insegurancaAlimentar'] as bool?,
      termoAceito: m['termoAceito'] as bool? ?? true,
    );

Map<String, dynamic> _avaliacaoMap(Avaliacao a) => {
      'id': a.id,
      'data': a.data.toIso8601String(),
      'faixa': a.faixa,
      'probabilidade': a.probabilidade,
      'pontos': a.pontos,
      'fatores': a.fatores,
      'respostasJson': a.respostasJson,
    };

Avaliacao _avaliacaoDe(Map m) => Avaliacao(
      id: m['id'] as int?,
      data: DateTime.parse(m['data'] as String),
      faixa: m['faixa'] as String,
      probabilidade: (m['probabilidade'] as num?)?.toDouble(),
      pontos: m['pontos'] as int?,
      fatores: (m['fatores'] as List).cast<String>(),
      respostasJson: m['respostasJson'] as String,
    );

Map<String, dynamic> _medMap(Medicamento m) => {
      'id': m.id,
      'nome': m.nome,
      'dose': m.dose,
      'horarios': m.horarios,
      'diasSemana': m.diasSemana,
      'ativo': m.ativo,
    };

Medicamento _medDe(Map m) => Medicamento(
      id: m['id'] as int?,
      nome: m['nome'] as String,
      dose: m['dose'] as String,
      horarios: (m['horarios'] as List).cast<String>(),
      diasSemana: (m['diasSemana'] as List).cast<int>(),
      ativo: m['ativo'] as bool? ?? true,
    );

Map<String, dynamic> _doseMap(Dose d) => {
      'id': d.id,
      'medicamentoId': d.medicamentoId,
      'data': d.data,
      'tomada': d.tomada,
    };

Dose _doseDe(Map m) => Dose(
      id: m['id'] as int?,
      medicamentoId: m['medicamentoId'] as int,
      data: m['data'] as String,
      tomada: m['tomada'] as bool,
    );

Map<String, dynamic> _consultaMap(Consulta c) => {
      'id': c.id,
      'quando': c.quando.toIso8601String(),
      'profissional': c.profissional,
      'especialidade': c.especialidade,
      'local': c.local,
      'situacao': c.situacao,
    };

Consulta _consultaDe(Map m) => Consulta(
      id: m['id'] as int?,
      quando: DateTime.parse(m['quando'] as String),
      profissional: m['profissional'] as String,
      especialidade: m['especialidade'] as String,
      local: m['local'] as String,
      situacao: m['situacao'] as String? ?? 'agendada',
    );

Map<String, dynamic> _exameMap(Exame e) => {
      'id': e.id,
      'tipo': e.tipo,
      'valor': e.valor,
      'unidade': e.unidade,
      'data': e.data.toIso8601String(),
    };

Exame _exameDe(Map m) => Exame(
      id: m['id'] as int?,
      tipo: m['tipo'] as String,
      valor: (m['valor'] as num).toDouble(),
      unidade: m['unidade'] as String,
      data: DateTime.parse(m['data'] as String),
    );

class _PerfilMemoria implements PerfilRepositorio {
  Perfil? dado;
  void Function()? aoMudar;

  @override
  Future<void> salvar(Perfil perfil) async {
    garantirAltura(perfil);
    dado = perfil;
    aoMudar?.call();
  }

  @override
  Future<Perfil?> obter() async => dado;
}

class _QuestionarioMemoria implements QuestionarioRepositorio {
  final List<Avaliacao> itens = [];
  int _seq = 0;
  void Function()? aoMudar;

  @override
  Future<int> salvar(Avaliacao a) async {
    _seq += 1;
    itens.add(Avaliacao(
      id: _seq,
      data: a.data,
      faixa: a.faixa,
      fatores: a.fatores,
      respostasJson: a.respostasJson,
      probabilidade: a.probabilidade,
      pontos: a.pontos,
    ));
    aoMudar?.call();
    return _seq;
  }

  @override
  Future<Avaliacao?> ultima() async => itens.isEmpty ? null : itens.last;

  @override
  Future<List<Avaliacao>> listar() async => List.unmodifiable(itens.reversed);
}

class _MedicamentoMemoria implements MedicamentoRepositorio {
  final List<Medicamento> itens = [];
  final List<Dose> doses = [];
  int _seq = 0;
  int _doseSeq = 0;
  void Function()? aoMudar;

  @override
  Future<int> salvar(Medicamento m) async {
    if (m.id != null) {
      final i = itens.indexWhere((x) => x.id == m.id);
      if (i >= 0) {
        itens[i] = m;
        aoMudar?.call();
        return m.id!;
      }
    }
    _seq += 1;
    itens.add(Medicamento(
      id: _seq,
      nome: m.nome,
      dose: m.dose,
      horarios: m.horarios,
      diasSemana: m.diasSemana,
      ativo: m.ativo,
    ));
    aoMudar?.call();
    return _seq;
  }

  @override
  Future<void> excluir(int id) async {
    itens.removeWhere((m) => m.id == id);
    doses.removeWhere((d) => d.medicamentoId == id);
    aoMudar?.call();
  }

  @override
  Future<List<Medicamento>> listar() async => List.unmodifiable(itens);

  @override
  Future<void> marcarTomada({required int medicamentoId, required String data}) async {
    _doseSeq += 1;
    doses.add(Dose(id: _doseSeq, medicamentoId: medicamentoId, data: data, tomada: true));
    aoMudar?.call();
  }

  @override
  Future<bool> tomada({required int medicamentoId, required String data}) async {
    return doses.any((d) => d.medicamentoId == medicamentoId && d.data == data && d.tomada);
  }

  @override
  Future<List<Dose>> dosesDoDia(String data) async {
    return doses.where((d) => d.data == data).toList();
  }
}

class _ConsultaMemoria implements ConsultaRepositorio {
  _ConsultaMemoria(this.agenda);
  final AgendaAlarmes agenda;
  final List<Consulta> itens = [];
  int _seq = 0;
  void Function()? aoMudar;

  @override
  Future<int> salvar(Consulta c) async {
    if (c.id != null) {
      final i = itens.indexWhere((x) => x.id == c.id);
      if (i >= 0) {
        itens[i] = c;
        await cancelarLembretesConsulta(agenda, c.id!);
        await agendarLembretesConsulta(agenda, c.id!, c);
        aoMudar?.call();
        return c.id!;
      }
    }
    _seq += 1;
    itens.add(Consulta(
      id: _seq,
      quando: c.quando,
      profissional: c.profissional,
      especialidade: c.especialidade,
      local: c.local,
      situacao: c.situacao,
    ));
    await agendarLembretesConsulta(agenda, _seq, c);
    aoMudar?.call();
    return _seq;
  }

  @override
  Future<void> excluir(int id) async {
    itens.removeWhere((c) => c.id == id);
    await cancelarLembretesConsulta(agenda, id);
    aoMudar?.call();
  }

  @override
  Future<List<Consulta>> listar() async {
    final copia = [...itens]..sort((a, b) => a.quando.compareTo(b.quando));
    return copia;
  }

  @override
  Future<Consulta?> proxima(DateTime agora) async {
    final futuras = (await listar())
        .where((c) => c.situacao == 'agendada' && c.quando.isAfter(agora))
        .toList();
    if (futuras.isEmpty) return null;
    return futuras.first;
  }
}

class _ExameMemoria implements ExameRepositorio {
  final List<Exame> itens = [];
  int _seq = 0;
  void Function()? aoMudar;

  @override
  Future<int> salvar(Exame e) async {
    if (e.id != null) {
      final i = itens.indexWhere((x) => x.id == e.id);
      if (i >= 0) {
        itens[i] = e;
        aoMudar?.call();
        return e.id!;
      }
    }
    _seq += 1;
    itens.add(Exame(
      id: _seq,
      tipo: e.tipo,
      valor: e.valor,
      unidade: e.unidade,
      data: e.data,
    ));
    aoMudar?.call();
    return _seq;
  }

  @override
  Future<void> excluir(int id) async {
    itens.removeWhere((e) => e.id == id);
    aoMudar?.call();
  }

  @override
  Future<List<Exame>> listar() async {
    final copia = [...itens]..sort((a, b) => b.data.compareTo(a.data));
    return copia;
  }
}

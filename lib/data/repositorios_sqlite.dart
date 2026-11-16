import 'dart:convert';

import 'package:healthrisk_mobile/data/banco.dart';
import 'package:healthrisk_mobile/data/modelos.dart';
import 'package:healthrisk_mobile/data/repositorios.dart';
import 'package:sqflite/sqflite.dart';

Repositorios repositoriosSqlite(Banco banco) {
  return Repositorios(
    perfil: PerfilRepositorioSqlite(banco),
    questionario: QuestionarioRepositorioSqlite(banco),
    medicamento: MedicamentoRepositorioSqlite(banco),
    consulta: ConsultaRepositorioSqlite(banco),
    exame: ExameRepositorioSqlite(banco),
    apagarTudo: banco.apagarTudo,
  );
}

class PerfilRepositorioSqlite implements PerfilRepositorio {
  PerfilRepositorioSqlite(this.banco);
  final Banco banco;

  @override
  Future<void> salvar(Perfil perfil) async {
    garantirAltura(perfil);
    await banco.db.insert('perfil', {
      'id': 1,
      'nascimento': perfil.nascimento.toIso8601String(),
      'sexo': perfil.sexo,
      'peso_kg': perfil.pesoKg,
      'altura_cm': perfil.alturaCm,
      'cintura_cm': perfil.cinturaCm,
      'familiar': perfil.familiarPrimeiroGrau ? 1 : 0,
      'pressao_alta': perfil.pressaoAlta ? 1 : 0,
      'diagnostico_informado': perfil.diagnosticoInformado ? 1 : 0,
      'escolaridade_ord': perfil.escolaridadeOrd,
      'hdl': perfil.hdl,
      'inseguranca_alimentar': perfil.insegurancaAlimentar == null
          ? null
          : (perfil.insegurancaAlimentar! ? 1 : 0),
      'termo_aceito': perfil.termoAceito ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<Perfil?> obter() async {
    final rows = await banco.db.query('perfil', where: 'id = 1');
    if (rows.isEmpty) return null;
    final r = rows.first;
    return Perfil(
      nascimento: DateTime.parse(r['nascimento']! as String),
      sexo: r['sexo']! as int,
      pesoKg: (r['peso_kg']! as num).toDouble(),
      alturaCm: (r['altura_cm']! as num).toDouble(),
      cinturaCm: (r['cintura_cm']! as num).toDouble(),
      familiarPrimeiroGrau: r['familiar'] == 1,
      pressaoAlta: r['pressao_alta'] == 1,
      diagnosticoInformado: r['diagnostico_informado'] == 1,
      escolaridadeOrd: r['escolaridade_ord'] as int?,
      hdl: (r['hdl'] as num?)?.toDouble(),
      insegurancaAlimentar: r['inseguranca_alimentar'] == null
          ? null
          : r['inseguranca_alimentar'] == 1,
      termoAceito: r['termo_aceito'] == 1,
    );
  }
}

class QuestionarioRepositorioSqlite implements QuestionarioRepositorio {
  QuestionarioRepositorioSqlite(this.banco);
  final Banco banco;

  @override
  Future<int> salvar(Avaliacao a) async {
    return banco.db.insert('questionario', {
      'data': a.data.toIso8601String(),
      'faixa': a.faixa,
      'probabilidade': a.probabilidade,
      'pontos': a.pontos,
      'fatores': jsonEncode(a.fatores),
      'respostas': a.respostasJson,
    });
  }

  @override
  Future<Avaliacao?> ultima() async {
    final rows = await banco.db.query('questionario', orderBy: 'id DESC', limit: 1);
    if (rows.isEmpty) return null;
    return _deRow(rows.first);
  }

  @override
  Future<List<Avaliacao>> listar() async {
    final rows = await banco.db.query('questionario', orderBy: 'id DESC');
    return [for (final r in rows) _deRow(r)];
  }

  Avaliacao _deRow(Map<String, Object?> r) {
    return Avaliacao(
      id: r['id'] as int,
      data: DateTime.parse(r['data']! as String),
      faixa: r['faixa']! as String,
      probabilidade: (r['probabilidade'] as num?)?.toDouble(),
      pontos: r['pontos'] as int?,
      fatores: (jsonDecode(r['fatores']! as String) as List).cast<String>(),
      respostasJson: r['respostas']! as String,
    );
  }
}

class MedicamentoRepositorioSqlite implements MedicamentoRepositorio {
  MedicamentoRepositorioSqlite(this.banco);
  final Banco banco;

  @override
  Future<int> salvar(Medicamento m) async {
    final dados = {
      'nome': m.nome,
      'dose': m.dose,
      'horarios': jsonEncode(m.horarios),
      'dias_semana': jsonEncode(m.diasSemana),
      'ativo': m.ativo ? 1 : 0,
    };
    if (m.id != null) {
      await banco.db.update('medicamento', dados, where: 'id = ?', whereArgs: [m.id]);
      return m.id!;
    }
    return banco.db.insert('medicamento', dados);
  }

  @override
  Future<void> excluir(int id) async {
    await banco.db.delete('dose', where: 'medicamento_id = ?', whereArgs: [id]);
    await banco.db.delete('medicamento', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Medicamento>> listar() async {
    final rows = await banco.db.query('medicamento', orderBy: 'id ASC');
    return [
      for (final r in rows)
        Medicamento(
          id: r['id'] as int,
          nome: r['nome']! as String,
          dose: r['dose']! as String,
          horarios: (jsonDecode(r['horarios']! as String) as List).cast<String>(),
          diasSemana: (jsonDecode(r['dias_semana']! as String) as List).cast<int>(),
          ativo: r['ativo'] == 1,
        ),
    ];
  }

  @override
  Future<void> marcarTomada({required int medicamentoId, required String data}) async {
    await banco.db.insert('dose', {
      'medicamento_id': medicamentoId,
      'data': data,
      'tomada': 1,
    });
  }

  @override
  Future<bool> tomada({required int medicamentoId, required String data}) async {
    final rows = await banco.db.query(
      'dose',
      where: 'medicamento_id = ? AND data = ? AND tomada = 1',
      whereArgs: [medicamentoId, data],
    );
    return rows.isNotEmpty;
  }

  @override
  Future<List<Dose>> dosesDoDia(String data) async {
    final rows = await banco.db.query('dose', where: 'data = ?', whereArgs: [data]);
    return [
      for (final r in rows)
        Dose(
          id: r['id'] as int,
          medicamentoId: r['medicamento_id'] as int,
          data: r['data']! as String,
          tomada: r['tomada'] == 1,
        ),
    ];
  }
}

class ConsultaRepositorioSqlite implements ConsultaRepositorio {
  ConsultaRepositorioSqlite(this.banco);
  final Banco banco;

  @override
  Future<int> salvar(Consulta c) async {
    final dados = {
      'quando': c.quando.toIso8601String(),
      'profissional': c.profissional,
      'especialidade': c.especialidade,
      'local': c.local,
      'situacao': c.situacao,
    };
    if (c.id != null) {
      await banco.db.update('consulta', dados, where: 'id = ?', whereArgs: [c.id]);
      await cancelarLembretesConsulta(banco.agenda, c.id!);
      await agendarLembretesConsulta(banco.agenda, c.id!, c);
      return c.id!;
    }
    final id = await banco.db.insert('consulta', dados);
    await agendarLembretesConsulta(banco.agenda, id, c);
    return id;
  }

  @override
  Future<void> excluir(int id) async {
    await banco.db.delete('consulta', where: 'id = ?', whereArgs: [id]);
    await cancelarLembretesConsulta(banco.agenda, id);
  }

  @override
  Future<List<Consulta>> listar() async {
    final rows = await banco.db.query('consulta', orderBy: 'quando ASC');
    return [
      for (final r in rows)
        Consulta(
          id: r['id'] as int,
          quando: DateTime.parse(r['quando']! as String),
          profissional: r['profissional']! as String,
          especialidade: r['especialidade']! as String,
          local: r['local']! as String,
          situacao: r['situacao']! as String,
        ),
    ];
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

class ExameRepositorioSqlite implements ExameRepositorio {
  ExameRepositorioSqlite(this.banco);
  final Banco banco;

  @override
  Future<int> salvar(Exame e) async {
    final dados = {
      'tipo': e.tipo,
      'valor': e.valor,
      'unidade': e.unidade,
      'data': e.data.toIso8601String(),
    };
    if (e.id != null) {
      await banco.db.update('exame', dados, where: 'id = ?', whereArgs: [e.id]);
      return e.id!;
    }
    return banco.db.insert('exame', dados);
  }

  @override
  Future<void> excluir(int id) async {
    await banco.db.delete('exame', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Exame>> listar() async {
    final rows = await banco.db.query('exame', orderBy: 'data DESC');
    return [
      for (final r in rows)
        Exame(
          id: r['id'] as int,
          tipo: r['tipo']! as String,
          valor: (r['valor']! as num).toDouble(),
          unidade: r['unidade']! as String,
          data: DateTime.parse(r['data']! as String),
        ),
    ];
  }
}

import 'package:healthrisk_mobile/data/agenda.dart';
import 'package:sqflite/sqflite.dart';

class Banco {
  Banco(this._db, this.agenda);

  final Database _db;
  final AgendaAlarmes agenda;

  Database get db => _db;

  static Future<Banco> abrir({
    required String caminho,
    required AgendaAlarmes agenda,
  }) async {
    final db = await openDatabase(
      caminho,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE perfil (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            nascimento TEXT NOT NULL,
            sexo INTEGER NOT NULL,
            peso_kg REAL NOT NULL,
            altura_cm REAL NOT NULL,
            cintura_cm REAL NOT NULL,
            familiar INTEGER NOT NULL,
            pressao_alta INTEGER NOT NULL,
            diagnostico_informado INTEGER NOT NULL,
            escolaridade_ord INTEGER,
            hdl REAL,
            inseguranca_alimentar INTEGER,
            termo_aceito INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE questionario (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data TEXT NOT NULL,
            faixa TEXT NOT NULL,
            probabilidade REAL,
            pontos INTEGER,
            fatores TEXT NOT NULL,
            respostas TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE medicamento (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            dose TEXT NOT NULL,
            horarios TEXT NOT NULL,
            dias_semana TEXT NOT NULL,
            ativo INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE dose (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            medicamento_id INTEGER NOT NULL,
            data TEXT NOT NULL,
            tomada INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE consulta (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            quando TEXT NOT NULL,
            profissional TEXT NOT NULL,
            especialidade TEXT NOT NULL,
            local TEXT NOT NULL,
            situacao TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE exame (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tipo TEXT NOT NULL,
            valor REAL NOT NULL,
            unidade TEXT NOT NULL,
            data TEXT NOT NULL
          )
        ''');
      },
    );
    return Banco(db, agenda);
  }

  Future<void> apagarTudo() async {
    await _db.delete('dose');
    await _db.delete('medicamento');
    await _db.delete('consulta');
    await _db.delete('exame');
    await _db.delete('questionario');
    await _db.delete('perfil');
    await agenda.cancelarTodos();
  }
}

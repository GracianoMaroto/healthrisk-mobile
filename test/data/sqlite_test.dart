import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:healthrisk_mobile/data/agenda.dart';
import 'package:healthrisk_mobile/data/banco.dart';
import 'package:healthrisk_mobile/data/modelos.dart';
import 'package:healthrisk_mobile/data/repositorios_sqlite.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('SQLite persiste perfil, questionário, remédio, consulta e exame', () async {
    final dir = await Directory.systemTemp.createTemp('hr_sqlite_');
    addTearDown(() async {
      try {
        await dir.delete(recursive: true);
      } catch (_) {}
    });
    final agenda = AgendaMemoria();
    final banco = await Banco.abrir(caminho: p.join(dir.path, 't.db'), agenda: agenda);
    final repos = repositoriosSqlite(banco);

    await repos.perfil.salvar(Perfil(
      nascimento: DateTime(1968, 1, 15),
      sexo: 1,
      pesoKg: 96,
      alturaCm: 170,
      cinturaCm: 112,
      familiarPrimeiroGrau: true,
      pressaoAlta: true,
      diagnosticoInformado: false,
    ));
    expect((await repos.perfil.obter())!.pesoKg, 96);

    await repos.questionario.salvar(Avaliacao(
      data: DateTime(2026, 11, 15),
      faixa: 'alto',
      fatores: const ['cintura'],
      respostasJson: '{}',
      probabilidade: 0.8,
    ));
    expect((await repos.questionario.ultima())!.faixa, 'alto');

    final medId = await repos.medicamento.salvar(const Medicamento(
      nome: 'Metformina',
      dose: '500 mg',
      horarios: ['08:00'],
      diasSemana: [1, 2, 3, 4, 5, 6, 7],
    ));
    await repos.medicamento.marcarTomada(medicamentoId: medId, data: '2026-11-15');
    expect(await repos.medicamento.tomada(medicamentoId: medId, data: '2026-11-15'), isTrue);

    await repos.consulta.salvar(Consulta(
      quando: DateTime(2026, 11, 16, 14),
      profissional: 'Dra. Ana',
      especialidade: 'Clínico',
      local: 'UBS',
    ));
    expect(agenda.registrados.where((a) => a.canal == 'consultas').length, 2);

    final exameId = await repos.exame.salvar(Exame(
      tipo: 'glicemia_jejum',
      valor: 200,
      unidade: 'mg/dL',
      data: DateTime(2026, 11, 15),
    ));
    expect((await repos.exame.listar()).first.valor, 200);
    await repos.exame.salvar(Exame(
      id: exameId,
      tipo: 'glicemia_jejum',
      valor: 110,
      unidade: 'mg/dL',
      data: DateTime(2026, 11, 15),
    ));
    expect((await repos.exame.listar()).single.valor, 110);
    await repos.exame.excluir(exameId);
    expect(await repos.exame.listar(), isEmpty);

    final consultaId = await repos.consulta.salvar(Consulta(
      quando: DateTime(2026, 11, 10, 9),
      profissional: 'Dr. Paulo',
      especialidade: 'Cardiologia',
      local: 'UBS Centro',
    ));
    expect((await repos.consulta.listar()).where((c) => c.id == consultaId).single.situacao, 'agendada');
    await repos.consulta.salvar(Consulta(
      id: consultaId,
      quando: DateTime(2026, 11, 10, 9),
      profissional: 'Dr. Paulo',
      especialidade: 'Cardiologia',
      local: 'UBS Centro',
      situacao: 'realizada',
    ));
    expect((await repos.consulta.listar()).where((c) => c.id == consultaId).single.situacao, 'realizada');
    await repos.consulta.excluir(consultaId);
    expect((await repos.consulta.listar()).where((c) => c.id == consultaId), isEmpty);

    await repos.medicamento.salvar(Medicamento(
      id: medId,
      nome: 'Enalapril',
      dose: '10 mg',
      horarios: const ['08:00'],
      diasSemana: const [1, 2, 3, 4, 5, 6, 7],
    ));
    expect((await repos.medicamento.listar()).single.nome, 'Enalapril');
    await repos.medicamento.excluir(medId);
    expect(await repos.medicamento.listar(), isEmpty);

    await repos.apagarTudo();
    expect(await repos.perfil.obter(), isNull);
    expect(await repos.medicamento.listar(), isEmpty);
    expect(agenda.cancelarTodosChamadas, 1);
  });
}

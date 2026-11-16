import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:healthrisk_mobile/data/agenda.dart';
import 'package:healthrisk_mobile/data/modelos.dart';
import 'package:healthrisk_mobile/data/repositorios_memoria.dart';

import '../helpers/harness.dart';

void main() {
  test('CRUD das seis tabelas, IMC/RCE e altura 0 recusada', () async {
    final h = await montarHarness();
    addTearDown(h.fechar);

    expect(
      () => Perfil(
        nascimento: DateTime(1968, 1, 15),
        sexo: 1,
        pesoKg: 96,
        alturaCm: 0,
        cinturaCm: 112,
        familiarPrimeiroGrau: true,
        pressaoAlta: true,
        diagnosticoInformado: false,
      ).imc,
      throwsArgumentError,
    );

    final perfil = Perfil(
      nascimento: DateTime(1968, 1, 15),
      sexo: 1,
      pesoKg: 96,
      alturaCm: 170,
      cinturaCm: 112,
      familiarPrimeiroGrau: true,
      pressaoAlta: true,
      diagnosticoInformado: false,
    );
    expect(perfil.imc, closeTo(33.22, 0.02));
    expect(perfil.razaoCinturaEstatura, closeTo(0.659, 0.001));
    await h.deps.repos.perfil.salvar(perfil);
    expect((await h.deps.repos.perfil.obter())!.pesoKg, 96);

    await expectLater(
      h.deps.repos.perfil.salvar(Perfil(
        nascimento: DateTime(1968, 1, 15),
        sexo: 1,
        pesoKg: 96,
        alturaCm: 0,
        cinturaCm: 112,
        familiarPrimeiroGrau: true,
        pressaoAlta: true,
        diagnosticoInformado: false,
      )),
      throwsArgumentError,
    );

    await h.deps.repos.questionario.salvar(Avaliacao(
      data: DateTime(2026, 11, 15),
      faixa: 'alto',
      fatores: const ['cintura'],
      respostasJson: '{}',
      probabilidade: 0.8,
    ));
    expect((await h.deps.repos.questionario.ultima())!.faixa, 'alto');

    final medId = await h.deps.repos.medicamento.salvar(const Medicamento(
      nome: 'Metformina',
      dose: '500 mg',
      horarios: ['08:00'],
      diasSemana: [1, 2, 3, 4, 5, 6, 7],
    ));
    await h.deps.repos.medicamento.marcarTomada(medicamentoId: medId, data: '2026-11-15');
    expect(await h.deps.repos.medicamento.tomada(medicamentoId: medId, data: '2026-11-15'), isTrue);
    expect((await h.deps.repos.medicamento.dosesDoDia('2026-11-15')).length, 1);

    await h.deps.repos.consulta.salvar(Consulta(
      quando: DateTime(2026, 11, 16, 14),
      profissional: 'Dra. Ana',
      especialidade: 'Clínico',
      local: 'UBS',
    ));
    expect(h.agenda.registrados.where((a) => a.canal == 'consultas').length, 2);

    await h.deps.repos.exame.salvar(Exame(
      tipo: 'glicemia_jejum',
      valor: 200,
      unidade: 'mg/dL',
      data: DateTime(2026, 11, 15),
    ));
    expect((await h.deps.repos.exame.listar()).first.valor, 200);

    await h.deps.repos.medicamento.salvar(Medicamento(
      id: medId,
      nome: 'Enalapril',
      dose: '10 mg',
      horarios: const ['08:00'],
      diasSemana: const [1, 2, 3, 4, 5, 6, 7],
    ));
    expect((await h.deps.repos.medicamento.listar()).single.nome, 'Enalapril');
    await h.deps.repos.medicamento.excluir(medId);
    expect(await h.deps.repos.medicamento.listar(), isEmpty);

    final consultaId = await h.deps.repos.consulta.salvar(Consulta(
      quando: DateTime(2026, 11, 10, 9),
      profissional: 'Dr. Paulo',
      especialidade: 'Clínico',
      local: 'UBS',
    ));
    expect((await h.deps.repos.consulta.listar()).last.situacao, 'agendada');
    await h.deps.repos.consulta.salvar(Consulta(
      id: consultaId,
      quando: DateTime(2026, 11, 10, 9),
      profissional: 'Dr. Paulo',
      especialidade: 'Clínico',
      local: 'UBS',
      situacao: 'realizada',
    ));
    expect(
      (await h.deps.repos.consulta.listar()).any((c) => c.profissional == 'Dr. Paulo' && c.situacao == 'realizada'),
      isTrue,
    );
    await h.deps.repos.consulta.excluir(consultaId);
    expect(
      (await h.deps.repos.consulta.listar()).any((c) => c.id == consultaId),
      isFalse,
    );
  });

  test('apagar tudo zera tabelas e pede cancelamento de alarmes', () async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await h.deps.repos.perfil.salvar(Perfil(
      nascimento: DateTime(1968, 1, 15),
      sexo: 1,
      pesoKg: 96,
      alturaCm: 170,
      cinturaCm: 112,
      familiarPrimeiroGrau: true,
      pressaoAlta: true,
      diagnosticoInformado: false,
    ));
    await h.deps.repos.medicamento.salvar(const Medicamento(
      nome: 'Metformina',
      dose: '500 mg',
      horarios: ['08:00'],
      diasSemana: [1, 2, 3, 4, 5, 6, 7],
    ));
    await h.deps.repos.apagarTudo();
    expect(await h.deps.repos.perfil.obter(), isNull);
    expect(await h.deps.repos.medicamento.listar(), isEmpty);
    expect(h.agenda.cancelarTodosChamadas, 1);
  });

  test('dump/load reconstitui perfil e questionário', () async {
    final origem = RepositoriosMemoria(AgendaMemoria());
    await origem.repos.perfil.salvar(Perfil(
      nascimento: DateTime(1968, 1, 15),
      sexo: 1,
      pesoKg: 96,
      alturaCm: 170,
      cinturaCm: 112,
      familiarPrimeiroGrau: true,
      pressaoAlta: true,
      diagnosticoInformado: false,
    ));
    await origem.repos.questionario.salvar(Avaliacao(
      data: DateTime(2026, 11, 15),
      faixa: 'alto',
      fatores: const ['Cintura: medida alta em relação à altura aumenta a faixa.'],
      respostasJson: '{}',
      probabilidade: 0.8,
    ));
    final json = jsonEncode(origem.dump());
    final destino = RepositoriosMemoria(AgendaMemoria());
    destino.load(jsonDecode(json) as Map<String, dynamic>);
    expect((await destino.repos.perfil.obter())!.pesoKg, 96);
    expect((await destino.repos.questionario.ultima())!.faixa, 'alto');
  });
}

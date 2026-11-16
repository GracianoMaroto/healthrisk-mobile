import 'package:flutter/material.dart';
import 'package:healthrisk_mobile/app/copy.dart';
import 'package:healthrisk_mobile/app/sessao.dart';
import 'package:healthrisk_mobile/app/tema.dart';
import 'package:healthrisk_mobile/data/agenda.dart';
import 'package:healthrisk_mobile/data/modelos.dart';
import 'package:healthrisk_mobile/data/repositorios.dart';
import 'package:healthrisk_mobile/ui/mascaras.dart';
import 'package:healthrisk_mobile/ui/widgets.dart';

class MedicamentosPage extends StatefulWidget {
  const MedicamentosPage({super.key, required this.sessao});

  final Sessao sessao;

  @override
  State<MedicamentosPage> createState() => _MedicamentosPageState();
}

class _MedicamentosPageState extends State<MedicamentosPage> {
  final nome = TextEditingController();
  final dose = TextEditingController();
  final horario = TextEditingController(text: '08:00');
  List<Medicamento> lista = [];
  int? editandoId;
  bool salvando = false;
  int? ocupadoId;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    nome.dispose();
    dose.dispose();
    horario.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    final meds = await widget.sessao.deps.repos.medicamento.listar();
    if (mounted) setState(() => lista = meds);
  }

  void _editar(Medicamento m) {
    setState(() {
      editandoId = m.id;
      nome.text = m.nome;
      dose.text = m.dose;
      horario.text = m.horarios.isEmpty ? '08:00' : m.horarios.first;
    });
  }

  void _limparFormulario() {
    editandoId = null;
    nome.clear();
    dose.clear();
  }

  Future<void> _excluir(Medicamento m) async {
    if (m.id == null || ocupadoId != null) return;
    setState(() => ocupadoId = m.id);
    try {
      await widget.sessao.deps.repos.medicamento.excluir(m.id!);
      await tentarCancelar(widget.sessao.deps.agenda, 1000 + m.id!);
      if (editandoId == m.id) _limparFormulario();
      if (!mounted) return;
      mostrarStatus(context, Copy.medicamentoExcluido);
      await _carregar();
    } finally {
      if (mounted) setState(() => ocupadoId = null);
    }
  }

  Future<void> _salvar() async {
    if (salvando) return;
    if (nome.text.trim().isEmpty) {
      mostrarStatus(context, 'Informe o nome.', erro: true);
      return;
    }
    setState(() => salvando = true);
    try {
      final agora = widget.sessao.deps.relogio.agora();
      final horaTexto = horario.text.trim().isEmpty ? '08:00' : horario.text.trim();
      final salvo = Medicamento(
        id: editandoId,
        nome: nome.text.trim(),
        dose: dose.text.trim().isEmpty ? '1 comprimido' : dose.text.trim(),
        horarios: [horaTexto],
        diasSemana: const [1, 2, 3, 4, 5, 6, 7],
      );
      final id = await widget.sessao.deps.repos.medicamento.salvar(salvo);
      await tentarCancelar(widget.sessao.deps.agenda, 1000 + id);
      await tentarAgendar(
        widget.sessao.deps.agenda,
        id: 1000 + id,
        quando: proximaOcorrencia(agora, horaTexto),
        canal: 'medicamentos',
        texto: '${salvo.nome} ${salvo.dose}',
      );
      if (!mounted) return;
      _limparFormulario();
      mostrarStatus(context, Copy.medicamentoSalvo);
      await _carregar();
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicamentos'),
        leading: IconButton(key: const Key('btn_voltar'), onPressed: () => widget.sessao.ir(TelaApp.home), icon: const Icon(Icons.arrow_back)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CampoGrande(
                key: const Key('campo_med_nome'),
                rotulo: 'Nome',
                controller: nome,
                obrigatorio: true,
              ),
              const SizedBox(height: 12),
              CampoGrande(key: const Key('campo_med_dose'), rotulo: 'Dose', controller: dose),
              const SizedBox(height: 12),
              CampoGrande(
                key: const Key('campo_med_horario'),
                rotulo: 'Horário',
                controller: horario,
                hint: '08:00',
                teclado: TextInputType.number,
                formatters: const [MascaraHora()],
              ),
              const SizedBox(height: 12),
              BotaoGrande(
                key: const Key('btn_salvar_med'),
                texto: editandoId == null ? 'Salvar medicamento' : 'Salvar alterações',
                carregando: salvando,
                onPressed: _salvar,
              ),
              if (editandoId != null) ...[
                const SizedBox(height: 12),
                BotaoGrande(
                  key: const Key('btn_cancelar_edicao_med'),
                  texto: Copy.cancelar,
                  preenchido: false,
                  onPressed: () => setState(_limparFormulario),
                ),
              ],
              const SizedBox(height: 16),
              ListaEmpilhada(
                itens: [
                  for (final m in lista)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('${m.nome} ${m.dose}', style: const TextStyle(fontSize: TemaSaude.fonteMinima)),
                            Text(m.horarios.join(', '), style: const TextStyle(fontSize: TemaSaude.fonteMinima)),
                            const SizedBox(height: 8),
                            BotaoGrande(
                              key: Key('btn_editar_med_${m.id}'),
                              texto: 'Editar',
                              preenchido: false,
                              onPressed: () => _editar(m),
                            ),
                            const SizedBox(height: 8),
                            BotaoGrande(
                              key: Key('btn_excluir_med_${m.id}'),
                              texto: 'Excluir',
                              preenchido: false,
                              carregando: ocupadoId == m.id,
                              onPressed: () => _excluir(m),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

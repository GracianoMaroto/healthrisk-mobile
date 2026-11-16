import 'package:flutter/material.dart';
import 'package:healthrisk_mobile/app/copy.dart';
import 'package:healthrisk_mobile/app/datas.dart';
import 'package:healthrisk_mobile/app/sessao.dart';
import 'package:healthrisk_mobile/app/tema.dart';
import 'package:healthrisk_mobile/data/modelos.dart';
import 'package:healthrisk_mobile/ui/mascaras.dart';
import 'package:healthrisk_mobile/ui/widgets.dart';
import 'package:intl/intl.dart';

bool consultaProxima(Consulta c, DateTime agora) =>
    c.situacao == 'agendada' && c.quando.isAfter(agora);

bool consultaPassada(Consulta c, DateTime agora) => !consultaProxima(c, agora);

bool bateConsulta(Consulta c, String busca) {
  final q = busca.trim().toLowerCase();
  if (q.isEmpty) return true;
  final data = DateFormat('dd/MM/yyyy HH:mm').format(c.quando);
  return [c.profissional, c.especialidade, c.local, c.situacao, data]
      .any((campo) => campo.toLowerCase().contains(q));
}

class ConsultasPage extends StatefulWidget {
  const ConsultasPage({super.key, required this.sessao});

  final Sessao sessao;

  @override
  State<ConsultasPage> createState() => _ConsultasPageState();
}

class _ConsultasPageState extends State<ConsultasPage> {
  final quando = TextEditingController();
  final profissional = TextEditingController();
  final especialidade = TextEditingController();
  final local = TextEditingController();
  List<Consulta> lista = [];
  String? erro;
  int? editandoId;
  bool salvando = false;
  int? ocupadoId;

  @override
  void initState() {
    super.initState();
    final extra = widget.sessao.consultaEmEdicao;
    if (extra != null) {
      widget.sessao.consultaEmEdicao = null;
      _preencher(extra);
    }
    _carregar();
  }

  @override
  void dispose() {
    quando.dispose();
    profissional.dispose();
    especialidade.dispose();
    local.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    final itens = await widget.sessao.deps.repos.consulta.listar();
    if (mounted) setState(() => lista = itens);
  }

  void _preencher(Consulta c) {
    editandoId = c.id;
    quando.text = DateFormat('dd/MM/yyyy HH:mm').format(c.quando);
    profissional.text = c.profissional;
    especialidade.text = c.especialidade;
    local.text = c.local;
  }

  void _limparFormulario() {
    editandoId = null;
    quando.clear();
    profissional.clear();
    especialidade.clear();
    local.clear();
  }

  void _editar(Consulta c) {
    setState(() => _preencher(c));
  }

  Future<void> _salvar() async {
    if (salvando) return;
    final data = parseQuandoConsulta(quando.text);
    if (data == null) {
      setState(() => erro = 'Use dd/mm/aaaa ou dd/mm/aaaa HH:mm. Consulta passada também vale.');
      return;
    }
    setState(() {
      salvando = true;
      erro = null;
    });
    try {
      Consulta? atual;
      if (editandoId != null) {
        for (final c in lista) {
          if (c.id == editandoId) atual = c;
        }
      }
      await widget.sessao.deps.repos.consulta.salvar(Consulta(
        id: editandoId,
        quando: data,
        profissional: profissional.text.trim().isEmpty ? 'Profissional' : profissional.text.trim(),
        especialidade: especialidade.text.trim().isEmpty ? 'Clínico' : especialidade.text.trim(),
        local: local.text.trim().isEmpty ? 'UBS' : local.text.trim(),
        situacao: atual?.situacao ?? 'agendada',
      ));
      if (!mounted) return;
      _limparFormulario();
      mostrarStatus(context, Copy.consultaSalva);
      await _carregar();
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  Future<void> _marcarRealizada(Consulta c) async {
    if (c.id == null || ocupadoId != null) return;
    setState(() => ocupadoId = c.id);
    try {
      await widget.sessao.deps.repos.consulta.salvar(c.copyWith(situacao: 'realizada'));
      if (!mounted) return;
      mostrarStatus(context, Copy.consultaRealizada);
      await _carregar();
    } finally {
      if (mounted) setState(() => ocupadoId = null);
    }
  }

  Future<void> _excluir(Consulta c) async {
    if (c.id == null || ocupadoId != null) return;
    setState(() => ocupadoId = c.id);
    try {
      await widget.sessao.deps.repos.consulta.excluir(c.id!);
      if (editandoId == c.id) _limparFormulario();
      if (!mounted) return;
      mostrarStatus(context, Copy.consultaExcluida);
      await _carregar();
    } finally {
      if (mounted) setState(() => ocupadoId = null);
    }
  }

  List<Consulta> get _proximas {
    final agora = widget.sessao.deps.relogio.agora();
    return lista.where((c) => consultaProxima(c, agora)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final agora = widget.sessao.deps.relogio.agora();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultas'),
        leading: IconButton(key: const Key('btn_voltar'), onPressed: () => widget.sessao.ir(TelaApp.home), icon: const Icon(Icons.arrow_back)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            CampoGrande(
              key: const Key('campo_consulta_quando'),
              rotulo: 'Quando (dd/mm/aaaa HH:mm)',
              controller: quando,
              hint: '16/11/2026 14:00',
              teclado: TextInputType.number,
              obrigatorio: true,
              formatters: const [MascaraDataHora()],
            ),
            const SizedBox(height: 12),
            CampoGrande(key: const Key('campo_consulta_profissional'), rotulo: 'Profissional', controller: profissional),
            const SizedBox(height: 12),
            CampoGrande(key: const Key('campo_consulta_especialidade'), rotulo: 'Especialidade', controller: especialidade),
            const SizedBox(height: 12),
            CampoGrande(key: const Key('campo_consulta_local'), rotulo: 'Local', controller: local),
            const SizedBox(height: 12),
            BotaoGrande(
              key: const Key('btn_salvar_consulta'),
              texto: editandoId == null ? 'Salvar consulta' : 'Salvar alterações',
              carregando: salvando,
              onPressed: _salvar,
            ),
            if (editandoId != null) ...[
              const SizedBox(height: 12),
              BotaoGrande(
                key: const Key('btn_cancelar_edicao_consulta'),
                texto: Copy.cancelar,
                preenchido: false,
                onPressed: () => setState(_limparFormulario),
              ),
            ],
            if (erro != null) ...[
              const SizedBox(height: 12),
              Text(erro!, key: const Key('txt_erro_consulta'), style: const TextStyle(color: Color(0xFFB91C1C), fontSize: TemaSaude.fonteMinima)),
            ],
            const SizedBox(height: 12),
            BotaoGrande(
              key: const Key('btn_historico_consulta'),
              texto: Copy.historico,
              preenchido: false,
              onPressed: () => widget.sessao.ir(TelaApp.consultasHistorico),
            ),
            const SizedBox(height: 16),
            if (_proximas.isEmpty)
              const Text(Copy.nenhumRegistro, style: TextStyle(fontSize: TemaSaude.fonteMinima))
            else
              for (final c in _proximas)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CartaoConsulta(
                    consulta: c,
                    agora: agora,
                    ocupadoId: ocupadoId,
                    onRealizada: () => _marcarRealizada(c),
                    onEditar: () => _editar(c),
                    onExcluir: () => _excluir(c),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartaoConsulta extends StatelessWidget {
  const CartaoConsulta({
    super.key,
    required this.consulta,
    required this.agora,
    required this.ocupadoId,
    required this.onRealizada,
    required this.onEditar,
    required this.onExcluir,
  });

  final Consulta consulta;
  final DateTime agora;
  final int? ocupadoId;
  final VoidCallback onRealizada;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final c = consulta;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(c.profissional, style: const TextStyle(fontSize: TemaSaude.fonteMinima)),
            Text(
              '${DateFormat('dd/MM/yyyy HH:mm').format(c.quando)} · ${c.especialidade} · ${c.local} · ${c.situacao}',
              style: const TextStyle(fontSize: TemaSaude.fonteMinima),
            ),
            if (c.situacao == 'agendada' && !c.quando.isAfter(agora)) ...[
              const SizedBox(height: 8),
              BotaoGrande(
                key: Key('btn_consulta_realizada_${c.id}'),
                texto: Copy.marcarRealizada,
                carregando: ocupadoId == c.id,
                onPressed: onRealizada,
              ),
            ],
            const SizedBox(height: 8),
            BotaoGrande(
              key: Key('btn_editar_consulta_${c.id}'),
              texto: 'Editar',
              preenchido: false,
              onPressed: onEditar,
            ),
            const SizedBox(height: 8),
            BotaoGrande(
              key: Key('btn_excluir_consulta_${c.id}'),
              texto: 'Excluir',
              preenchido: false,
              carregando: ocupadoId == c.id,
              onPressed: onExcluir,
            ),
          ],
        ),
      ),
    );
  }
}

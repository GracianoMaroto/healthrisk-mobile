import 'package:flutter/material.dart';
import 'package:healthrisk_mobile/app/copy.dart';
import 'package:healthrisk_mobile/app/sessao.dart';
import 'package:healthrisk_mobile/data/modelos.dart';
import 'package:healthrisk_mobile/ui/consultas_page.dart';
import 'package:healthrisk_mobile/ui/widgets.dart';

class ConsultasHistoricoPage extends StatefulWidget {
  const ConsultasHistoricoPage({super.key, required this.sessao});

  final Sessao sessao;

  @override
  State<ConsultasHistoricoPage> createState() => _ConsultasHistoricoPageState();
}

class _ConsultasHistoricoPageState extends State<ConsultasHistoricoPage> {
  final busca = TextEditingController();
  List<Consulta> lista = [];
  int? ocupadoId;

  @override
  void initState() {
    super.initState();
    busca.addListener(() => setState(() {}));
    _carregar();
  }

  @override
  void dispose() {
    busca.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    final itens = await widget.sessao.deps.repos.consulta.listar();
    if (mounted) setState(() => lista = itens);
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
      if (!mounted) return;
      mostrarStatus(context, Copy.consultaExcluida);
      await _carregar();
    } finally {
      if (mounted) setState(() => ocupadoId = null);
    }
  }

  List<Consulta> get _passadas {
    final agora = widget.sessao.deps.relogio.agora();
    return lista.where((c) => consultaPassada(c, agora) && bateConsulta(c, busca.text)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final agora = widget.sessao.deps.relogio.agora();
    return Scaffold(
      appBar: AppBar(
        title: const Text(Copy.historico),
        leading: IconButton(
          key: const Key('btn_voltar'),
          onPressed: () => widget.sessao.ir(TelaApp.consultas),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListaComBusca(
                controller: busca,
                campoKey: const Key('campo_busca_consulta'),
                hint: 'Profissional, local, especialidade',
                itens: [
                  for (final c in _passadas)
                    CartaoConsulta(
                      consulta: c,
                      agora: agora,
                      ocupadoId: ocupadoId,
                      onRealizada: () => _marcarRealizada(c),
                      onEditar: () => widget.sessao.irEditarConsulta(c),
                      onExcluir: () => _excluir(c),
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

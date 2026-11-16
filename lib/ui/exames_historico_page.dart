import 'package:flutter/material.dart';
import 'package:healthrisk_mobile/app/copy.dart';
import 'package:healthrisk_mobile/app/sessao.dart';
import 'package:healthrisk_mobile/data/modelos.dart';
import 'package:healthrisk_mobile/ui/exames_page.dart';
import 'package:healthrisk_mobile/ui/widgets.dart';
import 'package:intl/intl.dart';

class ExamesHistoricoPage extends StatefulWidget {
  const ExamesHistoricoPage({super.key, required this.sessao});

  final Sessao sessao;

  @override
  State<ExamesHistoricoPage> createState() => _ExamesHistoricoPageState();
}

class _ExamesHistoricoPageState extends State<ExamesHistoricoPage> {
  final busca = TextEditingController();
  List<Exame> lista = [];
  int? ocupadoId;

  String get _tipo => widget.sessao.tipoExameHistorico;

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
    final itens = await widget.sessao.deps.repos.exame.listar();
    if (mounted) setState(() => lista = itens);
  }

  Future<void> _excluir(Exame e) async {
    if (e.id == null || ocupadoId != null) return;
    setState(() => ocupadoId = e.id);
    try {
      await widget.sessao.deps.repos.exame.excluir(e.id!);
      if (!mounted) return;
      mostrarStatus(context, Copy.exameExcluido);
      await _carregar();
    } finally {
      if (mounted) setState(() => ocupadoId = null);
    }
  }

  List<Exame> get _filtrados {
    final q = busca.text.trim().toLowerCase();
    return lista.where((e) {
      if (e.tipo != _tipo) return false;
      if (q.isEmpty) return true;
      final rotulo = Copy.rotuloTipoExame(e.tipo);
      final dia = DateFormat('dd/MM/yyyy').format(e.data);
      return [rotulo, formatarValorExame(e.valor), e.unidade, dia].any((c) => c.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${Copy.historico} · ${Copy.rotuloTipoExame(_tipo)}'),
        leading: IconButton(
          key: const Key('btn_voltar'),
          onPressed: () => widget.sessao.ir(TelaApp.exames),
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
                campoKey: const Key('campo_busca_exame'),
                hint: 'Valor ou data',
                itens: [
                  for (final e in _filtrados)
                    CartaoExame(
                      exame: e,
                      ocupadoId: ocupadoId,
                      onEditar: () => widget.sessao.irEditarExame(e),
                      onExcluir: () => _excluir(e),
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

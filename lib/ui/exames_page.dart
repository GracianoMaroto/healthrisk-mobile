import 'package:flutter/material.dart';
import 'package:healthrisk_mobile/app/copy.dart';
import 'package:healthrisk_mobile/app/sessao.dart';
import 'package:healthrisk_mobile/app/tema.dart';
import 'package:healthrisk_mobile/data/modelos.dart';
import 'package:healthrisk_mobile/ui/mascaras.dart';
import 'package:healthrisk_mobile/ui/widgets.dart';
import 'package:intl/intl.dart';

String formatarValorExame(double v) {
  if (v == v.roundToDouble()) return v.toInt().toString();
  return v.toString().replaceAll('.', ',');
}

class ExamesPage extends StatefulWidget {
  const ExamesPage({super.key, required this.sessao});

  final Sessao sessao;

  @override
  State<ExamesPage> createState() => _ExamesPageState();
}

class _ExamesPageState extends State<ExamesPage> {
  String tipo = 'glicemia_jejum';
  final valor = TextEditingController();
  final data = TextEditingController();
  List<Exame> lista = [];
  int? editandoId;
  bool salvando = false;
  int? ocupadoId;

  @override
  void initState() {
    super.initState();
    final extra = widget.sessao.exameEmEdicao;
    if (extra != null) {
      widget.sessao.exameEmEdicao = null;
      _preencher(extra);
    }
    _carregar();
  }

  @override
  void dispose() {
    valor.dispose();
    data.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    final itens = await widget.sessao.deps.repos.exame.listar();
    if (mounted) setState(() => lista = itens);
  }

  void _preencher(Exame e) {
    editandoId = e.id;
    tipo = e.tipo;
    valor.text = formatarValorExame(e.valor);
    data.text = DateFormat('dd/MM/yyyy').format(e.data);
  }

  void _limparFormulario() {
    editandoId = null;
    valor.clear();
  }

  void _editar(Exame e) {
    setState(() => _preencher(e));
  }

  Future<void> _salvar() async {
    if (salvando) return;
    final v = double.tryParse(valor.text.replaceAll(',', '.'));
    if (v == null) {
      mostrarStatus(context, 'Informe o valor.', erro: true);
      return;
    }
    DateTime dia;
    try {
      dia = DateFormat('dd/MM/yyyy').parseStrict(data.text.trim());
    } catch (_) {
      dia = widget.sessao.deps.relogio.agora();
    }
    setState(() => salvando = true);
    try {
      await widget.sessao.deps.repos.exame.salvar(Exame(
        id: editandoId,
        tipo: tipo,
        valor: v,
        unidade: tipo == 'hba1c' ? '%' : 'mg/dL',
        data: dia,
      ));
      if (!mounted) return;
      _limparFormulario();
      mostrarStatus(context, Copy.exameSalvo);
      await _carregar();
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  Future<void> _excluir(Exame e) async {
    if (e.id == null || ocupadoId != null) return;
    setState(() => ocupadoId = e.id);
    try {
      await widget.sessao.deps.repos.exame.excluir(e.id!);
      if (editandoId == e.id) _limparFormulario();
      if (!mounted) return;
      mostrarStatus(context, Copy.exameExcluido);
      await _carregar();
    } finally {
      if (mounted) setState(() => ocupadoId = null);
    }
  }

  Exame? _recente(String tipoExame) {
    for (final e in lista) {
      if (e.tipo == tipoExame) return e;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final glicemia = _recente('glicemia_jejum');
    final hba1c = _recente('hba1c');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exames'),
        leading: IconButton(key: const Key('btn_voltar'), onPressed: () => widget.sessao.ir(TelaApp.home), icon: const Icon(Icons.arrow_back)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            const Text(
              'O valor fica só no histórico. A pontuação de risco não lê esta tabela.',
              style: TextStyle(fontSize: TemaSaude.fonteMinima),
            ),
            const SizedBox(height: 12),
            BotaoGrande(
              key: const Key('btn_tipo_glicemia'),
              texto: Copy.glicemiaEmJejum,
              preenchido: tipo == 'glicemia_jejum',
              onPressed: () => setState(() => tipo = 'glicemia_jejum'),
            ),
            const SizedBox(height: 8),
            BotaoGrande(
              key: const Key('btn_tipo_hba1c'),
              texto: 'HbA1c',
              preenchido: tipo == 'hba1c',
              onPressed: () => setState(() => tipo = 'hba1c'),
            ),
            const SizedBox(height: 12),
            CampoGrande(
              key: const Key('campo_exame_valor'),
              rotulo: tipo == 'hba1c' ? 'Valor (%)' : 'Valor (mg/dL)',
              controller: valor,
              teclado: const TextInputType.numberWithOptions(decimal: true),
              obrigatorio: true,
              formatters: const [MascaraDecimal()],
            ),
            const SizedBox(height: 8),
            Text(
              tipo == 'hba1c' ? Copy.exameHba1cAjuda : Copy.exameGlicemiaAjuda,
              key: const Key('txt_exame_valor_ajuda'),
              style: const TextStyle(fontSize: TemaSaude.fonteMinima, height: 1.3),
            ),
            const SizedBox(height: 12),
            CampoGrande(
              key: const Key('campo_exame_data'),
              rotulo: 'Data (dd/mm/aaaa)',
              controller: data,
              teclado: TextInputType.number,
              opcional: true,
              hint: '15/11/2026',
              formatters: const [MascaraData()],
            ),
            const SizedBox(height: 12),
            BotaoGrande(
              key: const Key('btn_salvar_exame'),
              texto: editandoId == null ? 'Salvar exame' : 'Salvar alterações',
              carregando: salvando,
              onPressed: _salvar,
            ),
            if (editandoId != null) ...[
              const SizedBox(height: 12),
              BotaoGrande(
                key: const Key('btn_cancelar_edicao_exame'),
                texto: Copy.cancelar,
                preenchido: false,
                onPressed: () => setState(_limparFormulario),
              ),
            ],
            const SizedBox(height: 12),
            BotaoGrande(
              key: const Key('btn_historico_exame'),
              texto: Copy.historico,
              preenchido: false,
              onPressed: () => widget.sessao.irHistoricoExames(tipo),
            ),
            const SizedBox(height: 16),
            if (glicemia == null && hba1c == null)
              const Text(Copy.nenhumRegistro, style: TextStyle(fontSize: TemaSaude.fonteMinima)),
            if (glicemia != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CartaoExame(
                  exame: glicemia,
                  ocupadoId: ocupadoId,
                  onEditar: () => _editar(glicemia),
                  onExcluir: () => _excluir(glicemia),
                ),
              ),
            if (hba1c != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CartaoExame(
                  exame: hba1c,
                  ocupadoId: ocupadoId,
                  onEditar: () => _editar(hba1c),
                  onExcluir: () => _excluir(hba1c),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartaoExame extends StatelessWidget {
  const CartaoExame({
    super.key,
    required this.exame,
    required this.ocupadoId,
    required this.onEditar,
    required this.onExcluir,
  });

  final Exame exame;
  final int? ocupadoId;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final e = exame;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${Copy.rotuloTipoExame(e.tipo)} ${formatarValorExame(e.valor)} ${e.unidade}',
              style: const TextStyle(fontSize: TemaSaude.fonteMinima),
            ),
            Text(DateFormat('dd/MM/yyyy').format(e.data), style: const TextStyle(fontSize: TemaSaude.fonteMinima)),
            const SizedBox(height: 8),
            BotaoGrande(
              key: Key('btn_editar_exame_${e.id}'),
              texto: 'Editar',
              preenchido: false,
              onPressed: onEditar,
            ),
            const SizedBox(height: 8),
            BotaoGrande(
              key: Key('btn_excluir_exame_${e.id}'),
              texto: 'Excluir',
              preenchido: false,
              carregando: ocupadoId == e.id,
              onPressed: onExcluir,
            ),
          ],
        ),
      ),
    );
  }
}

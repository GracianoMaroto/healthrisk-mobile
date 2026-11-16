import 'package:flutter/material.dart';
import 'package:healthrisk_mobile/app/copy.dart';
import 'package:healthrisk_mobile/app/sessao.dart';
import 'package:healthrisk_mobile/app/tema.dart';
import 'package:healthrisk_mobile/data/modelos.dart';
import 'package:healthrisk_mobile/ui/widgets.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.sessao});

  final Sessao sessao;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Perfil? perfil;
  Consulta? proxima;
  List<Medicamento> medicamentos = [];
  final Set<int> tomadas = {};

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final p = await widget.sessao.deps.repos.perfil.obter();
    final agora = widget.sessao.deps.relogio.agora();
    final meds = await widget.sessao.deps.repos.medicamento.listar();
    final dia = DateFormat('yyyy-MM-dd').format(agora);
    final idsTomados = <int>{};
    for (final m in meds) {
      if (m.id != null && await widget.sessao.deps.repos.medicamento.tomada(medicamentoId: m.id!, data: dia)) {
        idsTomados.add(m.id!);
      }
    }
    final consulta = await widget.sessao.deps.repos.consulta.proxima(agora);
    setState(() {
      perfil = p;
      medicamentos = meds.where((m) => m.ativo && m.diasSemana.contains(agora.weekday)).toList();
      tomadas
        ..clear()
        ..addAll(idsTomados);
      proxima = consulta;
    });
  }

  String _rotuloFaixa() {
    return switch (widget.sessao.ultimoResultado?.faixa) {
      'alto' => Copy.faixaAlto,
      'moderado' => Copy.faixaModerado,
      'baixo' => Copy.faixaBaixo,
      _ => 'Sem avaliação',
    };
  }

  Widget _blocoFaixa() {
    return Card(
      key: const Key('bloco_faixa'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Última faixa', textAlign: TextAlign.center, style: TextStyle(fontSize: TemaSaude.fonteMinima)),
            const SizedBox(height: 8),
            BlocoProbabilidade(
              faixa: _rotuloFaixa(),
              probabilidade: widget.sessao.ultimoResultado?.probabilidade,
              faixaGrande: false,
              faixaKey: const Key('txt_faixa_home'),
              probKey: const Key('txt_probabilidade_home'),
              decKey: const Key('txt_probabilidade_dec_home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blocoRotina() {
    return Column(
      key: const Key('bloco_rotina'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Doses de hoje', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        if (medicamentos.isEmpty)
          const Text('Nenhum medicamento para hoje.', style: TextStyle(fontSize: TemaSaude.fonteMinima)),
        ...medicamentos.map((m) {
          final tomada = tomadas.contains(m.id);
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('${m.nome} ${m.dose}', style: const TextStyle(fontSize: TemaSaude.fonteMinima)),
                  Text(m.horarios.join(', '), style: const TextStyle(fontSize: TemaSaude.fonteMinima)),
                  const SizedBox(height: 8),
                  FilledButton(
                    key: Key('btn_tomei_${m.id}'),
                    onPressed: tomada
                        ? null
                        : () async {
                            final dia = DateFormat('yyyy-MM-dd').format(widget.sessao.deps.relogio.agora());
                            await widget.sessao.deps.repos.medicamento.marcarTomada(medicamentoId: m.id!, data: dia);
                            if (mounted) mostrarStatus(context, Copy.doseRegistrada);
                            await _carregar();
                          },
                    child: Text(tomada ? 'Ok' : Copy.tomei),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text('Próxima consulta', style: TextStyle(fontSize: TemaSaude.fonteMinima)),
            subtitle: Text(
              proxima == null
                  ? 'Nenhuma consulta agendada'
                  : '${proxima!.profissional} — ${DateFormat('dd/MM/yyyy HH:mm').format(proxima!.quando)}',
              key: const Key('txt_proxima_consulta'),
              style: const TextStyle(fontSize: TemaSaude.fonteMinima),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final diagnostico = widget.sessao.perfil?.diagnosticoInformado ?? perfil?.diagnosticoInformado ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text(Copy.appNome)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            if (diagnostico) ...[_blocoRotina(), const SizedBox(height: 16), _blocoFaixa()]
            else ...[_blocoFaixa(), const SizedBox(height: 16), _blocoRotina()],
            const SizedBox(height: 20),
            BotaoGrande(key: const Key('btn_nav_medicamentos'), texto: 'Medicamentos', onPressed: () => widget.sessao.ir(TelaApp.medicamentos)),
            const SizedBox(height: 12),
            BotaoGrande(key: const Key('btn_nav_consultas'), texto: 'Consultas', onPressed: () => widget.sessao.ir(TelaApp.consultas)),
            const SizedBox(height: 12),
            BotaoGrande(key: const Key('btn_nav_exames'), texto: 'Exames', onPressed: () => widget.sessao.ir(TelaApp.exames)),
            const SizedBox(height: 12),
            BotaoGrande(key: const Key('btn_nav_questionario'), texto: 'Refazer questionário', preenchido: false, onPressed: () => widget.sessao.ir(TelaApp.questionario)),
            const SizedBox(height: 12),
            BotaoGrande(key: const Key('btn_nav_ajustes'), texto: 'Ajustes', preenchido: false, onPressed: () => widget.sessao.ir(TelaApp.ajustes)),
            ],
          ),
        ),
      ),
    );
  }
}

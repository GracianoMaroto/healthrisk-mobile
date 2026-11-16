import 'package:flutter/material.dart';
import 'package:healthrisk_mobile/app/copy.dart';
import 'package:healthrisk_mobile/app/sessao.dart';
import 'package:healthrisk_mobile/data/persistencia_web.dart';
import 'package:healthrisk_mobile/app/tema.dart';
import 'package:healthrisk_mobile/ui/mascaras.dart';
import 'package:healthrisk_mobile/ui/widgets.dart';

class AjustesPage extends StatefulWidget {
  const AjustesPage({super.key, required this.sessao});

  final Sessao sessao;

  @override
  State<AjustesPage> createState() => _AjustesPageState();
}

class _AjustesPageState extends State<AjustesPage> {
  final pin = TextEditingController();
  bool confirmar = false;
  bool pinAtivo = false;
  bool salvando = false;
  bool apagando = false;

  @override
  void initState() {
    super.initState();
    _carregarStatus();
  }

  @override
  void dispose() {
    pin.dispose();
    super.dispose();
  }

  Future<void> _carregarStatus() async {
    final tem = await widget.sessao.deps.cofre.temPin();
    if (mounted) setState(() => pinAtivo = tem);
  }

  Future<void> _salvarPin() async {
    if (salvando) return;
    if (pin.text.trim().length < 4) {
      mostrarStatus(context, Copy.pinCurto, erro: true);
      return;
    }
    setState(() => salvando = true);
    try {
      await widget.sessao.deps.cofre.salvar(pin.text.trim());
      if (!mounted) return;
      pin.clear();
      setState(() => pinAtivo = true);
      mostrarStatus(context, Copy.pinSalvo);
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  Future<void> _apagar() async {
    if (apagando) return;
    setState(() => apagando = true);
    try {
      await widget.sessao.deps.repos.apagarTudo();
      apagarEstadoWeb();
      await widget.sessao.deps.cofre.apagar();
      widget.sessao.ultimoResultado = null;
      widget.sessao.perfil = null;
      widget.sessao.desbloqueado = false;
      widget.sessao.ir(TelaApp.termo);
    } finally {
      if (mounted) setState(() => apagando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        leading: IconButton(key: const Key('btn_voltar'), onPressed: () => widget.sessao.ir(TelaApp.home), icon: const Icon(Icons.arrow_back)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(Copy.pinBeneficio, style: TextStyle(fontSize: TemaSaude.fonteMinima, height: 1.3)),
            const SizedBox(height: 12),
            if (pinAtivo)
              const Text(Copy.pinAtivo, key: Key('txt_pin_status'), style: TextStyle(fontSize: TemaSaude.fonteMinima, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            CampoGrande(
              key: const Key('campo_pin'),
              rotulo: 'PIN',
              controller: pin,
              teclado: TextInputType.number,
              opcional: true,
              obscure: true,
              formatters: const [MascaraDigitos()],
            ),
            const SizedBox(height: 12),
            BotaoGrande(
              key: const Key('btn_salvar_pin'),
              texto: 'Salvar PIN',
              carregando: salvando,
              onPressed: _salvarPin,
            ),
            const SizedBox(height: 28),
            if (!confirmar)
              BotaoGrande(
                key: const Key('btn_apagar_tudo'),
                texto: Copy.apagarTudo,
                onPressed: () => setState(() => confirmar = true),
              )
            else ...[
              const Text(Copy.confirmarApagar, style: TextStyle(fontSize: TemaSaude.fonteMinima)),
              const SizedBox(height: 12),
              BotaoGrande(
                key: const Key('btn_confirmar_apagar'),
                texto: Copy.confirmar,
                carregando: apagando,
                onPressed: _apagar,
              ),
              const SizedBox(height: 12),
              BotaoGrande(texto: Copy.cancelar, preenchido: false, onPressed: () => setState(() => confirmar = false)),
            ],
          ],
        ),
      ),
    );
  }
}

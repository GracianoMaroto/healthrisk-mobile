import 'package:flutter/material.dart';
import 'package:healthrisk_mobile/app/sessao.dart';
import 'package:healthrisk_mobile/app/tema.dart';
import 'package:healthrisk_mobile/ui/mascaras.dart';
import 'package:healthrisk_mobile/ui/widgets.dart';

class PinPage extends StatefulWidget {
  const PinPage({super.key, required this.sessao});

  final Sessao sessao;

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  final pin = TextEditingController();
  String? erro;
  bool entrando = false;

  @override
  void dispose() {
    pin.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (entrando) return;
    setState(() => entrando = true);
    try {
      final ok = await widget.sessao.deps.cofre.conferir(pin.text.trim());
      if (ok) {
        widget.sessao.desbloqueado = true;
        await widget.sessao.iniciar();
      } else if (mounted) {
        setState(() => erro = 'PIN incorreto');
      }
    } finally {
      if (mounted) setState(() => entrando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TelaPasso(
      titulo: 'Desbloquear',
      filho: Column(
        children: [
          const Text('Digite o PIN para abrir o HealthRisk.', style: TextStyle(fontSize: TemaSaude.fonteMinima)),
          const SizedBox(height: 16),
          CampoGrande(
            key: const Key('campo_pin_unlock'),
            rotulo: 'PIN',
            controller: pin,
            teclado: TextInputType.number,
            obscure: true,
            formatters: const [MascaraDigitos()],
          ),
          if (erro != null) Text(erro!, style: const TextStyle(color: Colors.red, fontSize: TemaSaude.fonteMinima)),
        ],
      ),
      acoes: [
        BotaoGrande(key: const Key('btn_unlock_pin'), texto: 'Entrar', carregando: entrando, onPressed: _entrar),
      ],
    );
  }
}

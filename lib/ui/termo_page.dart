import 'package:flutter/material.dart';
import 'package:healthrisk_mobile/app/copy.dart';
import 'package:healthrisk_mobile/app/sessao.dart';
import 'package:healthrisk_mobile/app/tema.dart';
import 'package:healthrisk_mobile/ui/widgets.dart';

class TermoPage extends StatelessWidget {
  const TermoPage({super.key, required this.sessao});

  final Sessao sessao;

  @override
  Widget build(BuildContext context) {
    return TelaPasso(
      titulo: Copy.termoTitulo,
      filho: const Text(
        Copy.termoCorpo,
        style: TextStyle(fontSize: TemaSaude.fonteMinima, height: 1.4),
      ),
      acoes: [
        BotaoGrande(
          key: const Key('btn_aceitar'),
          texto: Copy.aceitar,
          onPressed: () => sessao.ir(TelaApp.perfil),
        ),
        BotaoGrande(
          key: const Key('btn_nao_aceitar'),
          texto: Copy.naoAceitar,
          preenchido: false,
          onPressed: () {},
        ),
      ],
    );
  }
}

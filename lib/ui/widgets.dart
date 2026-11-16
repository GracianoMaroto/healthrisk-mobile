import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healthrisk_mobile/app/copy.dart';
import 'package:healthrisk_mobile/app/probabilidade.dart';
import 'package:healthrisk_mobile/app/tema.dart';

class TelaPasso extends StatelessWidget {
  const TelaPasso({
    super.key,
    required this.titulo,
    required this.filho,
    this.acoes = const [],
    this.onVoltar,
    this.passoAtual,
    this.totalPassos,
    this.rotuloPasso,
  });

  final String titulo;
  final Widget filho;
  final List<Widget> acoes;
  final VoidCallback? onVoltar;
  final int? passoAtual;
  final int? totalPassos;
  final String? rotuloPasso;

  @override
  Widget build(BuildContext context) {
    final temProgresso = passoAtual != null && totalPassos != null && totalPassos! > 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        automaticallyImplyLeading: false,
        leading: onVoltar == null
            ? null
            : IconButton(
                key: const Key('btn_voltar_passo'),
                onPressed: onVoltar,
                icon: const Icon(Icons.arrow_back),
              ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (temProgresso)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      rotuloPasso ?? 'Passo $passoAtual de $totalPassos',
                      key: const Key('txt_passo'),
                      style: const TextStyle(fontSize: TemaSaude.fonteMinima),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: passoAtual! / totalPassos!,
                        minHeight: 8,
                        color: TemaSaude.teal,
                        backgroundColor: TemaSaude.teal.withAlpha(46),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: filho,
                    ),
                  ),
                ],
              ),
            ),
            if (acoes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final w in acoes)
                      Padding(padding: const EdgeInsets.only(top: 12), child: w),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BotaoGrande extends StatelessWidget {
  const BotaoGrande({
    super.key,
    required this.texto,
    required this.onPressed,
    this.preenchido = true,
    this.carregando = false,
  });

  final String texto;
  final VoidCallback? onPressed;
  final bool preenchido;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    final on = carregando ? null : onPressed;
    final child = carregando
        ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: preenchido ? Colors.white : TemaSaude.teal,
            ),
          )
        : Text(texto, textAlign: TextAlign.center);
    final botao = preenchido
        ? FilledButton(onPressed: on, child: child)
        : OutlinedButton(onPressed: on, child: child);
    return SizedBox(width: double.infinity, child: botao);
  }
}

class CampoGrande extends StatelessWidget {
  const CampoGrande({
    super.key,
    required this.rotulo,
    required this.controller,
    this.teclado = TextInputType.text,
    this.hint,
    this.obrigatorio = false,
    this.opcional = false,
    this.formatters,
    this.obscure = false,
  });

  final String rotulo;
  final TextEditingController controller;
  final TextInputType teclado;
  final String? hint;
  final bool obrigatorio;
  final bool opcional;
  final List<TextInputFormatter>? formatters;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    const vermelho = Color(0xFFB91C1C);
    final hintTexto = obrigatorio
        ? (hint == null || hint!.isEmpty ? '*' : '$hint *')
        : hint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (opcional)
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text(
              Copy.opcional,
              key: Key('txt_indicador_campo'),
              style: TextStyle(fontSize: 14, height: 1.2, color: Color(0xFF4B5563)),
            ),
          ),
        TextField(
          controller: controller,
          keyboardType: teclado,
          inputFormatters: formatters,
          obscureText: obscure,
          style: const TextStyle(fontSize: TemaSaude.fonteMinima),
          decoration: InputDecoration(
            label: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: rotulo),
                  if (obrigatorio)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: vermelho, fontWeight: FontWeight.w700),
                    ),
                ],
              ),
            ),
            hintText: hintTexto,
            border: const OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}

void mostrarStatus(BuildContext context, String texto, {bool erro = false}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger?.hideCurrentSnackBar();
  messenger?.showSnackBar(
    SnackBar(
      content: Text(texto, style: const TextStyle(fontSize: TemaSaude.fonteMinima)),
      backgroundColor: erro ? const Color(0xFFB91C1C) : TemaSaude.teal,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

class ListaEmpilhada extends StatelessWidget {
  const ListaEmpilhada({super.key, required this.itens});

  final List<Widget> itens;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: itens.isEmpty
          ? const Text(Copy.nenhumRegistro, style: TextStyle(fontSize: TemaSaude.fonteMinima))
          : ListView(children: itens),
    );
  }
}

class ListaComBusca extends StatelessWidget {
  const ListaComBusca({
    super.key,
    required this.controller,
    required this.campoKey,
    required this.itens,
    this.hint = 'Buscar',
  });

  final TextEditingController controller;
  final Key campoKey;
  final List<Widget> itens;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CampoGrande(key: campoKey, rotulo: 'Buscar', controller: controller, hint: hint),
          const SizedBox(height: 12),
          Expanded(
            child: itens.isEmpty
                ? const Text(Copy.nenhumRegistro, style: TextStyle(fontSize: TemaSaude.fonteMinima))
                : ListView(children: itens),
          ),
        ],
      ),
    );
  }
}

class BlocoProbabilidade extends StatelessWidget {
  const BlocoProbabilidade({
    super.key,
    required this.faixa,
    this.probabilidade,
    this.faixaGrande = true,
    this.faixaKey = const Key('txt_faixa'),
    this.probKey = const Key('txt_probabilidade'),
    this.decKey = const Key('txt_probabilidade_dec'),
  });

  final String faixa;
  final double? probabilidade;
  final bool faixaGrande;
  final Key faixaKey;
  final Key probKey;
  final Key decKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          faixa,
          key: faixaKey,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: faixaGrande ? 42 : 22,
            fontWeight: FontWeight.bold,
            color: TemaSaude.teal,
          ),
        ),
        if (probabilidade != null) ...[
          const SizedBox(height: 4),
          Text(
            FormatoProbabilidade.porcentagem(probabilidade!),
            key: probKey,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: faixaGrande ? 32 : 26,
              fontWeight: FontWeight.w700,
              color: TemaSaude.teal,
            ),
          ),
          Text(
            FormatoProbabilidade.decimal(probabilidade!),
            key: decKey,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:healthrisk_mobile/app/copy.dart';
import 'package:healthrisk_mobile/app/idade.dart';
import 'package:healthrisk_mobile/app/sessao.dart';
import 'package:healthrisk_mobile/app/tema.dart';
import 'package:healthrisk_mobile/data/modelos.dart';
import 'package:healthrisk_mobile/domain/respostas.dart';
import 'package:healthrisk_mobile/domain/resultado.dart';
import 'package:healthrisk_mobile/ui/widgets.dart';

class ResultadoPage extends StatefulWidget {
  const ResultadoPage({super.key, required this.sessao});

  final Sessao sessao;

  @override
  State<ResultadoPage> createState() => _ResultadoPageState();
}

class _ResultadoPageState extends State<ResultadoPage> {
  Resultado? whatIf;
  bool simulando = false;

  String _rotulo(String faixa) {
    return switch (faixa) {
      'alto' => Copy.faixaAlto,
      'moderado' => Copy.faixaModerado,
      _ => Copy.faixaBaixo,
    };
  }

  Future<void> _simular() async {
    if (simulando) return;
    setState(() => simulando = true);
    try {
      final atual = widget.sessao.perfil ?? await widget.sessao.deps.repos.perfil.obter();
      if (atual == null || widget.sessao.ultimoResultado == null) return;
      final agora = widget.sessao.deps.relogio.agora();
      final respostas = Respostas(
        idadeAnos: idadeEmAnos(atual.nascimento, agora),
        sexo: atual.sexo,
        pesoKg: atual.pesoKg,
        alturaCm: atual.alturaCm,
        cinturaCm: atual.cinturaCm - 6,
        familiarPrimeiroGrau: atual.familiarPrimeiroGrau,
        pressaoAlta: atual.pressaoAlta,
        diagnosticoInformado: atual.diagnosticoInformado,
        cumpre150min: true,
        sentado8hOuMais: false,
        hortalicaQuaseTodoDia: true,
        comidaProntaFrequente: false,
        bebidaAcucaradaFrequente: false,
        embutidoFrequente: false,
        escolaridadeOrd: atual.escolaridadeOrd,
        hdl: atual.hdl,
        insegurancaAlimentar: atual.insegurancaAlimentar,
      );
      setState(() => whatIf = widget.sessao.deps.avaliador.avaliar(respostas));
    } finally {
      if (mounted) setState(() => simulando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.sessao.ultimoResultado;
    final diagnostico = widget.sessao.perfil?.diagnosticoInformado ?? false;
    final frase = diagnostico ? Copy.fraseCuidado : Copy.fraseRisco;
    return TelaPasso(
      titulo: 'Resultado',
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocoProbabilidade(
            faixa: _rotulo(r?.faixa ?? 'baixo'),
            probabilidade: r?.probabilidade,
          ),
          const SizedBox(height: 16),
          Text(frase, key: const Key('txt_frase_resultado'), style: const TextStyle(fontSize: TemaSaude.fonteMinima)),
          const SizedBox(height: 12),
          const Text(Copy.disclaimer, key: Key('txt_disclaimer'), style: TextStyle(fontSize: TemaSaude.fonteMinima, fontWeight: FontWeight.w600)),
          if (!diagnostico) ...[
            const SizedBox(height: 12),
            const Text(Copy.procurarUbs, style: const TextStyle(fontSize: TemaSaude.fonteMinima)),
          ],
          const SizedBox(height: 16),
          if (r != null && r.fatores.isNotEmpty) ...[
            const Text('O que mais pesou nesta faixa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...r.fatores.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('• $f', style: const TextStyle(fontSize: TemaSaude.fonteMinima, height: 1.3)),
                )),
          ],
          const SizedBox(height: 16),
          if (whatIf != null)
            Column(
              key: const Key('txt_whatif'),
              children: [
                const Text(
                  Copy.hipoteseHabito,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: TemaSaude.fonteMinima, fontWeight: FontWeight.w600),
                ),
                if (whatIf!.probabilidade != null)
                  BlocoProbabilidade(
                    faixa: _rotulo(whatIf!.faixa),
                    probabilidade: whatIf!.probabilidade,
                    faixaGrande: false,
                    faixaKey: const Key('txt_faixa_whatif'),
                    probKey: const Key('txt_probabilidade_whatif'),
                    decKey: const Key('txt_probabilidade_dec_whatif'),
                  ),
              ],
            ),
        ],
      ),
      acoes: [
        BotaoGrande(key: const Key('btn_whatif'), texto: Copy.whatIf, preenchido: false, carregando: simulando, onPressed: _simular),
        BotaoGrande(key: const Key('btn_inicio'), texto: Copy.irInicio, onPressed: () => widget.sessao.ir(TelaApp.home)),
      ],
    );
  }
}

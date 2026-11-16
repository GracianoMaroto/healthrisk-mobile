import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:healthrisk_mobile/app/copy.dart';
import 'package:healthrisk_mobile/app/idade.dart';
import 'package:healthrisk_mobile/app/sessao.dart';
import 'package:healthrisk_mobile/app/tema.dart';
import 'package:healthrisk_mobile/data/modelos.dart';
import 'package:healthrisk_mobile/domain/respostas.dart';
import 'package:healthrisk_mobile/ui/widgets.dart';

class QuestionarioPage extends StatefulWidget {
  const QuestionarioPage({super.key, required this.sessao});

  final Sessao sessao;

  @override
  State<QuestionarioPage> createState() => _QuestionarioPageState();
}

class _QuestionarioPageState extends State<QuestionarioPage> {
  static const _perguntas = [
    Copy.qHortalica,
    Copy.qComidaPronta,
    Copy.qBebida,
    Copy.qEmbutido,
    Copy.q150,
    Copy.qSentado,
  ];

  int passo = 0;
  bool salvando = false;
  bool? hortalica;
  bool? comidaPronta;
  bool? bebida;
  bool? embutido;
  bool? min150;
  bool? sentado;

  bool? get _atual => switch (passo) {
        0 => hortalica,
        1 => comidaPronta,
        2 => bebida,
        3 => embutido,
        4 => min150,
        _ => sentado,
      };

  void _voltar() {
    if (passo == 0 || salvando) return;
    setState(() => passo -= 1);
  }

  Future<void> _responder(bool valor) async {
    if (salvando) return;
    setState(() {
      switch (passo) {
        case 0:
          hortalica = valor;
          break;
        case 1:
          comidaPronta = valor;
          break;
        case 2:
          bebida = valor;
          break;
        case 3:
          embutido = valor;
          break;
        case 4:
          min150 = valor;
          break;
        default:
          sentado = valor;
      }
    });
    if (passo < 5) {
      setState(() => passo += 1);
      return;
    }
    setState(() => salvando = true);
    try {
      await _avaliar();
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  Future<void> _avaliar() async {
    final perfil = widget.sessao.perfil ?? await widget.sessao.deps.repos.perfil.obter();
    if (perfil == null) {
      if (mounted) {
        mostrarStatus(context, 'Perfil não encontrado. Preencha o perfil de novo.', erro: true);
      }
      return;
    }
    final agora = widget.sessao.deps.relogio.agora();
    final respostas = Respostas(
      idadeAnos: idadeEmAnos(perfil.nascimento, agora),
      sexo: perfil.sexo,
      pesoKg: perfil.pesoKg,
      alturaCm: perfil.alturaCm,
      cinturaCm: perfil.cinturaCm,
      familiarPrimeiroGrau: perfil.familiarPrimeiroGrau,
      pressaoAlta: perfil.pressaoAlta,
      diagnosticoInformado: perfil.diagnosticoInformado,
      cumpre150min: min150 ?? false,
      sentado8hOuMais: sentado ?? false,
      hortalicaQuaseTodoDia: hortalica ?? false,
      comidaProntaFrequente: comidaPronta ?? false,
      bebidaAcucaradaFrequente: bebida ?? false,
      embutidoFrequente: embutido ?? false,
      escolaridadeOrd: perfil.escolaridadeOrd,
      hdl: perfil.hdl,
      insegurancaAlimentar: perfil.insegurancaAlimentar,
    );
    final resultado = widget.sessao.deps.avaliador.avaliar(respostas);
    await widget.sessao.deps.repos.questionario.salvar(Avaliacao(
      data: agora,
      faixa: resultado.faixa,
      probabilidade: resultado.probabilidade,
      pontos: resultado.pontos,
      fatores: resultado.fatores,
      respostasJson: jsonEncode(respostas.toMap()),
    ));
    widget.sessao.publicarResultado(resultado);
  }

  @override
  Widget build(BuildContext context) {
    final atual = _atual;
    return TelaPasso(
      titulo: 'Hábitos da semana',
      onVoltar: passo == 0 ? null : _voltar,
      passoAtual: passo + 1,
      totalPassos: _perguntas.length,
      rotuloPasso: 'Pergunta ${passo + 1} de ${_perguntas.length}',
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _perguntas[passo],
            key: const Key('titulo_passo'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(Copy.qAjuda, style: TextStyle(fontSize: TemaSaude.fonteMinima, height: 1.3)),
          const SizedBox(height: 24),
          BotaoGrande(
            key: const Key('btn_sim'),
            texto: Copy.sim,
            preenchido: atual == true,
            carregando: salvando,
            onPressed: () => _responder(true),
          ),
          const SizedBox(height: 12),
          BotaoGrande(
            key: const Key('btn_nao'),
            texto: Copy.nao,
            preenchido: atual == false,
            carregando: salvando,
            onPressed: () => _responder(false),
          ),
        ],
      ),
    );
  }
}

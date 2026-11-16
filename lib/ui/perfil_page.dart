import 'package:flutter/material.dart';
import 'package:healthrisk_mobile/app/copy.dart';
import 'package:healthrisk_mobile/app/sessao.dart';
import 'package:healthrisk_mobile/app/tema.dart';
import 'package:healthrisk_mobile/data/modelos.dart';
import 'package:healthrisk_mobile/ui/mascaras.dart';
import 'package:healthrisk_mobile/ui/widgets.dart';
import 'package:intl/intl.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key, required this.sessao});

  final Sessao sessao;

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  static const _total = 11;

  int passo = 0;
  final nascimento = TextEditingController();
  final peso = TextEditingController();
  final altura = TextEditingController();
  final cintura = TextEditingController();
  final hdl = TextEditingController();
  int? sexo;
  int? escolaridadeOrd;
  bool? familiar;
  bool? pressao;
  bool? diagnostico;
  bool? inseguranca;
  String? erro;

  @override
  void dispose() {
    nascimento.dispose();
    peso.dispose();
    altura.dispose();
    cintura.dispose();
    hdl.dispose();
    super.dispose();
  }

  String get _titulo => switch (passo) {
        0 => Copy.pNascimento,
        1 => Copy.pSexo,
        2 => Copy.pPeso,
        3 => Copy.pAltura,
        4 => Copy.pCintura,
        5 => Copy.pFamiliar,
        6 => Copy.pPressao,
        7 => Copy.pDiagnostico,
        8 => Copy.pEscolaridade,
        9 => Copy.pHdl,
        _ => Copy.pInseguranca,
      };

  String? get _ajuda => switch (passo) {
        0 => Copy.pNascimentoAjuda,
        8 => Copy.pEscolaridadeAjuda,
        9 => Copy.pHdlAjuda,
        _ => null,
      };

  void _voltar() {
    if (passo == 0) return;
    setState(() {
      erro = null;
      passo -= 1;
    });
  }

  Future<void> _avancar() async {
    setState(() => erro = null);
    if (passo == 0 && _parseData(nascimento.text) == null) {
      setState(() => erro = 'Use o formato dd/mm/aaaa.');
      return;
    }
    if (passo == 2 && double.tryParse(peso.text.replaceAll(',', '.')) == null) {
      setState(() => erro = 'Informe o peso.');
      return;
    }
    if (passo == 3) {
      final h = double.tryParse(altura.text.replaceAll(',', '.'));
      if (h == null || h <= 0) {
        setState(() => erro = Copy.alturaZero);
        return;
      }
    }
    if (passo == 4 && double.tryParse(cintura.text.replaceAll(',', '.')) == null) {
      setState(() => erro = 'Informe a cintura.');
      return;
    }
    if (passo == 9 && hdl.text.trim().isEmpty) {
      hdl.clear();
    }
    if (passo < 10) {
      setState(() => passo += 1);
      return;
    }
    await _salvar();
  }

  Future<void> _salvar() async {
    final h = double.parse(altura.text.replaceAll(',', '.'));
    if (h <= 0) {
      setState(() => erro = Copy.alturaZero);
      return;
    }
    final perfil = Perfil(
      nascimento: _parseData(nascimento.text)!,
      sexo: sexo ?? 1,
      pesoKg: double.parse(peso.text.replaceAll(',', '.')),
      alturaCm: h,
      cinturaCm: double.parse(cintura.text.replaceAll(',', '.')),
      familiarPrimeiroGrau: familiar ?? false,
      pressaoAlta: pressao ?? false,
      diagnosticoInformado: diagnostico ?? false,
      escolaridadeOrd: escolaridadeOrd,
      hdl: double.tryParse(hdl.text.replaceAll(',', '.')),
      insegurancaAlimentar: inseguranca,
    );
    await widget.sessao.deps.repos.perfil.salvar(perfil);
    widget.sessao.perfil = perfil;
    widget.sessao.ir(TelaApp.questionario);
  }

  DateTime? _parseData(String texto) {
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(texto.trim());
    } catch (_) {
      return null;
    }
  }

  Widget _simNao(bool? atual, void Function(bool) on) {
    return Column(
      children: [
        BotaoGrande(
          key: const Key('btn_sim'),
          texto: Copy.sim,
          preenchido: atual == true,
          onPressed: () {
            on(true);
            _avancar();
          },
        ),
        const SizedBox(height: 12),
        BotaoGrande(
          key: const Key('btn_nao'),
          texto: Copy.nao,
          preenchido: atual == false,
          onPressed: () {
            on(false);
            _avancar();
          },
        ),
      ],
    );
  }

  Widget _escolaridade() {
    const niveis = [
      (1, Copy.esc1),
      (2, Copy.esc2),
      (3, Copy.esc3),
      (4, Copy.esc4),
      (5, Copy.esc5),
    ];
    return Column(
      children: [
        for (final n in niveis) ...[
          BotaoGrande(
            key: Key('btn_esc_${n.$1}'),
            texto: n.$2,
            preenchido: escolaridadeOrd == n.$1,
            onPressed: () {
              escolaridadeOrd = n.$1;
              _avancar();
            },
          ),
          const SizedBox(height: 12),
        ],
        BotaoGrande(
          key: const Key('btn_pular'),
          texto: Copy.naoSei,
          preenchido: false,
          onPressed: () {
            escolaridadeOrd = null;
            _avancar();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget campo;
    final acoes = <Widget>[];
    switch (passo) {
      case 0:
        campo = CampoGrande(
          key: const Key('campo_nascimento'),
          rotulo: 'Nascimento (dd/mm/aaaa)',
          controller: nascimento,
          hint: '15/01/1968',
          teclado: TextInputType.number,
          obrigatorio: true,
          formatters: const [MascaraData()],
        );
        acoes.add(BotaoGrande(key: const Key('btn_continuar'), texto: Copy.continuar, onPressed: _avancar));
        break;
      case 1:
        campo = Column(children: [
          BotaoGrande(
            key: const Key('btn_sexo_m'),
            texto: 'Masculino',
            preenchido: sexo == 1,
            onPressed: () {
              sexo = 1;
              _avancar();
            },
          ),
          const SizedBox(height: 12),
          BotaoGrande(
            key: const Key('btn_sexo_f'),
            texto: 'Feminino',
            preenchido: sexo == 2,
            onPressed: () {
              sexo = 2;
              _avancar();
            },
          ),
        ]);
        break;
      case 2:
        campo = CampoGrande(
          key: const Key('campo_peso'),
          rotulo: 'Peso (kg)',
          controller: peso,
          teclado: const TextInputType.numberWithOptions(decimal: true),
          obrigatorio: true,
          formatters: const [MascaraDecimal()],
        );
        acoes.add(BotaoGrande(key: const Key('btn_continuar'), texto: Copy.continuar, onPressed: _avancar));
        break;
      case 3:
        campo = CampoGrande(
          key: const Key('campo_altura'),
          rotulo: 'Altura (cm)',
          controller: altura,
          teclado: const TextInputType.numberWithOptions(decimal: true),
          obrigatorio: true,
          formatters: const [MascaraDecimal()],
        );
        acoes.add(BotaoGrande(key: const Key('btn_continuar'), texto: Copy.continuar, onPressed: _avancar));
        break;
      case 4:
        campo = CampoGrande(
          key: const Key('campo_cintura'),
          rotulo: 'Cintura (cm)',
          controller: cintura,
          teclado: const TextInputType.numberWithOptions(decimal: true),
          obrigatorio: true,
          formatters: const [MascaraDecimal()],
        );
        acoes.add(BotaoGrande(key: const Key('btn_continuar'), texto: Copy.continuar, onPressed: _avancar));
        break;
      case 5:
        campo = _simNao(familiar, (v) => familiar = v);
        break;
      case 6:
        campo = _simNao(pressao, (v) => pressao = v);
        break;
      case 7:
        campo = _simNao(diagnostico, (v) => diagnostico = v);
        break;
      case 8:
        campo = _escolaridade();
        break;
      case 9:
        campo = CampoGrande(
          key: const Key('campo_hdl'),
          rotulo: 'HDL (mg/dL)',
          controller: hdl,
          teclado: const TextInputType.numberWithOptions(decimal: true),
          opcional: true,
          formatters: const [MascaraDecimal()],
        );
        acoes.add(BotaoGrande(key: const Key('btn_continuar'), texto: Copy.continuar, onPressed: _avancar));
        acoes.add(BotaoGrande(
          key: const Key('btn_pular'),
          texto: Copy.naoSei,
          preenchido: false,
          onPressed: () {
            hdl.clear();
            _avancar();
          },
        ));
        break;
      default:
        campo = Column(
          children: [
            _simNao(inseguranca, (v) => inseguranca = v),
            const SizedBox(height: 12),
            BotaoGrande(
              key: const Key('btn_pular'),
              texto: Copy.naoSei,
              preenchido: false,
              onPressed: () {
                inseguranca = null;
                _avancar();
              },
            ),
          ],
        );
    }

    final ajuda = _ajuda;
    return TelaPasso(
      titulo: 'Perfil',
      onVoltar: passo == 0 ? null : _voltar,
      passoAtual: passo + 1,
      totalPassos: _total,
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_titulo, key: const Key('titulo_passo'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          if (ajuda != null) ...[
            const SizedBox(height: 8),
            Text(ajuda, style: const TextStyle(fontSize: TemaSaude.fonteMinima, height: 1.3)),
          ],
          const SizedBox(height: 16),
          campo,
          if (erro != null) ...[
            const SizedBox(height: 12),
            Text(erro!, style: const TextStyle(color: Colors.red, fontSize: TemaSaude.fonteMinima)),
          ],
        ],
      ),
      acoes: acoes,
    );
  }
}

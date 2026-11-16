/// Respostas do questionário e do perfil.
///
/// Contrato do escudo anti-vazamento: este objeto **não** tem glicemia, HbA1c,
/// insulina nem nome de hipoglicemiante. Exame vive em outra tabela (Etapa 2).
class Respostas {
  const Respostas({
    required this.idadeAnos,
    required this.sexo,
    required this.pesoKg,
    required this.alturaCm,
    required this.cinturaCm,
    required this.familiarPrimeiroGrau,
    required this.pressaoAlta,
    required this.diagnosticoInformado,
    required this.cumpre150min,
    required this.sentado8hOuMais,
    required this.hortalicaQuaseTodoDia,
    required this.comidaProntaFrequente,
    required this.bebidaAcucaradaFrequente,
    required this.embutidoFrequente,
    this.escolaridadeOrd,
    this.hdl,
    this.insegurancaAlimentar,
  });

  /// Idade em anos completos (o ViewModel da Etapa 2 calcula a partir da data de nascimento).
  final int idadeAnos;

  /// 1 = masculino, 2 = feminino (codificação NHANES). Entra no cálculo da LR, não na frase da tela.
  final int sexo;

  final double pesoKg;
  final double alturaCm;
  final double cinturaCm;
  final bool familiarPrimeiroGrau;
  final bool pressaoAlta;

  /// Só troca a frase da tela de resultado. Não pontua.
  final bool diagnosticoInformado;

  final bool cumpre150min;
  final bool sentado8hOuMais;
  final bool hortalicaQuaseTodoDia;
  final bool comidaProntaFrequente;
  final bool bebidaAcucaradaFrequente;
  final bool embutidoFrequente;

  /// Opcional ("não sei" → null → imputador estratificado).
  final int? escolaridadeOrd;
  final double? hdl;
  final bool? insegurancaAlimentar;

  double get imc => pesoKg / ((alturaCm / 100.0) * (alturaCm / 100.0));

  double get razaoCinturaEstatura => cinturaCm / alturaCm;

  /// Proxy da pergunta "8 h ou mais sentado": 540 min (9 h) ou 240 min (4 h).
  int get minutosSentadoDia => sentado8hOuMais ? 540 : 240;

  Map<String, Object?> toMap() => {
        'idadeAnos': idadeAnos,
        'sexo': sexo,
        'pesoKg': pesoKg,
        'alturaCm': alturaCm,
        'cinturaCm': cinturaCm,
        'familiarPrimeiroGrau': familiarPrimeiroGrau,
        'pressaoAlta': pressaoAlta,
        'diagnosticoInformado': diagnosticoInformado,
        'cumpre150min': cumpre150min,
        'sentado8hOuMais': sentado8hOuMais,
        'hortalicaQuaseTodoDia': hortalicaQuaseTodoDia,
        'comidaProntaFrequente': comidaProntaFrequente,
        'bebidaAcucaradaFrequente': bebidaAcucaradaFrequente,
        'embutidoFrequente': embutidoFrequente,
        'escolaridadeOrd': escolaridadeOrd,
        'hdl': hdl,
        'insegurancaAlimentar': insegurancaAlimentar,
        'imc': imc,
        'razaoCinturaEstatura': razaoCinturaEstatura,
        'minutosSentadoDia': minutosSentadoDia,
      };

  Respostas copyWith({
    int? idadeAnos,
    int? sexo,
    double? pesoKg,
    double? alturaCm,
    double? cinturaCm,
    bool? familiarPrimeiroGrau,
    bool? pressaoAlta,
    bool? diagnosticoInformado,
    bool? cumpre150min,
    bool? sentado8hOuMais,
    bool? hortalicaQuaseTodoDia,
    bool? comidaProntaFrequente,
    bool? bebidaAcucaradaFrequente,
    bool? embutidoFrequente,
    int? escolaridadeOrd,
    double? hdl,
    bool? insegurancaAlimentar,
    bool limparEscolaridade = false,
    bool limparHdl = false,
    bool limparInseguranca = false,
  }) {
    return Respostas(
      idadeAnos: idadeAnos ?? this.idadeAnos,
      sexo: sexo ?? this.sexo,
      pesoKg: pesoKg ?? this.pesoKg,
      alturaCm: alturaCm ?? this.alturaCm,
      cinturaCm: cinturaCm ?? this.cinturaCm,
      familiarPrimeiroGrau: familiarPrimeiroGrau ?? this.familiarPrimeiroGrau,
      pressaoAlta: pressaoAlta ?? this.pressaoAlta,
      diagnosticoInformado: diagnosticoInformado ?? this.diagnosticoInformado,
      cumpre150min: cumpre150min ?? this.cumpre150min,
      sentado8hOuMais: sentado8hOuMais ?? this.sentado8hOuMais,
      hortalicaQuaseTodoDia: hortalicaQuaseTodoDia ?? this.hortalicaQuaseTodoDia,
      comidaProntaFrequente: comidaProntaFrequente ?? this.comidaProntaFrequente,
      bebidaAcucaradaFrequente:
          bebidaAcucaradaFrequente ?? this.bebidaAcucaradaFrequente,
      embutidoFrequente: embutidoFrequente ?? this.embutidoFrequente,
      escolaridadeOrd:
          limparEscolaridade ? null : (escolaridadeOrd ?? this.escolaridadeOrd),
      hdl: limparHdl ? null : (hdl ?? this.hdl),
      insegurancaAlimentar: limparInseguranca
          ? null
          : (insegurancaAlimentar ?? this.insegurancaAlimentar),
    );
  }
}

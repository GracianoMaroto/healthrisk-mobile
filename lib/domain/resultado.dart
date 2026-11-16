class Resultado {
  const Resultado({
    required this.faixa,
    this.probabilidade,
    this.pontos,
    this.fatores = const [],
  });

  /// `baixo`, `moderado` ou `alto`.
  final String faixa;

  /// Probabilidade da regressão logística (0–1). Ausente no checklist.
  final double? probabilidade;

  /// Pontos da seção 3.5 (0–23). Ausente na LR.
  final int? pontos;

  /// Frases acionáveis da tela ("você pontuou porque…").
  /// Sexo, escolaridade e renda imputada **não** entram aqui.
  final List<String> fatores;
}

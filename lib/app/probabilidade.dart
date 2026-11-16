class FormatoProbabilidade {
  static String porcentagem(double p) {
    return '${(p * 100).toStringAsFixed(1).replaceAll('.', ',')}%';
  }

  static String decimal(double p) {
    return p.toStringAsFixed(4).replaceAll('.', ',');
  }
}

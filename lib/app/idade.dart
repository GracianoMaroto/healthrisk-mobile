int idadeEmAnos(DateTime nascimento, DateTime hoje) {
  var idade = hoje.year - nascimento.year;
  final aniversarioEsteAno = DateTime(hoje.year, nascimento.month, nascimento.day);
  if (hoje.isBefore(aniversarioEsteAno)) {
    idade -= 1;
  }
  return idade;
}

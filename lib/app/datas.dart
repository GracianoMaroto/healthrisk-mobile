import 'package:intl/intl.dart';

DateTime? parseQuandoConsulta(String texto) {
  final t = texto.trim();
  if (t.isEmpty) return null;
  for (final fmt in const ['dd/MM/yyyy HH:mm', 'dd/MM/yyyy']) {
    try {
      return DateFormat(fmt).parseStrict(t);
    } catch (_) {}
  }
  return null;
}

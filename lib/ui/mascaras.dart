import 'package:flutter/services.dart';

class MascaraData extends TextInputFormatter {
  const MascaraData();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _aplicar(newValue.text, 8, [2, 4], '/');
  }
}

class MascaraDataHora extends TextInputFormatter {
  const MascaraDataHora();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > 12 ? digits.substring(0, 12) : digits;
    final buf = StringBuffer();
    for (var i = 0; i < clipped.length; i++) {
      if (i == 2 || i == 4) buf.write('/');
      if (i == 8) buf.write(' ');
      if (i == 10) buf.write(':');
      buf.write(clipped[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class MascaraHora extends TextInputFormatter {
  const MascaraHora();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _aplicar(newValue.text, 4, [2], ':');
  }
}

class MascaraDecimal extends TextInputFormatter {
  const MascaraDecimal();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final buf = StringBuffer();
    var separador = false;
    for (final rune in newValue.text.runes) {
      final c = String.fromCharCode(rune);
      if (c.compareTo('0') >= 0 && c.compareTo('9') <= 0) {
        buf.write(c);
      } else if ((c == ',' || c == '.') && !separador) {
        buf.write(c);
        separador = true;
      }
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class MascaraDigitos extends TextInputFormatter {
  const MascaraDigitos({this.maximo});

  final int? maximo;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (maximo != null && digits.length > maximo!) {
      digits = digits.substring(0, maximo);
    }
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}

TextEditingValue _aplicar(
  String bruto,
  int limite,
  List<int> cortes,
  String marca,
) {
  final digits = bruto.replaceAll(RegExp(r'\D'), '');
  final clipped = digits.length > limite ? digits.substring(0, limite) : digits;
  final buf = StringBuffer();
  for (var i = 0; i < clipped.length; i++) {
    if (cortes.contains(i)) buf.write(marca);
    buf.write(clipped[i]);
  }
  final text = buf.toString();
  return TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: text.length),
  );
}

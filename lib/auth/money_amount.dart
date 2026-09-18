import 'package:flutter/services.dart';

import 'digit_cursor.dart';

class MoneyAmount {
  static String digits(String raw, {int maxDigits = 9}) {
    var only = raw.replaceAll(RegExp(r'\D'), '');
    if (only.length > maxDigits) only = only.substring(0, maxDigits);
    if (only.isEmpty) return '';
    only = only.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    return only;
  }

  static String format(String raw, {int maxDigits = 9}) {
    final d = digits(raw, maxDigits: maxDigits);
    if (d.isEmpty) return '';
    final buf = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      final fromEnd = d.length - i;
      buf.write(d[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }

  static int parse(String raw) => int.tryParse(digits(raw)) ?? 0;
}

class MoneyFormatter extends TextInputFormatter {
  const MoneyFormatter({this.maxDigits = 9});

  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldDigits = MoneyAmount.digits(oldValue.text, maxDigits: maxDigits);
    var nextDigits = MoneyAmount.digits(newValue.text, maxDigits: maxDigits);
    final deleting = newValue.text.length < oldValue.text.length;
    final oldBefore = digitCountBefore(oldValue.text, oldValue.selection.baseOffset);
    var cursorDigits = digitCountBefore(newValue.text, newValue.selection.baseOffset);

    if (deleting && nextDigits.length >= oldDigits.length && oldBefore > 0) {
      nextDigits = deleteDigitAt(oldDigits, oldBefore);
      cursorDigits = oldBefore - 1;
    }

    nextDigits = MoneyAmount.digits(nextDigits, maxDigits: maxDigits);
    cursorDigits = cursorDigits.clamp(0, nextDigits.length);
    final formatted = MoneyAmount.format(nextDigits, maxDigits: maxDigits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: offsetAfterDigits(formatted, cursorDigits),
      ),
    );
  }
}

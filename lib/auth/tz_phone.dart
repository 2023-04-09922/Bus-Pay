import 'package:flutter/services.dart';

import 'digit_cursor.dart';

class TzPhone {
  static const prefix = '+255 ';

  static String nationalDigits(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    while (digits.startsWith('255')) {
      digits = digits.substring(3);
    }
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return digits.length > 9 ? digits.substring(0, 9) : digits;
  }

  static String format(String raw) {
    final national = nationalDigits(raw);
    if (national.isEmpty) return prefix;
    if (national.length <= 3) return '$prefix$national';
    return '$prefix${national.substring(0, 3)} ${national.substring(3)}';
  }

  static bool isValid(String raw) =>
      RegExp(r'^[1-9]\d{8}$').hasMatch(nationalDigits(raw));

  static String toApi(String raw) => '+255${nationalDigits(raw)}';
}

class TzPhoneFormatter extends TextInputFormatter {
  const TzPhoneFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldDigits = TzPhone.nationalDigits(oldValue.text);
    var nextDigits = TzPhone.nationalDigits(newValue.text);
    final deleting = newValue.text.length < oldValue.text.length;
    final oldBefore = _nationalBefore(oldValue);
    var cursorDigits = _nationalBefore(newValue);

    if (deleting && nextDigits.length >= oldDigits.length && oldBefore > 0) {
      nextDigits = deleteDigitAt(oldDigits, oldBefore);
      cursorDigits = oldBefore - 1;
    }

    nextDigits = TzPhone.nationalDigits(nextDigits);
    cursorDigits = cursorDigits.clamp(0, nextDigits.length);
    final formatted = TzPhone.format(nextDigits);
    final offset = cursorDigits == 0
        ? TzPhone.prefix.length
        : offsetAfterDigits(formatted, cursorDigits + 3);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: offset.clamp(0, formatted.length),
      ),
    );
  }

  int _nationalBefore(TextEditingValue value) {
    final allBefore = digitCountBefore(value.text, value.selection.baseOffset);
    return (allBefore - 3).clamp(0, 9);
  }
}

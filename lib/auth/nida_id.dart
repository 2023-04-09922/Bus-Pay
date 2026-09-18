import 'package:flutter/services.dart';

import 'digit_cursor.dart';

class NidaId {
  static String digits(String raw) {
    final only = raw.replaceAll(RegExp(r'\D'), '');
    return only.length > 20 ? only.substring(0, 20) : only;
  }

  static String format(String raw) {
    final d = digits(raw);
    if (d.length <= 8) return d;
    if (d.length <= 13) {
      return '${d.substring(0, 8)}-${d.substring(8)}';
    }
    if (d.length <= 18) {
      return '${d.substring(0, 8)}-${d.substring(8, 13)}-${d.substring(13)}';
    }
    return '${d.substring(0, 8)}-${d.substring(8, 13)}-${d.substring(13, 18)}-${d.substring(18)}';
  }

  static bool isValid(String raw) => digits(raw).length == 20;

  static String toApi(String raw) => digits(raw);
}

class NidaFormatter extends TextInputFormatter {
  const NidaFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldDigits = NidaId.digits(oldValue.text);
    var nextDigits = NidaId.digits(newValue.text);
    final deleting = newValue.text.length < oldValue.text.length;
    final oldBefore = digitCountBefore(oldValue.text, oldValue.selection.baseOffset);
    var cursorDigits = digitCountBefore(newValue.text, newValue.selection.baseOffset);

    if (deleting && nextDigits.length >= oldDigits.length && oldBefore > 0) {
      nextDigits = deleteDigitAt(oldDigits, oldBefore);
      cursorDigits = oldBefore - 1;
    }

    nextDigits = NidaId.digits(nextDigits);
    cursorDigits = cursorDigits.clamp(0, nextDigits.length);
    final formatted = NidaId.format(nextDigits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: offsetAfterDigits(formatted, cursorDigits),
      ),
    );
  }
}

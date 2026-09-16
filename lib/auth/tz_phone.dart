import 'package:flutter/services.dart';

class TzPhone {
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
    if (national.isEmpty) return '+255 ';
    if (national.length <= 3) return '+255 $national';
    return '+255 ${national.substring(0, 3)} ${national.substring(3)}';
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
    final deleting = newValue.text.length < oldValue.text.length;
    var source = newValue.text;
    if (deleting) {
      final oldDigits = TzPhone.nationalDigits(oldValue.text);
      final newDigits = TzPhone.nationalDigits(newValue.text);
      if (oldDigits.isNotEmpty && newDigits.length >= oldDigits.length) {
        source = oldDigits.substring(0, oldDigits.length - 1);
      }
    }
    final formatted = TzPhone.format(source);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

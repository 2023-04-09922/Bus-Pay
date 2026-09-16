import 'package:flutter/services.dart';

class NidaId {
  static String digits(String raw) {
    final only = raw.replaceAll(RegExp(r'\D'), '');
    return only.length > 20 ? only.substring(0, 20) : only;
  }

  static String format(String raw) {
    final d = digits(raw);
    if (d.length <= 8) return d;
    if (d.length <= 19) {
      return '${d.substring(0, 8)}-${d.substring(8)}';
    }
    return '${d.substring(0, 8)}-${d.substring(8, 19)}-${d.substring(19)}';
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
    final formatted = NidaId.format(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

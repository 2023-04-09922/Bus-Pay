int digitCountBefore(String text, int offset) {
  final end = offset.clamp(0, text.length);
  var count = 0;
  for (var i = 0; i < end; i++) {
    final code = text.codeUnitAt(i);
    if (code >= 48 && code <= 57) count++;
  }
  return count;
}

int offsetAfterDigits(String formatted, int digitCount, {int minOffset = 0}) {
  if (digitCount <= 0) return minOffset.clamp(0, formatted.length);
  var seen = 0;
  for (var i = 0; i < formatted.length; i++) {
    final code = formatted.codeUnitAt(i);
    if (code >= 48 && code <= 57) {
      seen++;
      if (seen >= digitCount) return i + 1;
    }
  }
  return formatted.length;
}

String deleteDigitAt(String digits, int digitIndex) {
  if (digits.isEmpty || digitIndex <= 0) return digits;
  final i = (digitIndex - 1).clamp(0, digits.length - 1);
  return digits.substring(0, i) + digits.substring(i + 1);
}

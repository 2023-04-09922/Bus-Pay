class PasswordRule {
  static final pattern = RegExp(r'^\d{4}$');

  static bool isValid(String value) => pattern.hasMatch(value);
}

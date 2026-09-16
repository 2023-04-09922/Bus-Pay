class AgentPasswordRule {
  static final pattern = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
  );

  static bool isValid(String value) => pattern.hasMatch(value);
}

class AgentEmail {
  static final pattern = RegExp(
    r'^[\w.+-]+@[a-z0-9-]+(\.[a-z0-9-]+)+$',
    caseSensitive: false,
  );

  static String normalize(String raw) =>
      raw.trim().toLowerCase().replaceAll(',', '.');

  static bool isValid(String raw) => pattern.hasMatch(normalize(raw));
}

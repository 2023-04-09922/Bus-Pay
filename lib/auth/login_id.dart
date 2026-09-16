enum UserRole { conductor, agent }

class LoginId {
  static final conductorPattern =
      RegExp(r'^bp-c[a-z0-9]{6}bus$', caseSensitive: false);
  static final agentPattern =
      RegExp(r'^bp-a[a-z0-9]{6}agent$', caseSensitive: false);

  static String normalize(String raw) => raw.trim();

  static UserRole? roleOf(String raw) {
    final id = normalize(raw);
    if (conductorPattern.hasMatch(id)) return UserRole.conductor;
    if (agentPattern.hasMatch(id)) return UserRole.agent;
    return null;
  }

  static String formatTill(String digits) {
    final only = digits.replaceAll(RegExp(r'\D'), '');
    if (only.length >= 8) {
      final d = only.substring(only.length - 8);
      return '${d.substring(0, 4)}-${d.substring(4)}';
    }
    final padded = only.padLeft(8, '0');
    return '${padded.substring(0, 4)}-${padded.substring(4)}';
  }
}

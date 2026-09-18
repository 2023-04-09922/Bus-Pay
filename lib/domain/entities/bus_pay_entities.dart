class AgentEntity {
  const AgentEntity({
    required this.email,
    required this.token,
    required this.firstName,
    required this.lastName,
    required this.tillNumber,
  });

  final String email;
  final String token;
  final String firstName;
  final String lastName;
  final String tillNumber;
}

class CardEntity {
  const CardEntity({
    required this.serialNumber,
    required this.firstName,
    required this.lastName,
    this.nfcUid = '',
    this.phone = '',
    this.balance = 0,
    this.frozen = false,
  });

  final String serialNumber;
  final String nfcUid;
  final String firstName;
  final String lastName;
  final String phone;
  final int balance;
  final bool frozen;

  String get holderName => '$firstName $lastName'.trim();
}

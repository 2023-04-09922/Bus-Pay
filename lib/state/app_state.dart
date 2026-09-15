import 'package:flutter/material.dart';

class Transaction {
  Transaction({
    required this.passengerName,
    required this.amount,
    required this.time,
    this.type = TransactionType.nauli,
    this.detail = '',
  });

  final String passengerName;
  final int amount;
  final DateTime time;
  final TransactionType type;
  final String detail;
}

enum TransactionType { nauli, toaPesa, tumaPesa }

enum AppLanguage { sw, en }

enum DisplaySize { compact, normal, large }

class ConductorProfile {
  ConductorProfile({
    required this.name,
    required this.id,
    required this.email,
    required this.phone,
  });

  String name;
  String id;
  String email;
  String phone;
}

class AppState extends ChangeNotifier {
  int walletBalance = 0;
  final List<Transaction> transactions = [];
  ThemeMode themeMode = ThemeMode.light;
  AppLanguage language = AppLanguage.sw;
  DisplaySize displaySize = DisplaySize.normal;

  ConductorProfile profile = ConductorProfile(
    name: 'John Mushi',
    id: 'DLD-C001',
    email: 'john.mushi@daladala.co.tz',
    phone: '+255 712 345 678',
  );

  double get textScale => switch (displaySize) {
        DisplaySize.compact => 0.90,
        DisplaySize.normal => 1.0,
        DisplaySize.large => 1.15,
      };

  Locale get locale =>
      language == AppLanguage.sw ? const Locale('sw') : const Locale('en');

  void applyLoginId(String conductorId) {
    if (conductorId.trim().isNotEmpty) {
      profile.id = conductorId.trim();
    }
    notifyListeners();
  }

  void addNauliPayment({
    required String passengerName,
    required int amount,
  }) {
    walletBalance += amount;
    transactions.insert(
      0,
      Transaction(
        passengerName: passengerName,
        amount: amount,
        time: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  bool withdrawToAgent({
    required String agentName,
    required int amount,
  }) {
    if (amount <= 0 || amount > walletBalance) return false;
    walletBalance -= amount;
    transactions.insert(
      0,
      Transaction(
        passengerName: agentName,
        amount: amount,
        time: DateTime.now(),
        type: TransactionType.toaPesa,
        detail: 'Wakala',
      ),
    );
    notifyListeners();
    return true;
  }

  bool sendMobileMoney({
    required String network,
    required String phone,
    required int amount,
  }) {
    if (amount <= 0 || amount > walletBalance) return false;
    walletBalance -= amount;
    transactions.insert(
      0,
      Transaction(
        passengerName: phone,
        amount: amount,
        time: DateTime.now(),
        type: TransactionType.tumaPesa,
        detail: network,
      ),
    );
    notifyListeners();
    return true;
  }

  void setTheme(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
  }

  void setLanguage(AppLanguage value) {
    language = value;
    notifyListeners();
  }

  void setDisplaySize(DisplaySize value) {
    displaySize = value;
    notifyListeners();
  }

  void updateProfile({
    String? name,
    String? email,
    String? phone,
  }) {
    if (name != null) profile.name = name;
    if (email != null) profile.email = email;
    if (phone != null) profile.phone = phone;
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.notifier!;
  }
}

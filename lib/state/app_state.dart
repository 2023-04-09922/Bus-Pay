import 'package:flutter/material.dart';

import '../auth/account_store.dart';
import '../auth/login_id.dart';
import '../services/api_service.dart';

class Transaction {
  Transaction({
    required this.passengerName,
    required this.amount,
    required this.time,
    this.type = TransactionType.nauli,
    this.detail = '',
    this.reference = '',
  });

  final String passengerName;
  final int amount;
  final DateTime time;
  final TransactionType type;
  final String detail;
  final String reference;
}

enum TransactionType { nauli, toaPesa, tumaPesa }

enum AppLanguage { sw, en }

enum DisplaySize { compact, normal, large }

class UserAccount {
  UserAccount({
    required this.username,
    required this.password,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.nida = '',
    this.email = '',
    this.tillNumber = '',
  });

  String username;
  String password;
  UserRole role;
  String firstName;
  String lastName;
  String phone;
  String nida;
  String email;
  String tillNumber;

  String get fullName => '$firstName $lastName'.trim();
}

class AppState extends ChangeNotifier {
  int walletBalance = 0;
  final List<Transaction> transactions = [];
  ThemeMode themeMode = ThemeMode.light;
  AppLanguage language = AppLanguage.sw;
  DisplaySize displaySize = DisplaySize.normal;
  bool walletHidden = true;
  UserRole? currentRole;
  UserAccount? currentUser;
  String? authToken;
  String? hiddenUsername;

  double get textScale => switch (displaySize) {
        DisplaySize.compact => 0.90,
        DisplaySize.normal => 1.0,
        DisplaySize.large => 1.15,
      };

  String get displayName => currentUser?.fullName ?? '';
  String get displayId => currentUser?.phone ?? '';
  String get displayPhone => currentUser?.phone ?? '';
  String get displayEmail => currentUser?.email ?? '';
  String get agentTill => currentUser?.tillNumber ?? '0000-0000';

  void applyRemoteLogin(Map<String, dynamic> data) {
    final rawUser = data['user'];
    final user = rawUser is Map
        ? Map<String, dynamic>.from(rawUser)
        : Map<String, dynamic>.from(data);

    authToken = (data['token'] ?? data['accessToken'] ?? user['token'])
        ?.toString();

    final phone = (user['phone'] ?? user['mobile'] ?? '').toString();
    final username = (user['username'] ?? hiddenUsername ?? '').toString();
    final roleValue =
        (user['role'] ?? data['role'] ?? '').toString().toLowerCase();
    final role = roleValue.contains('admin')
        ? UserRole.admin
        : roleValue.contains('agent')
            ? UserRole.agent
            : (LoginId.roleOf(username) ?? UserRole.conductor);

    final names = (user['name'] ?? user['fullName'] ?? '').toString().trim();
    var first = (user['firstName'] ?? '').toString().trim();
    var last = (user['lastName'] ?? '').toString().trim();
    if (first.isEmpty && names.isNotEmpty) {
      final parts = names.split(RegExp(r'\s+'));
      first = parts.first;
      last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    currentUser = UserAccount(
      username: username.isEmpty ? phone : username,
      password: '',
      role: role,
      firstName: first.isEmpty ? 'Conductor' : first,
      lastName: last,
      phone: phone,
      nida: (user['nida'] ?? '').toString(),
      email: (user['email'] ?? '').toString(),
      tillNumber: (user['tillNumber'] ?? user['till'] ?? '').toString(),
    );
    currentRole = role;
    final collected = user['collected'] ?? data['collected'];
    if (collected is num) walletBalance = collected.toInt();
    if (role == UserRole.conductor && username.isNotEmpty) {
      hiddenUsername = username;
      AccountStore.saveUsername(username);
    }
    notifyListeners();
    refreshLedger();
  }

  Future<void> loadSavedAccount() async {
    hiddenUsername = await AccountStore.readUsername();
    notifyListeners();
  }

  Future<void> rememberAccount(String username) async {
    hiddenUsername = username;
    await AccountStore.saveUsername(username);
    notifyListeners();
  }

  void logout() {
    currentUser = null;
    currentRole = null;
    authToken = null;
    walletBalance = 0;
    transactions.clear();
    notifyListeners();
  }

  Future<void> refreshLedger() async {
    final token = authToken;
    if (token == null || token.isEmpty) return;
    try {
      final data = await ApiService.getTransactions(token: token);
      applyLedger(data);
    } catch (_) {}
  }

  void applyLedger(Map<String, dynamic> data) {
    final rows = data['transactions'];
    final collected = data['collected'];
    transactions
      ..removeWhere((tx) => tx.type == TransactionType.nauli)
      ..insertAll(0, _parseNauli(rows));
    if (collected is num) {
      walletBalance = collected.toInt();
    } else {
      walletBalance = transactions
          .where((tx) => tx.type == TransactionType.nauli)
          .fold(0, (sum, tx) => sum + tx.amount);
    }
    notifyListeners();
  }

  List<Transaction> _parseNauli(Object? rows) {
    if (rows is! List) return const [];
    return rows.map((row) {
      final map = row is Map ? Map<String, dynamic>.from(row) : <String, dynamic>{};
      final createdAt = DateTime.tryParse('${map['createdAt'] ?? ''}') ??
          DateTime.now();
      final first = (map['firstName'] ?? '').toString().trim();
      final last = (map['lastName'] ?? '').toString().trim();
      final fromNames = '$first $last'.trim();
      final passenger = fromNames.isNotEmpty
          ? fromNames
          : (map['passenger'] ?? map['card'] ?? '').toString();
      return Transaction(
        passengerName: passenger.isEmpty ? 'Passenger' : passenger,
        amount: (map['amount'] as num?)?.toInt() ?? 0,
        time: createdAt.toLocal(),
        reference: (map['reference'] ?? '').toString(),
        detail: (map['card'] ?? '').toString(),
      );
    }).toList();
  }

  void toggleWalletHidden() {
    walletHidden = !walletHidden;
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
    final user = currentUser;
    if (user == null) return;
    if (name != null) {
      final parts = name.trim().split(RegExp(r'\s+'));
      user.firstName = parts.isEmpty ? user.firstName : parts.first;
      user.lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }
    if (email != null) user.email = email;
    if (phone != null) user.phone = phone;
    notifyListeners();
  }

  String changePassword({
    required String newPassword,
    required String confirmPassword,
  }) {
    final user = currentUser;
    if (user == null) return 'no_user';
    if (newPassword != confirmPassword) return 'mismatch';
    user.password = newPassword;
    notifyListeners();
    return 'ok';
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

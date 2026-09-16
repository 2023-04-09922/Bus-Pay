import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccountStore {
  static const _usernameKey = 'hidden_username';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String?> readUsername() {
    return _storage.read(key: _usernameKey);
  }

  static Future<void> saveUsername(String username) {
    return _storage.write(key: _usernameKey, value: username);
  }
}

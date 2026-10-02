import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/app_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiService {
  static const _discoverTimeout = Duration(milliseconds: 900);
  static const _requestTimeout = Duration(milliseconds: 4500);
  static final _client = http.Client();
  static String _baseUrl = AppConfig.apiHosts.first;
  static bool _ready = false;

  static Future<void> warmup() async {
    try {
      await _discover();
    } catch (_) {}
  }

  static Future<void> _discover({bool force = false}) async {
    if (_ready && !force) return;
    _ready = false;
    final hits = await Future.wait(
      AppConfig.apiHosts.map((host) async {
        try {
          final response = await _client
              .get(Uri.parse('$host/health'))
              .timeout(_discoverTimeout);
          if (response.statusCode >= 200 && response.statusCode < 500) {
            return host;
          }
        } catch (_) {}
        return null;
      }),
    );
    for (final host in AppConfig.apiHosts) {
      if (hits.contains(host)) {
        _baseUrl = host;
        _ready = true;
        return;
      }
    }
    throw ApiException('Server did not respond');
  }

  static Future<Map<String, dynamic>> login({
    required String pin,
    String? username,
    String? phone,
  }) {
    final body = <String, dynamic>{'pin': pin};
    final u = username?.trim() ?? '';
    final p = phone?.trim() ?? '';
    if (u.isNotEmpty) body['username'] = u;
    if (p.isNotEmpty) body['phone'] = p;
    return _post('/auth/login', body);
  }

  static Future<Map<String, dynamic>> agentLogin({
    required String email,
    required String password,
  }) {
    return _post('/auth/agent/login', {
      'email': email,
      'password': password,
    });
  }

  static Future<Map<String, dynamic>> forgotAgentPassword({
    required String email,
  }) {
    return _post('/auth/agent/forgot-password', {
      'email': email,
    });
  }

  static Future<Map<String, dynamic>> resetAgentPassword({
    required String email,
    required String code,
    required String password,
    required String confirmPassword,
  }) {
    return _post('/auth/agent/reset-password', {
      'email': email,
      'code': code,
      'password': password,
      'confirmPassword': confirmPassword,
    });
  }

  static Future<Map<String, dynamic>> checkAvailability({
    String? phone,
    String? nida,
  }) {
    final q = <String, String>{};
    if (phone != null && phone.trim().isNotEmpty) q['phone'] = phone.trim();
    if (nida != null && nida.trim().isNotEmpty) q['nida'] = nida.trim();
    final query = q.entries
        .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return _get('/auth/check?$query');
  }

  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String nida,
    required String pin,
    required String confirmPin,
  }) {
    return _post('/auth/register/conductor', {
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'phone': phone.trim(),
      'nida': nida.trim(),
      'pin': pin,
      'confirmPin': confirmPin,
    });
  }

  static Future<Map<String, dynamic>> changePin({
    required String token,
    required String currentPin,
    required String newPin,
    required String confirmPin,
  }) {
    return _post(
      '/auth/change-pin',
      {
        'currentPin': currentPin,
        'newPin': newPin,
        'confirmPin': confirmPin,
      },
      token: token,
    );
  }

  static Future<Map<String, dynamic>> changeAgentPassword({
    required String token,
    required String currentPassword,
    required String password,
    required String confirmPassword,
  }) {
    return _post(
      '/auth/agent/change-password',
      {
        'currentPassword': currentPassword,
        'password': password,
        'confirmPassword': confirmPassword,
      },
      token: token,
    );
  }

  static Future<Map<String, dynamic>> forgotPin({
    required String phone,
    required String nida,
  }) {
    return _post('/auth/forgot-pin', {
      'phone': phone.trim(),
      'nida': nida.trim(),
    });
  }

  static Future<Map<String, dynamic>> resetPin({
    required String phone,
    required String nida,
    required String code,
    required String pin,
    required String confirmPin,
  }) {
    return _post('/auth/reset-pin', {
      'phone': phone.trim(),
      'nida': nida.trim(),
      'code': code.trim(),
      'pin': pin,
      'confirmPin': confirmPin,
    });
  }

  static Future<Map<String, dynamic>> scanCard({
    required String token,
    required String nfcUid,
  }) {
    return _post(
      '/platform/cards/scan',
      {'nfcUid': nfcUid.trim()},
      token: token,
    );
  }

  static Future<Map<String, dynamic>> activateCard({
    required String token,
    required String firstName,
    required String lastName,
    required String phone,
    required String cardNumber,
    required String nfcUid,
    String? nida,
  }) {
    return _post(
      '/platform/cards/activate',
      {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'phone': phone.trim(),
        'cardNumber': cardNumber.trim(),
        'nfcUid': nfcUid.trim(),
        if (nida != null && nida.trim().isNotEmpty) 'nida': nida.trim(),
      },
      token: token,
    );
  }

  static Future<Map<String, dynamic>> issueCard({
    required String token,
    required String firstName,
    required String lastName,
    required String phone,
    String? nida,
    String? serialNumber,
    String? nfcUid,
    int initialLoad = 0,
  }) {
    return _post(
      '/platform/cards',
      {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'phone': phone.trim(),
        if (nida != null && nida.trim().isNotEmpty) 'nida': nida.trim(),
        if (serialNumber != null && serialNumber.trim().isNotEmpty)
          'serialNumber': serialNumber.trim(),
        if (serialNumber != null && serialNumber.trim().isNotEmpty)
          'cardNumber': serialNumber.trim(),
        if (nfcUid != null && nfcUid.trim().isNotEmpty) 'nfcUid': nfcUid.trim(),
        'initialLoad': initialLoad,
      },
      token: token,
    );
  }

  static Future<Map<String, dynamic>> previewTopUpScan({
    required String token,
    required String nfcUid,
  }) {
    return _post(
      '/platform/wallets/topup/scan',
      {'nfcUid': nfcUid.trim()},
      token: token,
    );
  }

  static Future<Map<String, dynamic>> getTransactions({
    required String token,
  }) {
    return _get('/platform/transactions', token: token);
  }

  static Future<Map<String, dynamic>> tapPay({
    required String token,
    required int amount,
    String? serialNumber,
    String? nfcUid,
    String serviceType = 'TRANSPORT',
    String merchantCode = 'DLD-PLATFORM',
  }) {
    return _post(
      '/platform/payments/tap',
      {
        'amount': amount,
        'serviceType': serviceType,
        'merchantCode': merchantCode,
        if (serialNumber != null && serialNumber.trim().isNotEmpty)
          'serialNumber': serialNumber.trim(),
        if (nfcUid != null && nfcUid.trim().isNotEmpty) 'nfcUid': nfcUid.trim(),
      },
      token: token,
    );
  }

  static Future<Map<String, dynamic>> lookupCard({
    required String token,
    String? serialNumber,
    String? nfcUid,
  }) {
    if (nfcUid != null && nfcUid.trim().isNotEmpty) {
      return _get(
        '/platform/cards/uid/${Uri.encodeComponent(nfcUid.trim())}',
        token: token,
      );
    }
    if (serialNumber == null || serialNumber.trim().isEmpty) {
      throw ApiException('serialNumber or nfcUid is required');
    }
    return _get(
      '/platform/cards/${Uri.encodeComponent(serialNumber.trim())}',
      token: token,
    );
  }

  static Future<Map<String, dynamic>> renewCard({
    required String token,
    required String serialNumber,
    String? nfcUid,
    String? firstName,
    String? lastName,
    String? phone,
    int amount = 0,
  }) {
    return _post(
      '/platform/cards/${Uri.encodeComponent(serialNumber.trim())}/renew',
      {
        if (nfcUid != null && nfcUid.trim().isNotEmpty) 'nfcUid': nfcUid.trim(),
        if (firstName != null && firstName.trim().isNotEmpty)
          'firstName': firstName.trim(),
        if (lastName != null && lastName.trim().isNotEmpty)
          'lastName': lastName.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        'amount': amount,
      },
      token: token,
    );
  }

  static Future<Map<String, dynamic>> freezeCard({
    required String token,
    required String serialNumber,
  }) {
    return _post(
      '/platform/cards/${Uri.encodeComponent(serialNumber.trim())}/freeze',
      const {},
      token: token,
    );
  }

  static Future<Map<String, dynamic>> topUpWallet({
    required String token,
    required int amount,
    String? serialNumber,
    String? nfcUid,
    String? phone,
    String? walletAccountNumber,
  }) {
    return _post(
      '/platform/wallets/topup',
      {
        'amount': amount,
        if (serialNumber != null && serialNumber.trim().isNotEmpty)
          'serialNumber': serialNumber.trim(),
        if (nfcUid != null && nfcUid.trim().isNotEmpty) 'nfcUid': nfcUid.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (walletAccountNumber != null &&
            walletAccountNumber.trim().isNotEmpty)
          'walletAccountNumber': walletAccountNumber.trim(),
      },
      token: token,
    );
  }

  static Future<Map<String, dynamic>> lookupWakalaTill({
    required String token,
    required String tillNumber,
  }) {
    return _post(
      '/platform/agents/till/lookup',
      {'tillNumber': tillNumber.trim()},
      token: token,
    );
  }

  static Future<Map<String, dynamic>> withdrawToWakala({
    required String token,
    required String tillNumber,
    required int amount,
  }) {
    return _post(
      '/platform/withdrawals',
      {
        'tillNumber': tillNumber.trim(),
        'amount': amount,
      },
      token: token,
    );
  }

  static Future<http.Response> _send(
    Future<http.Response> Function(String base) run,
  ) async {
    await _discover();
    try {
      return await run(_baseUrl).timeout(_requestTimeout);
    } on TimeoutException {
      _ready = false;
    } on SocketException {
      _ready = false;
    } on HttpException {
      _ready = false;
    } on http.ClientException {
      _ready = false;
    }
    await _discover(force: true);
    try {
      return await run(_baseUrl).timeout(_requestTimeout);
    } on TimeoutException {
      throw ApiException('Server did not respond', statusCode: 408);
    } on SocketException {
      throw ApiException('Server did not respond');
    } on HttpException {
      throw ApiException('Server did not respond');
    } on http.ClientException {
      throw ApiException('Server did not respond');
    }
  }

  static Future<Map<String, dynamic>> _get(
    String path, {
    String? token,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await _send(
      (base) => _client.get(Uri.parse('$base$path'), headers: headers),
    );
    return _decode(response, authorized: token != null && token.isNotEmpty);
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await _send(
      (base) => _client.post(
        Uri.parse('$base$path'),
        headers: headers,
        body: jsonEncode(body),
      ),
    );
    return _decode(response, authorized: token != null && token.isNotEmpty);
  }

  /// Called when an authenticated request gets 401 (e.g. signed in elsewhere).
  static void Function()? onSessionExpired;

  static Map<String, dynamic> _decode(
    http.Response response, {
    bool authorized = false,
  }) {
    Map<String, dynamic> data = {};
    try {
      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      }
    } catch (_) {}

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    if (authorized && response.statusCode == 401) {
      onSessionExpired?.call();
    }

    final message = data['message'];
    throw ApiException(
      message is List
          ? message.join(', ')
          : (message?.toString() ?? 'Request failed'),
      statusCode: response.statusCode,
    );
  }
}

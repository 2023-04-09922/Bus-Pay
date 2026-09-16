import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiService {
  static const List<String> _hosts = [
    'http://127.0.0.1:3000',
    'http://10.0.2.2:3000',
    'http://192.168.20.93:3000',
    'http://192.168.137.1:3000',
    'http://192.168.5.1:3000',
  ];

  static const _probeTimeout = Duration(milliseconds: 700);
  static const _requestTimeout = Duration(seconds: 4);
  static final _client = http.Client();
  static String? _baseUrl;

  static Future<String?> _probe(String host) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$host/health'),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(_probeTimeout);
      return response.statusCode == 200 ? host : null;
    } catch (_) {
      return null;
    }
  }

  static Future<String> _base() async {
    if (_baseUrl != null) return _baseUrl!;

    final probes = _hosts.map(_probe).toList();
    final results = await Future.wait(probes);
    for (var i = 0; i < _hosts.length; i++) {
      if (results[i] != null) {
        _baseUrl = results[i];
        return _baseUrl!;
      }
    }
    throw ApiException('Server did not respond');
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String pin,
  }) {
    return _post('/auth/login', {
      'username': username,
      'pin': pin,
    });
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

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    late final http.Response response;
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final base = await _base();
      response = await _client
          .post(
            Uri.parse('$base$path'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(_requestTimeout);
    } on ApiException {
      rethrow;
    } on SocketException {
      _baseUrl = null;
      throw ApiException('Server did not respond');
    } on HttpException {
      _baseUrl = null;
      throw ApiException('Server did not respond');
    } on TimeoutException {
      _baseUrl = null;
      throw ApiException('Server did not respond');
    }

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

    final message = data['message'];
    throw ApiException(
      message is List
          ? message.join(', ')
          : (message?.toString() ?? 'Request failed'),
      statusCode: response.statusCode,
    );
  }
}

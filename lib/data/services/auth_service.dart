import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api_client.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await _dio.post(
      '/users/login',
      data: {'email': email, 'password': password},
    );

    // try to extract token from headers
    String? token;
    try {
      final setCookie = resp.headers.map['set-cookie']?.first;
      if (setCookie != null) {
        final match = RegExp(r'token=([^;]+)').firstMatch(setCookie);
        if (match != null) token = match.group(1);
      }
    } catch (_) {}

    if (token == null) {
      try {
        final data = resp.data;
        if (data is Map &&
            data['data'] is Map &&
            data['data']['accessToken'] != null)
          token = data['data']['accessToken'];
        if (data is Map && data['token'] != null) token = data['token'];
      } catch (_) {}
    }

    if (token != null) await _storage.write(key: 'jwt_token', value: token);

    return resp.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _dio.post('/users/logout');
    await _storage.delete(key: 'jwt_token');
  }
}

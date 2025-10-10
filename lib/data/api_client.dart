import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/env.dart';
import 'token_storage.dart';

final _tokenStorage = TokenStorage();

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  ApiClient._internal() {
    dio =
        Dio(
            BaseOptions(
              baseUrl: Env.baseUrl,
              connectTimeout: const Duration(seconds: 30),
            ),
          )
          ..interceptors.add(
            QueuedInterceptorsWrapper(
              onRequest: (options, handler) async {
                final token = await _tokenStorage.read('jwt_token');
                if (token != null)
                  options.headers['Authorization'] = 'Bearer $token';
                if (kDebugMode) {
                  debugPrint('--> ${options.method} ${options.uri}');
                }
                return handler.next(options);
              },
              onError: (e, handler) async {
                if (e.response?.statusCode == 401) {
                  await _tokenStorage.delete('jwt_token');
                }
                return handler.next(e);
              },
            ),
          );
  }
}

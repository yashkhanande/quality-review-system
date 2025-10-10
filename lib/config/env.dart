import 'package:flutter/foundation.dart';

class Env {
  // Use localhost when running on web (flutter run -d chrome).
  // Use Android emulator host mapping for non-web (10.0.2.2).
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000/api/v1';
    return 'http://10.0.2.2:5000/api/v1';
  }
}

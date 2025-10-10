import 'dart:html' as html;

class TokenStorage {
  Future<void> write(String key, String value) async {
    html.window.localStorage[key] = value;
  }

  Future<String?> read(String key) async {
    return html.window.localStorage[key];
  }

  Future<void> delete(String key) async {
    html.window.localStorage.remove(key);
  }
}

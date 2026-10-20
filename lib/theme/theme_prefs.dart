import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Where the chosen theme ('system', 'light' or 'dark') is remembered between launches.
abstract class ThemePrefs {
  Future<String?> read();
  Future<void> write(String value);
}

class SecureThemePrefs implements ThemePrefs {
  SecureThemePrefs({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'calora_theme';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);
}

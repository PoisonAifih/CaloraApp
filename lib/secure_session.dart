import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'session.dart';

class SecureSessionStore implements SessionStore {
  SecureSessionStore({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'calora_session';
  final FlutterSecureStorage _storage;

  @override
  Future<void> clear() => _storage.delete(key: _key);

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);
}

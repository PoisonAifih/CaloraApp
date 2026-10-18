abstract class SessionStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

class MemorySessionStore implements SessionStore {
  String? _token;

  @override
  Future<void> clear() async {
    _token = null;
  }

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async {
    _token = token;
  }
}

abstract class SessionStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
  Future<String?> readBaseUrl() async => null;
  Future<void> writeBaseUrl(String url) async {}
}

class MemorySessionStore implements SessionStore {
  String? _token;
  String? baseUrl;

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

  @override
  Future<String?> readBaseUrl() async => baseUrl;

  @override
  Future<void> writeBaseUrl(String url) async {
    baseUrl = url;
  }
}

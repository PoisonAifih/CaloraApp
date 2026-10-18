import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:calora_app/api/calora_client.dart';
import 'package:calora_app/session.dart';

void main() {
  test('login stores the token and a 401 clears it', () async {
    final store = MemorySessionStore();
    var calls = 0;
    final client = CaloraClient(
      session: store,
      baseUrl: 'http://example.test',
      httpClient: MockClient((request) async {
        calls += 1;
        if (request.method == 'POST' && request.url.path == '/api/session') {
          return http.Response(
            '{"sessionToken":"abc","user":{"id":"1","name":"Dave","email":null,"role":"USER","profile":null}}',
            200,
          );
        }
        expect(request.headers['cookie'], 'calora_session=abc');
        return http.Response('{"error":"Authentication required"}', 401);
      }),
    );

    final user = await client.login('Dave', 'secret');
    expect(user.name, 'Dave');
    expect(await store.read(), 'abc');

    await expectLater(client.dashboard(), throwsA(isA<CaloraException>().having((error) => error.status, 'status', 401)));
    expect(await store.read(), isNull);
    expect(calls, 2);
  });
}

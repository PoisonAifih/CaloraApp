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

  test('guest login posts to the guest endpoint and stores the token', () async {
    final store = MemorySessionStore();
    final client = CaloraClient(
      session: store,
      baseUrl: 'http://example.test/calora',
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/calora/api/session/guest');
        return http.Response(
          '{"sessionToken":"guest-token","user":{"id":"guest_1","name":"Guest ab12","email":null,"role":"GUEST","profile":null}}',
          200,
        );
      }),
    );

    final user = await client.loginAsGuest();
    expect(user.role, 'GUEST');
    expect(await store.read(), 'guest-token');
  });

  test('updateFood puts to the entry and keeps sugar, sodium and confidence', () async {
    final client = CaloraClient(
      session: MemorySessionStore(),
      baseUrl: 'http://example.test/calora',
      httpClient: MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.path, '/calora/api/food/food_1');
        expect(request.body, contains('"createdAt":"2026-11-23T01:00:00.000Z"'));
        return http.Response(
          '{"id":"food_1","meal":"Soto","category":"lunch","kcal":420,"protein":25,"carbs":40,"fat":14,"sugar":3,"sodium":900,"source":"PHOTO_ESTIMATE","confidence":0.7,"createdAt":"2026-11-23T01:00:00.000Z"}',
          200,
        );
      }),
    );

    final entry = await client.updateFood('food_1', {'meal': 'Soto', 'kcal': 420, 'createdAt': '2026-11-23T01:00:00.000Z'});
    expect(entry.sodium, 900);
    expect(entry.sugar, 3);
    expect(entry.confidence, 0.7);
  });
}

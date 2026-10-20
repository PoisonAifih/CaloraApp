import 'package:flutter_test/flutter_test.dart';
import 'package:calora_app/api/calora_client.dart';
import 'package:calora_app/app.dart';
import 'package:calora_app/session.dart';
import 'package:calora_app/store.dart';

void main() {
  testWidgets('shows sign in when logged out', (tester) async {
    final store = CaloraStore(CaloraClient(session: MemorySessionStore(), baseUrl: 'http://example.test'));
    await tester.pumpWidget(CaloraApp(store: store));
    await tester.pump();
    await tester.pump();
    expect(find.text('Masuk'), findsWidgets);
  });
}

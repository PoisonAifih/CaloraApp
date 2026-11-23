import 'package:flutter_test/flutter_test.dart';
import 'package:calora_app/api/calora_client.dart';
import 'package:calora_app/app.dart';
import 'package:calora_app/l10n.dart';
import 'package:calora_app/session.dart';
import 'package:calora_app/store.dart';

void main() {
  tearDown(() => AppLanguage.code = 'id');

  testWidgets('shows sign in when logged out', (tester) async {
    final store = CaloraStore(CaloraClient(session: MemorySessionStore(), baseUrl: 'http://example.test'));
    await tester.pumpWidget(CaloraApp(store: store));
    await tester.pump();
    await tester.pump();
    expect(find.text('Masuk'), findsWidgets);
    expect(find.text('Lanjut sebagai tamu'), findsOneWidget);
    expect(find.text('Masuk dengan Google segera hadir'), findsOneWidget);
    expect(find.text('Apple ID'), findsNothing);
  });

  testWidgets('switching to English redraws the sign-in screen', (tester) async {
    final store = CaloraStore(CaloraClient(session: MemorySessionStore(), baseUrl: 'http://example.test'));
    await tester.pumpWidget(CaloraApp(store: store));
    await tester.pump();
    await tester.pump();
    await store.setLanguage('en');
    await tester.pump();
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Continue as guest'), findsOneWidget);
    expect(find.text('Lanjut sebagai tamu'), findsNothing);
  });
}

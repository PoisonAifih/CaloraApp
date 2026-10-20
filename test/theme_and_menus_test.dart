import 'dart:convert';

import 'package:calora_app/api/calora_client.dart';
import 'package:calora_app/app.dart';
import 'package:calora_app/session.dart';
import 'package:calora_app/store.dart';
import 'package:calora_app/theme/calora_theme.dart';
import 'package:calora_app/theme/theme_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _MemoryThemePrefs implements ThemePrefs {
  _MemoryThemePrefs([this.value]);

  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async => this.value = value;
}

CaloraClient _client() {
  return CaloraClient(
    session: MemorySessionStore(),
    baseUrl: 'http://example.test',
    httpClient: MockClient((request) async {
      if (request.url.path == '/api/menus') {
        return http.Response(
          jsonEncode([
            {'id': 'P04', 'name': 'Ayam panggang', 'mealType': 'LUNCH', 'calories': 620, 'proteinG': 48, 'carbsG': 70, 'fatG': 16},
          ]),
          200,
        );
      }
      return http.Response('{}', 401);
    }),
  );
}

void main() {
  testWidgets('saved dark theme is restored and can be switched back', (tester) async {
    final prefs = _MemoryThemePrefs('dark');
    final store = CaloraStore(_client(), themePrefs: prefs);
    await tester.pumpWidget(CaloraApp(store: store));
    await tester.pump();
    await tester.pump();
    expect(store.themeMode, ThemeMode.dark);
    expect(CaloraColors.dark, isTrue);

    await store.setThemeMode(ThemeMode.light);
    await tester.pump();
    expect(CaloraColors.dark, isFalse);
    expect(prefs.value, 'light');
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, CaloraColors.backdrop);
  });

  test('menus load from the catalog endpoint', () async {
    final store = CaloraStore(_client());
    await store.loadMenus();
    expect(store.menus, hasLength(1));
    expect(store.menus!.first.name, 'Ayam panggang');
    expect(store.menus!.first.calories, 620);
  });
}

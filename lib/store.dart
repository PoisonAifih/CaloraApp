import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/foundation.dart';

import 'api/calora_client.dart';
import 'api/models.dart';
import 'theme/theme_prefs.dart';

class CaloraStore extends ChangeNotifier {
  CaloraStore(this.client, {this.themePrefs});

  final CaloraClient client;
  final ThemePrefs? themePrefs;
  bool ready = false;
  bool signedIn = false;
  CaloraUser? user;
  Dashboard? dashboard;
  String? error;

  ThemeMode themeMode = ThemeMode.system;

  /// Active catering menus; null until loaded.
  List<CateringMenu>? menus;

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();
    try {
      await themePrefs?.write(mode.name);
    } catch (_) {}
  }

  Future<void> _loadThemeMode() async {
    try {
      final saved = await themePrefs?.read();
      themeMode = ThemeMode.values.firstWhere((mode) => mode.name == saved, orElse: () => ThemeMode.system);
    } catch (_) {}
  }

  Future<void> loadMenus() async {
    try {
      menus = await client.menus();
      notifyListeners();
    } on CaloraException catch (_) {
      menus ??= [];
      notifyListeners();
    }
  }

  /// Catering tokens. Kept on the phone only until the server owns a balance.
  int tokenBalance = 20;

  void addTokens(int amount) {
    tokenBalance += amount;
    notifyListeners();
  }

  void spendTokens(int amount) {
    tokenBalance -= amount;
    notifyListeners();
  }

  Future<void> bootstrap() async {
    await _loadThemeMode();
    try {
      user = await client.current();
      signedIn = user != null;
      error = null;
      if (signedIn) await _load();
    } on CaloraException catch (e) {
      signedIn = false;
      error = e.status == 401 ? null : e.message;
    } finally {
      ready = true;
      notifyListeners();
    }
  }

  Future<void> login(String username, String password) async {
    user = await client.login(username, password);
    signedIn = true;
    error = null;
    notifyListeners();
    await refresh();
  }

  Future<void> logout() async {
    await client.logout();
    user = null;
    dashboard = null;
    signedIn = false;
    error = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    try {
      await _load();
      error = null;
    } on CaloraException catch (e) {
      if (e.status == 401) {
        signedIn = false;
        user = null;
        dashboard = null;
      }
      error = e.message;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> _load() async {
    dashboard = await client.dashboard();
    if (dashboard?.profile != null) {
      user = CaloraUser(
        id: user?.id ?? '',
        name: user?.name ?? '',
        email: user?.email,
        role: user?.role ?? 'USER',
        profile: dashboard!.profile,
      );
    }
  }
}

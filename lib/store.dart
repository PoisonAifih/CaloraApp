import 'package:flutter/foundation.dart';

import 'api/calora_client.dart';
import 'api/models.dart';

class CaloraStore extends ChangeNotifier {
  CaloraStore(this.client);

  final CaloraClient client;
  bool ready = false;
  bool signedIn = false;
  CaloraUser? user;
  Dashboard? dashboard;
  String? error;

  Future<void> bootstrap() async {
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

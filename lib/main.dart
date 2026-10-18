import 'package:flutter/widgets.dart';

import 'api/calora_client.dart';
import 'app.dart';
import 'secure_session.dart';
import 'store.dart';
import 'update/github_update.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final session = SecureSessionStore();
  runApp(CaloraApp(
    store: CaloraStore(CaloraClient(session: session)),
    updates: GithubUpdateClient(),
  ));
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'api/calora_client.dart';
import 'app.dart';
import 'secure_session.dart';
import 'store.dart';
import 'theme/theme_prefs.dart';
import 'update/github_update.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    for (final family in ['Inter', 'Oswald']) {
      yield LicenseEntryWithLineBreaks([family], await rootBundle.loadString('assets/fonts/$family-OFL.txt'));
    }
  });
  final session = SecureSessionStore();
  runApp(CaloraApp(
    store: CaloraStore(CaloraClient(session: session), themePrefs: SecureThemePrefs()),
    updates: GithubUpdateClient(),
  ));
}

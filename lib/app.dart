import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/shell_screen.dart';
import 'store.dart';
import 'theme/calora_theme.dart';
import 'update/github_update.dart';
import 'update/update_prompt.dart';

class CaloraScope extends InheritedNotifier<CaloraStore> {
  const CaloraScope({required CaloraStore store, required super.child, super.key}) : super(notifier: store);

  static CaloraStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CaloraScope>();
    assert(scope != null, 'CaloraScope missing');
    return scope!.notifier!;
  }
}

class CaloraApp extends StatefulWidget {
  const CaloraApp({required this.store, this.updates, super.key});

  final CaloraStore store;
  final GithubUpdateClient? updates;

  @override
  State<CaloraApp> createState() => _CaloraAppState();
}

class _CaloraAppState extends State<CaloraApp> {
  @override
  void initState() {
    super.initState();
    widget.store.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    final home = ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        if (!widget.store.ready) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return widget.store.signedIn ? const ShellScreen() : const LoginScreen();
      },
    );
    return CaloraScope(
      store: widget.store,
      child: MaterialApp(
        title: 'Calora',
        theme: caloraTheme(),
        home: widget.updates == null
            ? home
            : UpdateScope(
                client: widget.updates!,
                child: UpdatePrompt(client: widget.updates!, child: home),
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class _CaloraAppState extends State<CaloraApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    CaloraColors.dark = _wantsDark();
    WidgetsBinding.instance.addObserver(this);
    widget.store.addListener(_applyTheme);
    widget.store.bootstrap();
  }

  @override
  void dispose() {
    widget.store.removeListener(_applyTheme);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() => _applyTheme();

  bool _wantsDark() {
    return switch (widget.store.themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark,
    };
  }

  /// Colours are read from [CaloraColors] getters, so a theme switch has to rebuild
  /// every element, including const widgets that would otherwise be skipped.
  void _applyTheme() {
    final dark = _wantsDark();
    if (dark == CaloraColors.dark || !mounted) return;
    CaloraColors.dark = dark;
    setState(() {});
    void rebuild(Element element) {
      element.markNeedsBuild();
      element.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
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
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: CaloraColors.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          child: child!,
        ),
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

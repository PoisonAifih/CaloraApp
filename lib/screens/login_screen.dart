import 'package:flutter/material.dart';

import '../api/calora_client.dart';
import '../app.dart';
import '../theme/calora_theme.dart';
import '../l10n.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _showPassword = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_username.text.trim().isEmpty || _password.text.isEmpty) return;
    await _run(() => CaloraScope.of(context).login(_username.text.trim(), _password.text));
  }

  Future<void> _guest() => _run(() => CaloraScope.of(context).loginAsGuest());

  Future<void> _run(Future<void> Function() signIn) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await signIn();
    } on CaloraException catch (error) {
      if (mounted) setState(() => _error = error.status == 401 ? tr('Wrong username or password') : error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _soon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('{feature} is not available yet', {'feature': tr(feature)}))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CaloraColors.backdrop,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
                decoration: BoxDecoration(color: CaloraColors.canvas, borderRadius: BorderRadius.circular(28)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ColorFiltered(
                        // The line art is black on transparent; flip it to light lines in dark mode.
                        colorFilter: CaloraColors.dark
                            ? const ColorFilter.matrix([-1, 0, 0, 0, 255, 0, -1, 0, 0, 255, 0, 0, -1, 0, 255, 0, 0, 0, 1, 0])
                            : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                        child: Image.asset('assets/images/calora_logo.png', height: 116, semanticLabel: 'Calora'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'EAT SMART,\nLIVE FRESH',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: CaloraText.display, fontSize: 42, fontWeight: FontWeight.w700, color: CaloraColors.heading, height: 1),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [_Dash(CaloraColors.kiwi), _Dash(CaloraColors.sunshine), _Dash(CaloraColors.carrot)],
                    ),
                    const SizedBox(height: 28),
                    _Label(tr('Email or username')),
                    TextField(
                      controller: _username,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(fontSize: 17),
                      decoration: _field(),
                    ),
                    const SizedBox(height: 22),
                    const _Label('Password'),
                    TextField(
                      controller: _password,
                      obscureText: !_showPassword,
                      onSubmitted: (_) => _busy ? null : _submit(),
                      style: const TextStyle(fontSize: 17),
                      decoration: _field().copyWith(
                        suffixIcon: IconButton(
                          tooltip: _showPassword ? tr('Hide password') : tr('Show password'),
                          onPressed: () => setState(() => _showPassword = !_showPassword),
                          icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: CaloraColors.inkMuted),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _soon('Reset password'),
                        child: Text(tr('Forgot password?'), style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(_error!, style: TextStyle(color: CaloraColors.danger)),
                      ),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontFamily: CaloraText.body, fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      child: Text(_busy ? tr('Signing in…') : tr('Sign in')),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton(
                      onPressed: _busy ? null : _guest,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CaloraColors.ink,
                        side: BorderSide(color: CaloraColors.sand),
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontFamily: CaloraText.body, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      child: Text(tr('Continue as guest')),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      tr('Login with Google coming soon'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: CaloraColors.inkMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _field() {
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent, width: 2));
    return InputDecoration(
      filled: true,
      fillColor: CaloraColors.cream,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(borderSide: BorderSide(color: CaloraColors.heading, width: 2)),
    );
  }

}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: CaloraColors.inkMuted)),
    );
  }
}

class _Dash extends StatelessWidget {
  const _Dash(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 7,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
    );
  }
}

import 'package:flutter/material.dart';

import '../api/calora_client.dart';
import '../app.dart';
import '../theme/calora_theme.dart';
import '../widgets/calora_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final store = CaloraScope.of(context);
      await store.login(_username.text.trim(), _password.text);
    } on CaloraException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: CaloraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('CALORA', style: CaloraText.title),
                    const SizedBox(height: 8),
                    const Text('Sign in to log meals, workouts, and weight.', style: TextStyle(color: CaloraColors.inkMuted)),
                    const SizedBox(height: 20),
                    TextField(controller: _username, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Username')),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      onSubmitted: (_) => _busy ? null : _submit(),
                      decoration: const InputDecoration(labelText: 'Password'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: CaloraColors.danger)),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(onPressed: _busy ? null : _submit, child: Text(_busy ? 'Signing in' : 'Sign in')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

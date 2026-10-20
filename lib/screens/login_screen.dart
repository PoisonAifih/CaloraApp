import 'package:flutter/material.dart';

import '../api/calora_client.dart';
import '../app.dart';
import '../theme/calora_theme.dart';

const _sand = Color(0xFFE4D6B1);

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
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final store = CaloraScope.of(context);
      await store.login(_username.text.trim(), _password.text);
    } on CaloraException catch (error) {
      if (mounted) setState(() => _error = error.status == 401 ? 'Username atau password salah' : error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _soon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$feature belum tersedia')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6EADC),
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
                    const Center(child: SizedBox(width: 104, height: 104, child: CustomPaint(painter: _CarrotPainter()))),
                    const SizedBox(height: 24),
                    const Text(
                      'EAT SMART,\nLIVE FRESH',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: CaloraText.display, fontSize: 42, fontWeight: FontWeight.w700, color: CaloraColors.forest, height: 1),
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [_Dash(CaloraColors.kiwi), _Dash(CaloraColors.sunshine), _Dash(CaloraColors.carrot)],
                    ),
                    const SizedBox(height: 28),
                    const _Label('Email atau username'),
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
                          tooltip: _showPassword ? 'Sembunyikan password' : 'Tampilkan password',
                          onPressed: () => setState(() => _showPassword = !_showPassword),
                          icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: CaloraColors.inkMuted),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _soon('Reset password'),
                        child: const Text('Lupa Password?', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(_error!, style: const TextStyle(color: CaloraColors.danger)),
                      ),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontFamily: CaloraText.body, fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      child: Text(_busy ? 'Masuk…' : 'Masuk'),
                    ),
                    const SizedBox(height: 32),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: _sand)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Text('atau masuk dengan', style: TextStyle(color: CaloraColors.inkMuted)),
                        ),
                        Expanded(child: Divider(color: _sand)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _social('G', 'Google', () => _soon('Masuk dengan Google'))),
                        const SizedBox(width: 14),
                        Expanded(child: _social('A', 'Apple ID', () => _soon('Masuk dengan Apple ID'))),
                      ],
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
      focusedBorder: border.copyWith(borderSide: const BorderSide(color: CaloraColors.forest, width: 2)),
    );
  }

  Widget _social(String mark, String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: CaloraColors.ink,
        side: const BorderSide(color: _sand),
        minimumSize: const Size.fromHeight(58),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontFamily: CaloraText.body, fontSize: 16, fontWeight: FontWeight.w600),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: CaloraColors.cream,
            child: Text(mark, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: CaloraColors.forest)),
          ),
          const SizedBox(width: 8),
          Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
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
      child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: CaloraColors.inkMuted)),
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

/// Stand-in brand mark (same drawing as the web login) until the illustration is added as an asset.
class _CarrotPainter extends CustomPainter {
  const _CarrotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 120, size.height / 120);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final leaves = Path()
      ..moveTo(78, 22)
      ..quadraticBezierTo(69, 28, 67, 39)
      ..moveTo(86, 30)
      ..quadraticBezierTo(75, 32, 69, 41)
      ..moveTo(70, 16)
      ..quadraticBezierTo(69, 28, 73, 37);
    canvas.drawPath(leaves, line..color = CaloraColors.forest..strokeWidth = 5);

    final body = Path()
      ..moveTo(70, 40)
      ..cubicTo(78, 46, 79, 56, 73, 64)
      ..lineTo(38, 104)
      ..cubicTo(34, 109, 26, 107, 26, 100)
      ..lineTo(32, 56)
      ..cubicTo(34, 46, 44, 36, 56, 35)
      ..cubicTo(61, 35, 66, 37, 70, 40)
      ..close();
    canvas.drawPath(body, Paint()..color = CaloraColors.carrot);
    canvas.drawPath(body, line..color = CaloraColors.charcoal..strokeWidth = 4);

    final marks = Path()
      ..moveTo(44, 56)
      ..lineTo(54, 62)
      ..moveTo(38, 74)
      ..lineTo(48, 79)
      ..moveTo(34, 90)
      ..lineTo(42, 94);
    canvas.drawPath(marks, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

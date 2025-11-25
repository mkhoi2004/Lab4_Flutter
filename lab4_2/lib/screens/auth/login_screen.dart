import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;
  String? err;
  String? info;

  Future<void> _login() async {
    setState(() {
      loading = true;
      err = null;
      info = null;
    });
    try {
      await context.read<AuthProvider>().signIn(
        email.text.trim(),
        pass.text.trim(),
      );
    } catch (e) {
      setState(() => err = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _reset() async {
    setState(() {
      err = null;
      info = null;
    });
    try {
      await context.read<AuthProvider>().resetPassword(email.text.trim());
      setState(() => info = 'Đã gửi email đặt lại mật khẩu.');
    } catch (e) {
      setState(() => err = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: pass,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
            ),
            const SizedBox(height: 12),
            if (err != null)
              Text(err!, style: const TextStyle(color: Colors.red)),
            if (info != null)
              Text(info!, style: const TextStyle(color: Colors.green)),

            FilledButton(
              onPressed: loading ? null : _login,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Đăng nhập'),
            ),

            TextButton(
              onPressed: loading ? null : _reset,
              child: const Text('Quên mật khẩu?'),
            ),

            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
              child: const Text('Đăng ký tài khoản'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }
}

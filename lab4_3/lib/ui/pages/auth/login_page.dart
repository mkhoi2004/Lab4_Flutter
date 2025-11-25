import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  bool _register = false;
  String _email = '', _pass = '';
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(_register ? 'Đăng ký' : 'Đăng nhập')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    onSaved: (v) => _email = v!.trim(),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Nhập email' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Mật khẩu'),
                    obscureText: true,
                    onSaved: (v) => _pass = v!.trim(),
                    validator: (v) =>
                        (v == null || v.length < 6) ? '≥ 6 ký tự' : null,
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            if (!_form.currentState!.validate()) return;
                            _form.currentState!.save();
                            setState(() => _loading = true);
                            try {
                              if (_register) {
                                await auth.signUp(_email, _pass);
                              } else {
                                await auth.signIn(_email, _pass);
                              }
                            } catch (e) {
                              setState(() => _error = '$e');
                            } finally {
                              if (mounted) setState(() => _loading = false);
                            }
                          },
                    child: Text(_register ? 'Tạo tài khoản' : 'Đăng nhập'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _register = !_register),
                    child: Text(
                      _register
                          ? 'Đã có tài khoản? Đăng nhập'
                          : 'Chưa có tài khoản? Đăng ký',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

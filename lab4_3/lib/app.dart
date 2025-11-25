import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'ui/pages/auth/login_page.dart';
import 'ui/pages/home_page.dart';
import 'services/fcm_service.dart'; // <-- thêm

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    // Khi có user → init FCM + bind token
    if (user != null) {
      FcmService().init().then((_) => FcmService().bindUser(user.uid));
    }

    return MaterialApp(
      title: 'Library Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: user == null ? const LoginPage() : const HomePage(),
    );
  }
}

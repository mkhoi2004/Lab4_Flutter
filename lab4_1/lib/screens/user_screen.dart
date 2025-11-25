import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            child: Text(
              (user?.email ?? 'U').substring(0, 1).toUpperCase(),
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user?.email ?? 'Chưa đăng nhập',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
            onPressed: user == null
                ? null
                : () async {
                    await FirebaseAuth.instance.signOut();
                  },
          ),
        ],
      ),
    );
  }
}

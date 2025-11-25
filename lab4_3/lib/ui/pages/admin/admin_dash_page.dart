import 'package:flutter/material.dart';
import 'manage_books_page.dart';

class AdminDashPage extends StatelessWidget {
  const AdminDashPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bảng điều khiển thủ thư')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('Quản lý sách'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageBooksPage()),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'books_page.dart';
import 'loans_page.dart';
import 'admin/admin_dash_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final tabs = [const BooksPage(), const LoansPage(), const AdminDashPage()];
    return Scaffold(
      body: tabs[_idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Sách'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Mượn/Trả'),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}

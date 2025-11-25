import 'package:flutter/material.dart';
import 'product_list_screen.dart';
import 'order_list_screen.dart';
import 'user_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _tabs = const [
    ProductListScreen(), // tab 0
    OrderListScreen(), // tab 1
    UserScreen(), // tab 2
  ];

  String get _title {
    switch (_index) {
      case 0:
        return 'Danh sách sản phẩm';
      case 1:
        return 'Đơn hàng';
      case 2:
        return 'Người dùng';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront),
            label: 'Sản phẩm',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Đơn hàng',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Người dùng'),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../provider/cart_provider.dart';
import '../widgets/cart_item.dart'; // ✅ đúng path (không có dấu / đầu)
import '../services/order_service.dart';
import 'auth/login_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _checkout(BuildContext context, CartProvider cart) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(returnToCart: true),
        ),
      );
      return;
    }

    try {
      final orderId = await OrderService.createOrder(cart);
      cart.clear(); // ✅ đúng theo provider của bạn (nếu bạn đặt tên khác thì đổi lại)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đặt hàng thành công! Mã đơn: $orderId')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Thanh toán thất bại: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text('Giỏ hàng trống.'))
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) => CartItemWidget(
                      product: cart.items[i],
                    ), // ✅ đổi tên class
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: const [
                BoxShadow(blurRadius: 4, offset: Offset(0, -2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tổng cộng: ${cart.total.toStringAsFixed(2)} \$',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: cart.items.isEmpty
                      ? null
                      : () => _checkout(context, cart),
                  child: Text(
                    user == null ? 'Đăng nhập để thanh toán' : 'Thanh toán',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

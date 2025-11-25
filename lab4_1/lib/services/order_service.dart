import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../provider/cart_provider.dart';
import '../models/product.dart';

class OrderService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Tạo đơn hàng (yêu cầu user != null). Trả về orderId.
  static Future<String> createOrder(CartProvider cart) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Bạn cần đăng nhập trước khi thanh toán.');
    }

    final items = cart.items
        .map(
          (Product p) => {
            'id': p.id,
            'title': p.title,
            'price': p.price,
            'image': p.image,
          },
        )
        .toList();

    final docRef = await _db.collection('orders').add({
      'uid': user.uid,
      'email': user.email,
      'items': items,
      'total': cart.total,
      'status': 'created',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }
}

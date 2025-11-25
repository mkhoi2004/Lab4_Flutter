import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Bạn cần đăng nhập để xem đơn hàng.'));
    }

    final ordersQuery = FirebaseFirestore.instance
        .collection('orders')
        .where('uid', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: ordersQuery.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Lỗi tải đơn hàng: ${snap.error}'));
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('Chưa có đơn hàng nào.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            final items = (d['items'] as List?) ?? [];
            final total = (d['total'] ?? 0).toDouble();
            final status = (d['status'] ?? 'created').toString();
            final createdAt = d['createdAt'];

            DateTime? time;
            if (createdAt is Timestamp) time = createdAt.toDate();

            return Card(
              child: ExpansionTile(
                title: Text('Đơn #${docs[i].id.substring(0, 6).toUpperCase()}'),
                subtitle: Text(
                  '${time != null ? "${time.day}/${time.month}/${time.year} ${time.hour}:${time.minute.toString().padLeft(2, "0")}" : "Đang cập nhật..."} • $status',
                ),
                trailing: Text(
                  '${total.toStringAsFixed(2)} \$',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  const Divider(height: 1),
                  ...items.map((it) {
                    final m = it as Map<String, dynamic>;
                    return ListTile(
                      leading: Image.network(
                        (m['image'] ?? '').toString(),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                      ),
                      title: Text((m['title'] ?? '').toString()),
                      subtitle: Text(
                        '${(m['price'] ?? 0).toDouble().toStringAsFixed(2)} \$',
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 4),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

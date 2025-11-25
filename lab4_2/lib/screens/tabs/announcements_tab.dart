import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AnnouncementsTab extends StatelessWidget {
  const AnnouncementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .limit(50);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: q.snapshots(),
      builder: (context, snap) {
        if (snap.hasError) return Center(child: Text('Lỗi: ${snap.error}'));
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('Chưa có thông báo'));
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 0),
          itemBuilder: (_, i) {
            final d = docs[i].data();
            return ListTile(
              title: Text(d['title'] ?? ''),
              subtitle: Text(d['body'] ?? ''),
              trailing: Text(
                d['audience'] ?? 'all',
                style: const TextStyle(color: Colors.grey),
              ),
            );
          },
        );
      },
    );
  }
}

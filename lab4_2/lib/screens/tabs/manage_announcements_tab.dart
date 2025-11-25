import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageAnnouncementsTab extends StatefulWidget {
  const ManageAnnouncementsTab({super.key});
  @override
  State<ManageAnnouncementsTab> createState() => _ManageAnnouncementsTabState();
}

class _ManageAnnouncementsTabState extends State<ManageAnnouncementsTab> {
  final title = TextEditingController();
  final body = TextEditingController();

  Future<void> _add() async {
    final t = title.text.trim();
    final b = body.text.trim();
    if (t.isEmpty || b.isEmpty) return;

    await FirebaseFirestore.instance.collection('announcements').add({
      'title': t,
      'body': b,
      'audience': 'all',
      'createdAt': FieldValue.serverTimestamp(),
    });

    title.clear();
    body.clear();
  }

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('createdAt', descending: true);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: body,
                decoration: const InputDecoration(labelText: 'Nội dung'),
              ),
              const SizedBox(height: 8),
              FilledButton(onPressed: _add, child: const Text('Gửi thông báo')),
            ],
          ),
        ),
        const Divider(height: 0),
        Expanded(
          child: StreamBuilder(
            stream: q.snapshots(),
            builder: (context, snap) {
              if (!snap.hasData)
                return const Center(child: CircularProgressIndicator());
              final docs = snap.data!.docs;

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final d = docs[i].data();
                  return ListTile(
                    title: Text(d['title'] ?? ''),
                    subtitle: Text(d['body'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => docs[i].reference.delete(),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    title.dispose();
    body.dispose();
    super.dispose();
  }
}

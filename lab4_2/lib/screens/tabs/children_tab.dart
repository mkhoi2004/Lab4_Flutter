import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ChildrenTab extends StatelessWidget {
  const ChildrenTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final kids = auth.current?.childrenIds ?? [];
    final selected = auth.current?.studentId;

    if (kids.isEmpty) {
      return const Center(child: Text('Chưa có mã học sinh của con.'));
    }

    final q = FirebaseFirestore.instance
        .collection('students')
        .where('studentId', whereIn: kids);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: q.snapshots(),
      builder: (context, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;

        return ListView(
          children: docs.map((doc) {
            final d = doc.data();
            final sid = d['studentId'] as String? ?? '';
            final name = d['fullName'] as String? ?? sid;
            final cls = d['className'] as String? ?? '';

            final isSel = sid == selected;

            return ListTile(
              leading: Icon(isSel ? Icons.check_circle : Icons.circle_outlined),
              title: Text(name),
              subtitle: Text('Mã: $sid • Lớp: $cls'),
              onTap: () => auth.selectChild(sid),
            );
          }).toList(),
        );
      },
    );
  }
}

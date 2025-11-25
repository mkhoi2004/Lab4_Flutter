import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final uid = auth.current?.uid;
    final role = auth.current?.role;

    if (uid == null) return const Center(child: Text('Hãy đăng nhập'));

    final studentId = role == 'parent'
        ? auth.current?.studentId
        : auth.current?.studentId;

    if (role == 'parent' && (studentId == null || studentId.isEmpty)) {
      return const Center(child: Text('Hãy chọn con để xem lịch.'));
    }

    final todayDow = DateTime.now().weekday;

    final query = FirebaseFirestore.instance
        .collection('schedules')
        .where('studentId', isEqualTo: studentId)
        .where('dayOfWeek', isEqualTo: todayDow)
        .orderBy('startAt');

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snap) {
        if (snap.hasError) return Center(child: Text('Lỗi: ${snap.error}'));
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());

        final docs = snap.data!.docs;
        if (docs.isEmpty)
          return const Center(child: Text('Hôm nay chưa có lịch'));

        String fmtTime(Timestamp t) {
          final d = t.toDate();
          return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
        }

        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final d = docs[i].data();
            final startAt = d['startAt'] as Timestamp?;
            final endAt = d['endAt'] as Timestamp?;

            final time = (startAt != null && endAt != null)
                ? '${fmtTime(startAt)}–${fmtTime(endAt)}'
                : '—';

            return ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(d['subject'] ?? ''),
              subtitle: Text(
                'Phòng ${d['room'] ?? ''} • ${d['teacher'] ?? ''}\n$time',
              ),
              isThreeLine: true,
            );
          },
        );
      },
    );
  }
}

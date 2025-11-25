import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentIdDropdown extends StatelessWidget {
  final String? value;
  final void Function(String?) onChanged;
  final String label;
  final bool includeAll; // nếu muốn thêm option "Tất cả" cho teacher xem list

  const StudentIdDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Mã học sinh',
    this.includeAll = false,
  });

  @override
  Widget build(BuildContext context) {
    final studentsStream = FirebaseFirestore.instance
        .collection('students')
        .orderBy('studentId')
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: studentsStream,
      builder: (context, snap) {
        if (snap.hasError) {
          return Text('Lỗi tải học sinh: ${snap.error}');
        }
        if (!snap.hasData) {
          return const LinearProgressIndicator();
        }

        final docs = snap.data!.docs;

        final ids =
            docs
                .map((d) {
                  final data = d.data();
                  return (data['studentId'] ?? d.id).toString();
                })
                .toSet()
                .toList()
              ..sort();

        final items = <DropdownMenuItem<String>>[];

        if (includeAll) {
          items.add(
            const DropdownMenuItem(
              value: '__ALL__',
              child: Text('Tất cả học sinh'),
            ),
          );
        }

        for (final id in ids) {
          items.add(DropdownMenuItem(value: id, child: Text(id)));
        }

        return DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }
}

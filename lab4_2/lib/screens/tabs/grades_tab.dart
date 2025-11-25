import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/student_id_dropdown.dart';

class GradesTab extends StatefulWidget {
  const GradesTab({super.key});

  @override
  State<GradesTab> createState() => _GradesTabState();
}

class _GradesTabState extends State<GradesTab> {
  final _db = FirebaseFirestore.instance;

  // teacher add grade
  String? _selectedStudentId;
  final _subjectCtrl = TextEditingController();
  final _midCtrl = TextEditingController();
  final _finalCtrl = TextEditingController();

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _midCtrl.dispose();
    _finalCtrl.dispose();
    super.dispose();
  }

  Query<Map<String, dynamic>> _buildQuery(AuthProvider auth) {
    final role = auth.current?.role;
    final sid = auth.current?.studentId;

    if (role == 'teacher') {
      return _db.collection('grades').orderBy('updatedAt', descending: true);
    }

    return _db
        .collection('grades')
        .where('studentId', isEqualTo: sid)
        .orderBy('updatedAt', descending: true);
  }

  void _openAddGradeSheet() {
    final auth = context.read<AuthProvider>();
    if (auth.current?.role != 'teacher') return;

    _selectedStudentId = null; // reset mỗi lần mở

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (ctx, setModalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 6),
                    Container(
                      height: 4,
                      width: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Thêm điểm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ✅ dropdown studentId
                    StudentIdDropdown(
                      value: _selectedStudentId,
                      label: 'Chọn mã học sinh',
                      onChanged: (v) {
                        setModalState(() => _selectedStudentId = v);
                      },
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: _subjectCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Môn học',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: _midCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Điểm giữa kỳ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: _finalCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Điểm cuối kỳ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Lưu điểm'),
                        onPressed: () async {
                          final sid = _selectedStudentId;
                          final subject = _subjectCtrl.text.trim();
                          final mid =
                              double.tryParse(_midCtrl.text.trim()) ?? 0;
                          final fin =
                              double.tryParse(_finalCtrl.text.trim()) ?? 0;

                          if (sid == null || sid.isEmpty || subject.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Vui lòng chọn mã HS và nhập môn học',
                                ),
                              ),
                            );
                            return;
                          }

                          await _db.collection('grades').add({
                            'studentId': sid,
                            'subject': subject,
                            'scoreMid': mid,
                            'scoreFinal': fin,
                            'updatedAt': FieldValue.serverTimestamp(),
                          });

                          if (mounted) Navigator.pop(ctx);
                          _subjectCtrl.clear();
                          _midCtrl.clear();
                          _finalCtrl.clear();
                        },
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.current?.role;
    final uid = auth.current?.uid;

    if (uid == null) {
      return const Center(child: Text('Hãy đăng nhập'));
    }

    if (role == 'parent' &&
        (auth.current?.studentId == null || auth.current!.studentId!.isEmpty)) {
      return const Center(child: Text('Hãy chọn con trước khi xem điểm.'));
    }

    if (role == 'student' &&
        (auth.current?.studentId == null || auth.current!.studentId!.isEmpty)) {
      return const Center(child: Text('Tài khoản chưa có mã học sinh.'));
    }

    final query = _buildQuery(auth);

    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Lỗi: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Chưa có điểm'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final d = docs[i].data();
              final subject = (d['subject'] ?? '') as String;
              final mid = d['scoreMid'] ?? 0;
              final fin = d['scoreFinal'] ?? 0;
              final sid = d['studentId'] ?? '';

              return ListTile(
                leading: const Icon(Icons.school),
                title: Text(subject),
                subtitle: Text('Mã HS: $sid\nGiữa kỳ: $mid • Cuối kỳ: $fin'),
                isThreeLine: true,
              );
            },
          );
        },
      ),
      floatingActionButton: role == 'teacher'
          ? FloatingActionButton(
              onPressed: _openAddGradeSheet,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

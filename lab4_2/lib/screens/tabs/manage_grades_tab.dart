import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageGradesTab extends StatefulWidget {
  const ManageGradesTab({super.key});
  @override
  State<ManageGradesTab> createState() => _ManageGradesTabState();
}

class _ManageGradesTabState extends State<ManageGradesTab> {
  final _db = FirebaseFirestore.instance;

  String? selectedStudentId;
  final subjectCtrl = TextEditingController();
  final midCtrl = TextEditingController();
  final finCtrl = TextEditingController();

  @override
  void dispose() {
    subjectCtrl.dispose();
    midCtrl.dispose();
    finCtrl.dispose();
    super.dispose();
  }

  Future<void> _addOrUpdate() async {
    final sid = selectedStudentId?.trim() ?? '';
    final sub = subjectCtrl.text.trim();

    if (sid.isEmpty || sub.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn mã HS và nhập môn học')),
      );
      return;
    }

    final docId = '${sid}_$sub';
    await _db.collection('grades').doc(docId).set({
      'studentId': sid,
      'subject': sub,
      'scoreMid': double.tryParse(midCtrl.text.trim()) ?? 0,
      'scoreFinal': double.tryParse(finCtrl.text.trim()) ?? 0,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã lưu điểm')));

    setState(() {
      selectedStudentId = null;
      subjectCtrl.clear();
      midCtrl.clear();
      finCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradesQuery = _db
        .collection('grades')
        .orderBy('updatedAt', descending: true);

    final studentsStream = _db
        .collection('students')
        .orderBy('studentId')
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          // ✅ đệm theo bàn phím để không overflow
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              // ===== FORM =====
              Card(
                elevation: 0,
                color: Colors.grey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // StudentId dropdown
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: studentsStream,
                        builder: (context, snap) {
                          if (snap.hasError) {
                            return Text('Lỗi tải học sinh: ${snap.error}');
                          }
                          if (!snap.hasData) {
                            return const LinearProgressIndicator();
                          }

                          final ids =
                              snap.data!.docs
                                  .map(
                                    (d) => (d.data()['studentId'] ?? d.id)
                                        .toString(),
                                  )
                                  .toSet()
                                  .toList()
                                ..sort();

                          if (ids.isEmpty) {
                            return const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Chưa có học sinh trong hệ thống',
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          if (selectedStudentId != null &&
                              !ids.contains(selectedStudentId)) {
                            selectedStudentId = null;
                          }

                          return DropdownButtonFormField<String>(
                            value: selectedStudentId,
                            items: ids
                                .map(
                                  (id) => DropdownMenuItem(
                                    value: id,
                                    child: Text(id),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => selectedStudentId = v),
                            decoration: const InputDecoration(
                              labelText: 'Chọn mã học sinh',
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: subjectCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Môn học',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: midCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Giữa kỳ',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: finCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Cuối kỳ',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _addOrUpdate,
                          child: const Text('Lưu điểm'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const Divider(),

              // ===== LIST =====
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: gradesQuery.snapshots(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Lỗi tải điểm: ${snap.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  if (!snap.hasData) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final docs = snap.data!.docs;
                  if (docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Center(child: Text('Chưa có điểm')),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final d = docs[i].data();
                      return ListTile(
                        leading: const Icon(Icons.school_outlined),
                        title: Text('${d['studentId']} • ${d['subject']}'),
                        subtitle: Text(
                          'Giữa kỳ: ${d['scoreMid'] ?? 0} • Cuối kỳ: ${d['scoreFinal'] ?? 0}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => docs[i].reference.delete(),
                        ),
                        onTap: () {
                          setState(() {
                            selectedStudentId = d['studentId'].toString();
                            subjectCtrl.text = d['subject'].toString();
                            midCtrl.text = (d['scoreMid'] ?? 0).toString();
                            finCtrl.text = (d['scoreFinal'] ?? 0).toString();
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

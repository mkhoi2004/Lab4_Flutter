import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageSchedulesTab extends StatefulWidget {
  const ManageSchedulesTab({super.key});

  @override
  State<ManageSchedulesTab> createState() => _ManageSchedulesTabState();
}

class _ManageSchedulesTabState extends State<ManageSchedulesTab> {
  final _db = FirebaseFirestore.instance;

  String? selectedStudentId;
  int selectedDow = DateTime.now().weekday; // 1..7
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  final subjectCtrl = TextEditingController();
  final roomCtrl = TextEditingController();
  final teacherCtrl = TextEditingController();

  @override
  void dispose() {
    subjectCtrl.dispose();
    roomCtrl.dispose();
    teacherCtrl.dispose();
    super.dispose();
  }

  String _dowLabel(int d) {
    switch (d) {
      case 1:
        return 'Thứ 2';
      case 2:
        return 'Thứ 3';
      case 3:
        return 'Thứ 4';
      case 4:
        return 'Thứ 5';
      case 5:
        return 'Thứ 6';
      case 6:
        return 'Thứ 7';
      case 7:
        return 'Chủ nhật';
      default:
        return '---';
    }
  }

  Timestamp _toTimestampToday(TimeOfDay t) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    return Timestamp.fromDate(dt);
  }

  Future<void> _pickStartTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: startTime ?? TimeOfDay.now(),
    );
    if (t != null) setState(() => startTime = t);
  }

  Future<void> _pickEndTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: endTime ?? TimeOfDay.now(),
    );
    if (t != null) setState(() => endTime = t);
  }

  Future<void> _addOrUpdate() async {
    final sid = selectedStudentId?.trim() ?? '';
    final subject = subjectCtrl.text.trim();

    if (sid.isEmpty || subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn mã HS và nhập môn học')),
      );
      return;
    }
    if (startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn giờ bắt đầu/kết thúc')),
      );
      return;
    }

    final docId =
        '${sid}_${selectedDow}_${subject}_${startTime!.hour}${startTime!.minute}';

    await _db.collection('schedules').doc(docId).set({
      'studentId': sid,
      'dayOfWeek': selectedDow,
      'subject': subject,
      'room': roomCtrl.text.trim(),
      'teacher': teacherCtrl.text.trim(),
      'startAt': _toTimestampToday(startTime!),
      'endAt': _toTimestampToday(endTime!),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã lưu lịch học')));

    setState(() {
      selectedStudentId = null;
      selectedDow = DateTime.now().weekday;
      startTime = null;
      endTime = null;
      subjectCtrl.clear();
      roomCtrl.clear();
      teacherCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final schedulesQuery = _db
        .collection('schedules')
        .orderBy('updatedAt', descending: true);

    final studentsStream = _db
        .collection('students')
        .orderBy('studentId')
        .snapshots();

    String fmtTime(Timestamp? t) {
      if (t == null) return '--:--';
      final d = t.toDate();
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }

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

                      DropdownButtonFormField<int>(
                        value: selectedDow,
                        items: List.generate(
                          7,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text(_dowLabel(i + 1)),
                          ),
                        ),
                        onChanged: (v) => setState(() => selectedDow = v ?? 1),
                        decoration: const InputDecoration(
                          labelText: 'Chọn thứ',
                          border: OutlineInputBorder(),
                        ),
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
                              controller: roomCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Phòng',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: teacherCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Giáo viên',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.schedule),
                              label: Text(
                                startTime == null
                                    ? 'Giờ bắt đầu'
                                    : '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}',
                              ),
                              onPressed: _pickStartTime,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.schedule_outlined),
                              label: Text(
                                endTime == null
                                    ? 'Giờ kết thúc'
                                    : '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}',
                              ),
                              onPressed: _pickEndTime,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _addOrUpdate,
                          child: const Text('Lưu lịch học'),
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
                stream: schedulesQuery.snapshots(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Lỗi tải lịch: ${snap.error}',
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
                      child: Center(child: Text('Chưa có lịch học')),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final d = docs[i].data();
                      final sid = d['studentId'] ?? '';
                      final sub = d['subject'] ?? '';
                      final dow = d['dayOfWeek'] ?? 1;
                      final st = fmtTime(d['startAt']);
                      final et = fmtTime(d['endAt']);
                      final room = d['room'] ?? '';
                      final teacher = d['teacher'] ?? '';

                      return ListTile(
                        title: Text('$sid • $sub'),
                        subtitle: Text(
                          '${_dowLabel(dow)} • $st–$et\nPhòng: $room • GV: $teacher',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => docs[i].reference.delete(),
                        ),
                        onTap: () {
                          setState(() {
                            selectedStudentId = sid.toString();
                            selectedDow = dow as int;
                            subjectCtrl.text = sub.toString();
                            roomCtrl.text = room.toString();
                            teacherCtrl.text = teacher.toString();

                            final stDt = (d['startAt'] as Timestamp?)?.toDate();
                            final etDt = (d['endAt'] as Timestamp?)?.toDate();
                            startTime = stDt == null
                                ? null
                                : TimeOfDay(
                                    hour: stDt.hour,
                                    minute: stDt.minute,
                                  );
                            endTime = etDt == null
                                ? null
                                : TimeOfDay(
                                    hour: etDt.hour,
                                    minute: etDt.minute,
                                  );
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

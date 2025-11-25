import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  final fullName = TextEditingController();
  final studentIdCtrl = TextEditingController(); // for student

  String role = 'student';
  bool loading = false;
  String? err;

  // ====== PARENT: load + select children from students ======
  final _db = FirebaseFirestore.instance;
  bool loadingStudents = false;
  List<String> studentIds = [];
  List<String> selectedChildren = [];

  Future<void> _fetchStudents() async {
    setState(() {
      loadingStudents = true;
      err = null;
      studentIds = [];
      selectedChildren = [];
    });

    try {
      final snap = await _db.collection('students').get();

      final ids = snap.docs
          .map((doc) {
            final data = doc.data();
            final sid = data['studentId']?.toString();
            return (sid != null && sid.isNotEmpty) ? sid : doc.id;
          })
          .toSet()
          .toList();

      ids.sort();

      setState(() => studentIds = ids);
    } catch (e) {
      setState(() => err = 'Không tải được danh sách học sinh: $e');
    } finally {
      setState(() => loadingStudents = false);
    }
  }

  Future<void> _register() async {
    setState(() {
      loading = true;
      err = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final e = email.text.trim();
      final p = pass.text.trim();
      final name = fullName.text.trim();

      if (role == 'student') {
        await auth.signUpStudent(e, p, studentIdCtrl.text.trim(), name);
      } else if (role == 'parent') {
        if (selectedChildren.isEmpty) {
          throw Exception('Bạn phải chọn ít nhất 1 mã học sinh.');
        }
        await auth.signUpParent(e, p, selectedChildren, name);
      } else {
        await auth.signUpTeacher(e, p, name);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => err = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showStudent = role == 'student';
    final showParent = role == 'parent';

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký tài khoản')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: role,
              decoration: const InputDecoration(labelText: 'Vai trò'),
              items: const [
                DropdownMenuItem(value: 'student', child: Text('Học sinh')),
                DropdownMenuItem(value: 'parent', child: Text('Phụ huynh')),
                DropdownMenuItem(value: 'teacher', child: Text('Giáo viên')),
              ],
              onChanged: (v) async {
                final newRole = v ?? 'student';
                setState(() => role = newRole);

                if (newRole == 'parent') {
                  await _fetchStudents();
                }
              },
            ),
            const SizedBox(height: 8),

            TextField(
              controller: fullName,
              decoration: const InputDecoration(labelText: 'Họ tên'),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: pass,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu (≥6)'),
            ),
            const SizedBox(height: 8),

            if (showStudent)
              TextField(
                controller: studentIdCtrl,
                decoration: const InputDecoration(labelText: 'Mã học sinh'),
              ),

            if (showParent) ...[
              const SizedBox(height: 8),
              const Text(
                'Chọn mã học sinh của con:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),

              if (loadingStudents)
                const Center(child: CircularProgressIndicator()),

              if (!loadingStudents && studentIds.isEmpty)
                const Text('Chưa có học sinh nào trong hệ thống.'),

              if (!loadingStudents && studentIds.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: studentIds.map((sid) {
                    final selected = selectedChildren.contains(sid);
                    return FilterChip(
                      label: Text(sid),
                      selected: selected,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            selectedChildren.add(sid);
                          } else {
                            selectedChildren.remove(sid);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
            ],

            const SizedBox(height: 12),
            if (err != null)
              Text(err!, style: const TextStyle(color: Colors.red)),

            FilledButton(
              onPressed: loading ? null : _register,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Tạo tài khoản'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    fullName.dispose();
    studentIdCtrl.dispose();
    super.dispose();
  }
}

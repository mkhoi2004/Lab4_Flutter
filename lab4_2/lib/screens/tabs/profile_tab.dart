import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final nameCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool saving = false;
  String? msg;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final u = context.read<AuthProvider>().current;
    nameCtrl.text = u?.fullName ?? '';
  }

  Future<void> _saveName() async {
    setState(() {
      saving = true;
      msg = null;
    });
    try {
      await context.read<AuthProvider>().updateProfile(
        fullName: nameCtrl.text.trim(),
      );
      setState(() => msg = 'Đã cập nhật tên');
    } catch (e) {
      setState(() => msg = e.toString());
    } finally {
      setState(() => saving = false);
    }
  }

  Future<void> _changePass() async {
    setState(() {
      saving = true;
      msg = null;
    });
    try {
      await context.read<AuthProvider>().changePassword(passCtrl.text.trim());
      setState(() => msg = 'Đổi mật khẩu thành công');
    } catch (e) {
      setState(() => msg = e.toString());
    } finally {
      setState(() => saving = false);
    }
  }

  Future<void> _pickAvatar() async {
    setState(() {
      saving = true;
      msg = null;
    });
    try {
      final url = await StorageService().pickAndUploadAvatar();
      if (url != null) {
        await context.read<AuthProvider>().updateProfile(avatarUrl: url);
        setState(() => msg = 'Đã cập nhật avatar');
      }
    } catch (e) {
      setState(() => msg = e.toString());
    } finally {
      setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final u = auth.current;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: GestureDetector(
            onTap: saving ? null : _pickAvatar,
            child: CircleAvatar(
              radius: 44,
              backgroundImage: (u?.avatarUrl != null)
                  ? NetworkImage(u!.avatarUrl!)
                  : null,
              child: (u?.avatarUrl == null)
                  ? const Icon(Icons.person, size: 44)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('UID: ${u?.uid ?? ''}'),
        Text('Vai trò: ${u?.role ?? ''}'),
        if (u?.studentId != null) Text('Mã HS đang xem: ${u!.studentId}'),
        const SizedBox(height: 16),

        TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Họ tên'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: saving ? null : _saveName,
          child: const Text('Lưu hồ sơ'),
        ),

        const Divider(height: 32),

        TextField(
          controller: passCtrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: saving ? null : _changePass,
          child: const Text('Đổi mật khẩu'),
        ),

        const SizedBox(height: 12),
        if (msg != null)
          Text(
            msg!,
            style: TextStyle(
              color: msg!.startsWith('Đã') ? Colors.green : Colors.red,
            ),
          ),

        const Divider(height: 32),
        FilledButton(
          onPressed: saving ? null : auth.signOut,
          child: const Text('Đăng xuất'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }
}

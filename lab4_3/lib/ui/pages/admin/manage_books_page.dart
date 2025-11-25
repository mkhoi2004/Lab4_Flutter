import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/firestore_refs.dart';
import '../../../services/upload_service.dart';

class ManageBooksPage extends StatefulWidget {
  const ManageBooksPage({super.key});
  @override
  State<ManageBooksPage> createState() => _ManageBooksPageState();
}

class _ManageBooksPageState extends State<ManageBooksPage> {
  final _upload = UploadService();
  final _picker = ImagePicker();
  bool _busy = false;
  String? _error;

  Future<void> _addQuick() async {
    final id = booksRef.doc().id;
    await booksRef.doc(id).set({
      'title': 'Sách demo $id',
      'author': 'Tác giả A',
      'available': true,
      'category': 'General',
      'description': 'Mô tả ngắn',
      'coverUrl': null,
    });
  }

  Future<void> _pickAndUploadCover(
    DocumentReference<Map<String, dynamic>> doc,
  ) async {
    try {
      setState(() {
        _busy = true;
        _error = null;
      });
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      final secureUrl = await _upload.uploadImageFile(File(picked.path));
      await doc.update({'coverUrl': secureUrl});
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã cập nhật ảnh bìa')));
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sách'),
        actions: [
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addQuick,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (_error != null)
            MaterialBanner(
              content: Text(_error!),
              actions: [
                TextButton(
                  onPressed: () => setState(() => _error = null),
                  child: const Text('Ẩn'),
                ),
              ],
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: booksRef.orderBy('title').snapshots(),
              builder: (context, snap) {
                if (snap.hasError)
                  return Center(child: Text('Lỗi: ${snap.error}'));
                if (!snap.hasData)
                  return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                if (docs.isEmpty)
                  return const Center(child: Text('Chưa có sách'));
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final d = docs[i];
                    final cover = d['coverUrl'] as String?;
                    return ListTile(
                      leading: cover == null
                          ? const Icon(Icons.menu_book)
                          : Image.network(
                              cover,
                              width: 46,
                              height: 46,
                              fit: BoxFit.cover,
                            ),
                      title: Text(d['title'] ?? ''),
                      subtitle: Text(d['author'] ?? ''),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            tooltip: 'Chọn ảnh bìa',
                            onPressed: _busy
                                ? null
                                : () => _pickAndUploadCover(d.reference),
                            icon: const Icon(Icons.image),
                          ),
                          Switch(
                            value: (d['available'] ?? true) as bool,
                            onChanged: (v) =>
                                d.reference.update({'available': v}),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

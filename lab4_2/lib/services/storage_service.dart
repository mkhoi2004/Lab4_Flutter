import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;

  Future<String?> pickAndUploadAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return null;

    final file = File(picked.path);
    final name = 'avatars/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child(name);

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}

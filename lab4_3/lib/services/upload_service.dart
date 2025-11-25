import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class UploadService {
  // Emulator: 10.0.2.2, thiết bị thật: IP LAN của backend
  static const String baseUrl = 'https://5afac58cf9f1.ngrok-free.app';

  Future<String> uploadImageFile(File file) async {
    final uri = Uri.parse('$baseUrl/api/upload');
    final req = http.MultipartRequest('POST', uri);
    req.files.add(await http.MultipartFile.fromPath('file', file.path));

    final resp = await req.send();
    final body = await resp.stream.bytesToString();

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final map = jsonDecode(body) as Map<String, dynamic>;
      return map['secure_url'] as String;
    } else {
      throw 'Upload thất bại: ${resp.statusCode} - $body';
    }
  }
}

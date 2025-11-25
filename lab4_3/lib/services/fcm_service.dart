import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final CollectionReference<Map<String, dynamic>> _users = FirebaseFirestore
      .instance
      .collection('users');

  /// Xin quyền và thiết lập hiển thị ở foreground (iOS)
  Future<void> init() async {
    await _fcm.requestPermission();
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Gán token FCM cho user hiện tại và subscribe topic
  Future<void> bindUser(String uid) async {
    // Lấy token hiện tại và lưu lên Firestore
    final token = await _fcm.getToken();
    if (token != null) {
      await _users.doc(uid).set({'fcmToken': token}, SetOptions(merge: true));
    }

    // Theo dõi token refresh
    _fcm.onTokenRefresh.listen((newToken) async {
      await _users.doc(uid).set({
        'fcmToken': newToken,
      }, SetOptions(merge: true));
    });

    // Subscribe topic để nhận Campaign theo topic (ví dụ: nhắc trả sách)
    await _fcm.subscribeToTopic('due-soon');
  }
}

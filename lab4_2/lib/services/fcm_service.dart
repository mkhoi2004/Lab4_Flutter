import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  final _fcm = FirebaseMessaging.instance;
  final _users = FirebaseFirestore.instance.collection('users');

  Future<void> init() async {
    await _fcm.requestPermission();
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Lưu token lên Firestore + subscribe theo role (vd: 'student')
  Future<void> bindUser(String uid, {required String role}) async {
    final token = await _fcm.getToken();
    print('🔑 FCM token for $uid: $token');

    if (token != null) {
      await _users.doc(uid).set({'fcmToken': token}, SetOptions(merge: true));
    }

    _fcm.onTokenRefresh.listen((t) async {
      await _users.doc(uid).set({'fcmToken': t}, SetOptions(merge: true));
    });

    await _fcm.subscribeToTopic('all-users');
    await _fcm.subscribeToTopic(role);
    print('✅ Subscribed to topics: all-users, $role');

    // Hạn chế nhận nhầm: bỏ subscribe các role khác
    for (final other in const ['student', 'teacher', 'librarian']) {
      if (other != role) await _fcm.unsubscribeFromTopic(other);
    }
  }

  Future<void> unbindAll() async {
    await _fcm.unsubscribeFromTopic('all-users');
    for (final t in const ['student', 'teacher', 'librarian']) {
      await _fcm.unsubscribeFromTopic(t);
    }
  }
}

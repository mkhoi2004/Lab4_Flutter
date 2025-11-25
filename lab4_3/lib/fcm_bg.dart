import 'package:firebase_messaging/firebase_messaging.dart';

/// Hàm top-level để nhận FCM khi app ở background/terminated.
/// ĐỪNG đặt trong class.
/// Nếu cần, bạn có thể init Firebase ở đây, nhưng trong đa số trường hợp không bắt buộc.
@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  // print('BG message: ${message.messageId} - ${message.notification?.title}');
}

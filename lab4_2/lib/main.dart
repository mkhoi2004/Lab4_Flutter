import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/fcm_service.dart';
import 'services/fcm_bg.dart';

// ========== Local notifications (hiện noti khi app đang mở) ==========
final _local = FlutterLocalNotificationsPlugin();
const _channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance',
  description: 'Foreground notifications',
  importance: Importance.high,
);

Future<void> _initLocalNoti() async {
  const init = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );
  await _local.initialize(init);
  final android = _local
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  await android?.createNotificationChannel(_channel);
  await android?.requestNotificationsPermission(); // Android 13+
}

Future<void> _wireForegroundFCM() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((m) async {
    final n = m.notification;
    final a = n?.android;
    if (n != null && a != null) {
      await _local.show(
        n.hashCode,
        n.title,
        n.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  });

  // Người dùng bấm noti khi app background/cold start (tùy bạn điều hướng)
  FirebaseMessaging.onMessageOpenedApp.listen((m) {
    // print('Opened from notif: ${m.data}');
  });
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) {
    // print('Launched from notif: ${initial.data}');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);

  await _initLocalNoti();
  await _wireForegroundFCM();

  // Cấu hình FCM service & xin quyền
  await FcmService().init();
  await FirebaseMessaging.instance.requestPermission();

  // In token để test nhanh
  final token = await FirebaseMessaging.instance.getToken();
  print('🔑 FCM token: $token');

  runApp(
    ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider()..bootstrap(),
      child: const SchoolApp(),
    ),
  );
}

String? _boundUid;

class SchoolApp extends StatelessWidget {
  const SchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final uid = auth.current?.uid;
    final role = auth.current?.role;

    // Bind token + subscribe topic theo role (một lần mỗi uid)
    if (uid != null && role != null && uid != _boundUid) {
      print('🔗 Bind FCM for $uid (role=$role)');
      FcmService().bindUser(uid, role: role); // ← topic student
      _boundUid = uid;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'School App',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: switch (auth.status) {
        AuthStatus.loading => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        AuthStatus.unauthenticated => const LoginScreen(),
        AuthStatus.authenticated => const HomeScreen(),
      },
    );
  }
}

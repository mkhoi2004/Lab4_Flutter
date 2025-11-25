import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/fcm_service.dart';

enum AuthStatus { loading, unauthenticated, authenticated }

class AppUser {
  final String uid;
  final String role; // student | parent | teacher
  final String? studentId; // for student OR selected child for parent
  final List<String> childrenIds; // for parent
  final String? fullName;
  final String? avatarUrl;

  AppUser({
    required this.uid,
    required this.role,
    this.studentId,
    this.childrenIds = const [],
    this.fullName,
    this.avatarUrl,
  });

  AppUser copyWith({
    String? role,
    String? studentId,
    List<String>? childrenIds,
    String? fullName,
    String? avatarUrl,
  }) {
    return AppUser(
      uid: uid,
      role: role ?? this.role,
      studentId: studentId ?? this.studentId,
      childrenIds: childrenIds ?? this.childrenIds,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class AuthProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  StreamSubscription<User?>? _sub;

  AuthStatus status = AuthStatus.loading;
  AppUser? current;

  AuthProvider bootstrap() {
    _sub?.cancel();
    _sub = _auth.authStateChanges().listen((u) async {
      if (u == null) {
        status = AuthStatus.unauthenticated;
        current = null;
        notifyListeners();
        return;
      }
      await _loadUser(u.uid);
    });
    return this;
  }

  Future<void> _loadUser(String uid) async {
    status = AuthStatus.loading;
    notifyListeners();

    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data() ?? {};

    current = AppUser(
      uid: uid,
      role: (data['role'] ?? 'student') as String,
      studentId: data['studentId'] as String?,
      childrenIds: (data['childrenIds'] as List?)?.cast<String>() ?? const [],
      fullName: data['fullName'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
    );

    status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> signIn(String email, String pass) async {
    await _auth.signInWithEmailAndPassword(email: email, password: pass);
  }

  /// ✅ ĐĂNG KÝ HỌC SINH → tạo users + students
  Future<void> signUpStudent(
    String email,
    String pass,
    String studentId,
    String fullName,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: pass,
    );

    final uid = cred.user!.uid;

    // 1) users/{uid}
    await _db.collection('users').doc(uid).set({
      'role': 'student',
      'studentId': studentId,
      'fullName': fullName,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2) students/{studentId}  ✅ đây là phần bạn thiếu trước đó
    await _db.collection('students').doc(studentId).set({
      'studentId': studentId,
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'className': '', // để trống nếu chưa có lớp
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> signUpParent(
    String email,
    String pass,
    List<String> childrenIds,
    String fullName,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: pass,
    );

    await _db.collection('users').doc(cred.user!.uid).set({
      'role': 'parent',
      'childrenIds': childrenIds,
      'fullName': fullName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signUpTeacher(String email, String pass, String fullName) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: pass,
    );

    await _db.collection('users').doc(cred.user!.uid).set({
      'role': 'teacher',
      'fullName': fullName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addChildForParent(String childStudentId) async {
    final u = current;
    if (u == null || u.role != 'parent') return;

    final newChildren = {...u.childrenIds, childStudentId}.toList();
    await _db.collection('users').doc(u.uid).update({
      'childrenIds': newChildren,
    });

    current = u.copyWith(childrenIds: newChildren);
    notifyListeners();
  }

  void selectChild(String studentId) {
    if (current == null || current!.role != 'parent') return;
    current = current!.copyWith(studentId: studentId);
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> changePassword(String newPass) async {
    final u = _auth.currentUser;
    if (u == null) throw Exception('Chưa đăng nhập');
    await u.updatePassword(newPass);
  }

  Future<void> updateProfile({String? fullName, String? avatarUrl}) async {
    final u = current;
    if (u == null) return;

    final patch = <String, dynamic>{};
    if (fullName != null) patch['fullName'] = fullName;
    if (avatarUrl != null) patch['avatarUrl'] = avatarUrl;

    if (patch.isEmpty) return;

    await _db
        .collection('users')
        .doc(u.uid)
        .set(patch, SetOptions(merge: true));
    current = u.copyWith(fullName: fullName, avatarUrl: avatarUrl);
    notifyListeners();
  }

  Future<void> reloadUser() async {
    final uid = current?.uid;
    if (uid != null) await _loadUser(uid);
  }

  Future<void> signOut() async {
    await FcmService().unbindAll();
    await _auth.signOut();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

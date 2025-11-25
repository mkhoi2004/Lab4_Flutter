import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  AuthProvider() {
    _auth.authStateChanges().listen((_) => notifyListeners());
  }

  Future<void> signIn(String email, String pass) async {
    await _auth.signInWithEmailAndPassword(email: email, password: pass);
  }

  Future<void> signUp(String email, String pass) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: pass);
  }

  Future<void> signOut() async => _auth.signOut();
}

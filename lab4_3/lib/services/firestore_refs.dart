import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;
final usersRef = db.collection('users');
final booksRef = db.collection('books');
final loansRef = db.collection('loans');

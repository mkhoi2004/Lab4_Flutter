import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../services/firestore_refs.dart';

class BookProvider extends ChangeNotifier {
  Stream<List<Book>> watchBooks({String? search}) {
    Query<Map<String, dynamic>> q = booksRef.orderBy('title');
    if (search != null && search.trim().isNotEmpty) {
      q = booksRef.orderBy('title').startAt([search]).endAt(['$search\uf8ff']);
    }
    return q.snapshots().map(
      (s) => s.docs.map((d) => Book.fromMap(d.id, d.data())).toList(),
    );
  }

  Future<void> addOrUpdate(Book b) async {
    await booksRef.doc(b.id).set(b.toMap(), SetOptions(merge: true));
  }
}

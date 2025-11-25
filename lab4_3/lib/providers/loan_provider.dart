import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/loan.dart';
import '../services/firestore_refs.dart';

class LoanProvider extends ChangeNotifier {
  Stream<List<Loan>> watchMyLoans(String uid) {
    return loansRef
        .where('userId', isEqualTo: uid)
        .orderBy('borrowedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Loan.fromMap(d.id, d.data())).toList());
  }

  Future<void> borrow({required String bookId, required String userId}) async {
    final id = loansRef.doc().id;
    final now = DateTime.now().millisecondsSinceEpoch;
    await loansRef.doc(id).set({
      'bookId': bookId,
      'userId': userId,
      'borrowedAt': now,
      'returnedAt': null,
    });
    await booksRef.doc(bookId).update({'available': false});
  }

  Future<void> returnBook(Loan loan) async {
    await loansRef.doc(loan.id).update({
      'returnedAt': DateTime.now().millisecondsSinceEpoch,
    });
    await booksRef.doc(loan.bookId).update({'available': true});
  }
}

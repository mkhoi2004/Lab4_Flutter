class Loan {
  final String id;
  final String bookId;
  final String userId;
  final DateTime borrowedAt;
  final DateTime? returnedAt;

  Loan({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.borrowedAt,
    this.returnedAt,
  });

  factory Loan.fromMap(String id, Map<String, dynamic> m) => Loan(
    id: id,
    bookId: (m['bookId'] ?? '') as String,
    userId: (m['userId'] ?? '') as String,
    borrowedAt: DateTime.fromMillisecondsSinceEpoch(
      (m['borrowedAt'] ?? 0) as int,
    ),
    returnedAt: m['returnedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(m['returnedAt'] as int)
        : null,
  );

  Map<String, dynamic> toMap() => {
    'bookId': bookId,
    'userId': userId,
    'borrowedAt': borrowedAt.millisecondsSinceEpoch,
    'returnedAt': returnedAt?.millisecondsSinceEpoch,
  };
}

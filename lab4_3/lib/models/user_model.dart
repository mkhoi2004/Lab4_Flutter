class AppUser {
  final String uid;
  final String email;
  final String role; // 'user' | 'librarian'

  AppUser({required this.uid, required this.email, required this.role});

  factory AppUser.fromMap(String uid, Map<String, dynamic> m) => AppUser(
    uid: uid,
    email: (m['email'] ?? '') as String,
    role: (m['role'] ?? 'user') as String,
  );

  Map<String, dynamic> toMap() => {'email': email, 'role': role};
}

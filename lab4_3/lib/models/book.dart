class Book {
  final String id;
  final String title;
  final String author;
  final String? coverUrl;
  final bool available;
  final String? category;
  final String? description;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.coverUrl,
    required this.available,
    this.category,
    this.description,
  });

  factory Book.fromMap(String id, Map<String, dynamic> m) => Book(
    id: id,
    title: (m['title'] ?? '') as String,
    author: (m['author'] ?? '') as String,
    coverUrl: m['coverUrl'] as String?,
    available: (m['available'] ?? true) as bool,
    category: m['category'] as String?,
    description: m['description'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'title': title,
    'author': author,
    'coverUrl': coverUrl,
    'available': available,
    'category': category,
    'description': description,
  };
}

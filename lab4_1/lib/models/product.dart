class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String image;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    price: (json['price'] as num).toDouble(),
    image: json['image'] ?? '',
  );
}

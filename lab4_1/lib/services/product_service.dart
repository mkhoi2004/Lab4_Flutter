import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  static Future<List<Product>> fetchProducts() async {
    final res = await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (res.statusCode != 200) {
      throw Exception('Lỗi tải sản phẩm: ${res.statusCode}');
    }
    final List data = json.decode(res.body);
    return data
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

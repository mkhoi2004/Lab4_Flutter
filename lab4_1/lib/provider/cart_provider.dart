import 'package:flutter/material.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<Product> _items = [];
  List<Product> get items => List.unmodifiable(_items);

  void addToCart(Product p) {
    _items.add(p);
    notifyListeners();
  }

  void removeFromCart(Product p) {
    _items.remove(p);
    notifyListeners();
  }

  double get total => _items.fold(0.0, (sum, p) => sum + p.price);

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

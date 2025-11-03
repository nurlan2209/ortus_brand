import 'package:flutter/material.dart';
import '../models/order_model.dart';

class CartProvider extends ChangeNotifier {
  final List<OrderItem> _items = [];

  List<OrderItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  void addItem(OrderItem item) {
    final existingIndex = _items.indexWhere(
      (i) => i.productId == item.productId && i.size == item.size,
    );

    if (existingIndex >= 0) {
      final existingItem = _items[existingIndex];
      _items[existingIndex] = OrderItem(
        productId: existingItem.productId,
        name: existingItem.name,
        price: existingItem.price,
        size: existingItem.size,
        quantity: existingItem.quantity + item.quantity,
        image: existingItem.image,
      );
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(String productId, String size) {
    _items.removeWhere(
      (item) => item.productId == productId && item.size == size,
    );
    notifyListeners();
  }

  void updateQuantity(String productId, String size, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId, size);
      return;
    }

    final index = _items.indexWhere(
      (item) => item.productId == productId && item.size == size,
    );

    if (index >= 0) {
      final item = _items[index];
      _items[index] = OrderItem(
        productId: item.productId,
        name: item.name,
        price: item.price,
        size: item.size,
        quantity: newQuantity,
        image: item.image,
      );
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

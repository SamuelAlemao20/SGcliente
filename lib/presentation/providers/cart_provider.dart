import 'package:flutter/foundation.dart';
import 'package:sg_sabores_cliente/domain/entities/product.dart';

class CartItem {
  final String id;
  final Product product;
  int quantity;
  CartItem({required this.id, required this.product, this.quantity = 1});
  double get totalPrice => product.finalPrice * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => _items;

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get deliveryFee => 5.0;
  double get total => subtotal + deliveryFee;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _items.isEmpty;

  void updateItemQuantity(String itemId, int newQuantity) {
    // Lógica para atualizar quantidade
    notifyListeners();
  }
}

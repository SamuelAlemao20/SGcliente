import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:sg_sabores_cliente/domain/entities/order.dart';
import 'package:sg_sabores_cliente/domain/entities/product.dart';

class OrderProvider extends ChangeNotifier {
  OrderItem _mapOrderItemFromFirestore(Map<String, dynamic> data) {
    return OrderItem(
      id: data['id'] ?? '',
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 1,
      product: Product(
          id: '',
          name: '',
          description: '',
          imageUrl: '',
          price: 0,
          categoryId: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now()),
    );
  }
}

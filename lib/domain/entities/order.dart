import 'package:sg_sabores_cliente/domain/entities/address.dart';
import 'package:sg_sabores_cliente/domain/entities/product.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  onTheWay,
  delivered,
  cancelled
}

enum PaymentMethod { pix, creditCard, cash }

class Order {
  Order({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.paymentMethod,
    this.notes,
    required this.orderTime,
    this.estimatedDeliveryTime,
    this.trackingCode,
    required this.deliveryAddress,
  });
  final String id;
  final String restaurantId;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final String? notes;
  final DateTime orderTime;
  final DateTime? estimatedDeliveryTime;
  final String? trackingCode;
  final Address deliveryAddress;
}

class OrderItem {
  OrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.product,
    this.selectedOptions = const [],
    this.selectedAddons = const [],
  });
  final String id;
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final Product product;
  final List<ProductOptionItem> selectedOptions;
  final List<ProductAddon> selectedAddons;

  double get totalPrice {
    final optionsPrice = selectedOptions.fold<double>(
        0, (sum, item) => sum + item.additionalPrice);
    final addonsPrice =
        selectedAddons.fold<double>(0, (sum, item) => sum + item.price);
    return (product.finalPrice + optionsPrice + addonsPrice) * quantity;
  }
}

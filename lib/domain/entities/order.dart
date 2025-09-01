
import 'user.dart';
import 'restaurant.dart';
import 'product.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  onTheWay,
  delivered,
  cancelled
}

enum PaymentMethod {
  pix,
  creditCard,
  debitCard,
  cash
}

class Order {
  final String id;
  final String userId;
  final String restaurantId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final Address deliveryAddress;
  final String? notes;
  final String? couponCode;
  final double? couponDiscount;
  final DateTime orderTime;
  final DateTime? estimatedDeliveryTime;
  final String? trackingCode;
  final User? user;
  final Restaurant? restaurant;

  Order({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.deliveryAddress,
    this.notes,
    this.couponCode,
    this.couponDiscount,
    required this.orderTime,
    this.estimatedDeliveryTime,
    this.trackingCode,
    this.user,
    this.restaurant,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Aguardando confirmação';
      case OrderStatus.confirmed:
        return 'Pedido confirmado';
      case OrderStatus.preparing:
        return 'Preparando';
      case OrderStatus.ready:
        return 'Pronto para entrega';
      case OrderStatus.onTheWay:
        return 'Saiu para entrega';
      case OrderStatus.delivered:
        return 'Entregue';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  String get paymentMethodText {
    switch (paymentMethod) {
      case PaymentMethod.pix:
        return 'PIX';
      case PaymentMethod.creditCard:
        return 'Cartão de Crédito';
      case PaymentMethod.debitCard:
        return 'Cartão de Débito';
      case PaymentMethod.cash:
        return 'Dinheiro';
    }
  }

  double get totalWithDiscount {
    if (couponDiscount != null) {
      return total - couponDiscount!;
    }
    return total;
  }

  Order copyWith({
    String? id,
    String? userId,
    String? restaurantId,
    List<OrderItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? total,
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    Address? deliveryAddress,
    String? notes,
    String? couponCode,
    double? couponDiscount,
    DateTime? orderTime,
    DateTime? estimatedDeliveryTime,
    String? trackingCode,
    User? user,
    Restaurant? restaurant,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      notes: notes ?? this.notes,
      couponCode: couponCode ?? this.couponCode,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      orderTime: orderTime ?? this.orderTime,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      trackingCode: trackingCode ?? this.trackingCode,
      user: user ?? this.user,
      restaurant: restaurant ?? this.restaurant,
    );
  }
}

class OrderItem {
  final String id;
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? notes;
  final List<OrderItemOption> selectedOptions;
  final List<OrderItemAddon> selectedAddons;
  final Product? product;

  OrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.notes,
    this.selectedOptions = const [],
    this.selectedAddons = const [],
    this.product,
  });

  double get totalPrice {
    double optionsPrice = selectedOptions.fold(0, (sum, option) => sum + option.price);
    double addonsPrice = selectedAddons.fold(0, (sum, addon) => sum + addon.price);
    return (price + optionsPrice + addonsPrice) * quantity;
  }

  OrderItem copyWith({
    String? id,
    String? productId,
    String? name,
    double? price,
    int? quantity,
    String? notes,
    List<OrderItemOption>? selectedOptions,
    List<OrderItemAddon>? selectedAddons,
    Product? product,
  }) {
    return OrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      selectedAddons: selectedAddons ?? this.selectedAddons,
      product: product ?? this.product,
    );
  }
}

class OrderItemOption {
  final String optionId;
  final String itemId;
  final String name;
  final double price;

  OrderItemOption({
    required this.optionId,
    required this.itemId,
    required this.name,
    required this.price,
  });
}

class OrderItemAddon {
  final String addonId;
  final String name;
  final double price;

  OrderItemAddon({
    required this.addonId,
    required this.name,
    required this.price,
  });
}

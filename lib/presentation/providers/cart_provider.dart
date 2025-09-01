
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/order.dart';
import '../../services/payment_service.dart';
import '../../core/utils/service_locator.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final List<ProductOptionItem> selectedOptions;
  final List<ProductAddon> selectedAddons;
  final String? notes;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.selectedOptions = const [],
    this.selectedAddons = const [],
    this.notes,
  });

  double get totalPrice {
    double optionsPrice = selectedOptions.fold(0, (sum, option) => sum + option.additionalPrice);
    double addonsPrice = selectedAddons.fold(0, (sum, addon) => sum + addon.price);
    return (product.finalPrice + optionsPrice + addonsPrice) * quantity;
  }

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    List<ProductOptionItem>? selectedOptions,
    List<ProductAddon>? selectedAddons,
    String? notes,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      selectedAddons: selectedAddons ?? this.selectedAddons,
      notes: notes ?? this.notes,
    );
  }
}

class CartProvider extends ChangeNotifier {
  final PaymentService _paymentService = getIt<PaymentService>();
  final Uuid _uuid = Uuid();

  List<CartItem> _items = [];
  String? _restaurantId;
  String? _restaurantName;
  double _deliveryFee = 0.0;
  String? _couponCode;
  double _couponDiscount = 0.0;
  bool _isLoading = false;

  List<CartItem> get items => _items;
  String? get restaurantId => _restaurantId;
  String? get restaurantName => _restaurantName;
  double get deliveryFee => _deliveryFee;
  String? get couponCode => _couponCode;
  double get couponDiscount => _couponDiscount;
  bool get isLoading => _isLoading;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get total => subtotal + _deliveryFee - _couponDiscount;

  void addItem({
    required Product product,
    required String restaurantId,
    required String restaurantName,
    int quantity = 1,
    List<ProductOptionItem> selectedOptions = const [],
    List<ProductAddon> selectedAddons = const [],
    String? notes,
  }) {
    // Check if cart is empty or from same restaurant
    if (_items.isEmpty) {
      _restaurantId = restaurantId;
      _restaurantName = restaurantName;
    } else if (_restaurantId != restaurantId) {
      // Different restaurant, ask user to clear cart
      throw Exception('Você só pode adicionar itens do mesmo restaurante');
    }

    // Check if same item with same options already exists
    final existingIndex = _items.indexWhere((item) =>
        item.product.id == product.id &&
        _listEquals(item.selectedOptions, selectedOptions) &&
        _listEquals(item.selectedAddons, selectedAddons) &&
        item.notes == notes);

    if (existingIndex >= 0) {
      // Update quantity of existing item
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      // Add new item
      _items.add(CartItem(
        id: _uuid.v4(),
        product: product,
        quantity: quantity,
        selectedOptions: selectedOptions,
        selectedAddons: selectedAddons,
        notes: notes,
      ));
    }

    notifyListeners();
    _calculateDeliveryFee();
  }

  void updateItemQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }

    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    
    if (_items.isEmpty) {
      _clearRestaurantInfo();
    }
    
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _clearRestaurantInfo();
    _clearCoupon();
    notifyListeners();
  }

  void _clearRestaurantInfo() {
    _restaurantId = null;
    _restaurantName = null;
    _deliveryFee = 0.0;
  }

  Future<void> _calculateDeliveryFee() async {
    if (_restaurantId == null || _items.isEmpty) return;

    try {
      _isLoading = true;
      notifyListeners();

      // This would get user's current address
      // For now using mock coordinates
      final calculation = await _paymentService.calculateDeliveryFee(
        restaurantId: _restaurantId!,
        latitude: -23.5505, // Mock São Paulo coordinates
        longitude: -46.6333,
      );

      _deliveryFee = calculation.fee;
      notifyListeners();
    } catch (e) {
      debugPrint('Error calculating delivery fee: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyCoupon(String code) async {
    if (_restaurantId == null || code.isEmpty) return false;

    try {
      _isLoading = true;
      notifyListeners();

      final validation = await _paymentService.validateCoupon(
        couponCode: code,
        restaurantId: _restaurantId!,
        orderAmount: subtotal,
      );

      if (validation.isValid) {
        _couponCode = code;
        _couponDiscount = validation.discountAmount;
        notifyListeners();
        return true;
      } else {
        throw Exception(validation.message ?? 'Cupom inválido');
      }
    } catch (e) {
      debugPrint('Error applying coupon: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void removeCoupon() {
    _clearCoupon();
    notifyListeners();
  }

  void _clearCoupon() {
    _couponCode = null;
    _couponDiscount = 0.0;
  }

  // Convert cart to order items
  List<OrderItem> toOrderItems() {
    return _items.map((cartItem) {
      return OrderItem(
        id: _uuid.v4(),
        productId: cartItem.product.id,
        name: cartItem.product.name,
        price: cartItem.product.finalPrice,
        quantity: cartItem.quantity,
        notes: cartItem.notes,
        selectedOptions: cartItem.selectedOptions
            .map((option) => OrderItemOption(
                  optionId: option.id,
                  itemId: option.id,
                  name: option.name,
                  price: option.additionalPrice,
                ))
            .toList(),
        selectedAddons: cartItem.selectedAddons
            .map((addon) => OrderItemAddon(
                  addonId: addon.id,
                  name: addon.name,
                  price: addon.price,
                ))
            .toList(),
        product: cartItem.product,
      );
    }).toList();
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

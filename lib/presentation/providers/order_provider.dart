
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/order.dart';
import '../../domain/entities/user.dart' as app_user;
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../services/payment_service.dart';
import '../../core/utils/service_locator.dart';

class OrderProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = getIt<FirestoreService>();
  final AuthService _authService = getIt<AuthService>();
  final PaymentService _paymentService = getIt<PaymentService>();
  final Uuid _uuid = Uuid();

  List<Order> _orders = [];
  Order? _currentOrder;
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  Order? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<String?> createOrder({
    required String restaurantId,
    required List<OrderItem> items,
    required double subtotal,
    required double deliveryFee,
    required PaymentMethod paymentMethod,
    required app_user.Address deliveryAddress,
    String? notes,
    String? couponCode,
    double? couponDiscount,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = _authService.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final orderId = _uuid.v4();
      final now = DateTime.now();
      final estimatedDelivery = now.add(Duration(minutes: 45)); // Default 45 min

      final orderData = {
        'userId': user.uid,
        'restaurantId': restaurantId,
        'items': items.map((item) => _orderItemToMap(item)).toList(),
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'total': subtotal + deliveryFee - (couponDiscount ?? 0),
        'status': OrderStatus.pending.toString().split('.').last,
        'paymentMethod': paymentMethod.toString().split('.').last,
        'deliveryAddress': _addressToMap(deliveryAddress),
        'notes': notes,
        'couponCode': couponCode,
        'couponDiscount': couponDiscount,
        'orderTime': Timestamp.fromDate(now),
        'estimatedDeliveryTime': Timestamp.fromDate(estimatedDelivery),
        'trackingCode': _generateTrackingCode(),
      };

      await _firestoreService.createWithId('orders', orderId, orderData);

      // Process payment if not cash
      if (paymentMethod != PaymentMethod.cash) {
        await _processPayment(orderId, paymentMethod, subtotal + deliveryFee - (couponDiscount ?? 0));
      }

      return orderId;
    } catch (e) {
      _setError('Erro ao criar pedido: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _processPayment(String orderId, PaymentMethod method, double amount) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      switch (method) {
        case PaymentMethod.pix:
          final response = await _paymentService.createPixPayment(
            amount: amount,
            description: 'Pedido #$orderId',
            payerEmail: user.email!,
            orderId: orderId,
          );
          
          // Update order with payment info
          await _firestoreService.update('orders', orderId, {
            'paymentId': response.id,
            'pixQrCode': response.qrCode,
            'pixCopyAndPaste': response.pixCopyAndPaste,
          });
          break;
          
        case PaymentMethod.creditCard:
        case PaymentMethod.debitCard:
          // Card payment would be handled differently
          // This is a placeholder for card payment processing
          break;
          
        case PaymentMethod.cash:
          // No processing needed for cash
          break;
      }
    } catch (e) {
      debugPrint('Error processing payment: $e');
    }
  }

  Future<void> loadUserOrders() async {
    try {
      _setLoading(true);
      _clearError();

      final user = _authService.currentUser;
      if (user == null) return;

      final querySnapshot = await _firestoreService.readCollection(
        'orders',
        queryBuilder: (query) => query
            .where('userId', isEqualTo: user.uid)
            .orderBy('orderTime', descending: true),
      );

      _orders = querySnapshot.docs
          .map((doc) => _mapOrderFromFirestore(doc))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar pedidos: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadOrderById(String orderId) async {
    try {
      _setLoading(true);
      _clearError();

      final doc = await _firestoreService.read('orders', orderId);
      if (doc.exists) {
        _currentOrder = _mapOrderFromFirestore(doc);
        notifyListeners();
      }
    } catch (e) {
      _setError('Erro ao carregar pedido: $e');
    } finally {
      _setLoading(false);
    }
  }

  Stream<Order?> watchOrder(String orderId) {
    return _firestoreService.watchDocument('orders', orderId).map((doc) {
      if (doc.exists) {
        final order = _mapOrderFromFirestore(doc);
        _currentOrder = order;
        
        // Update order in list if exists
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index >= 0) {
          _orders[index] = order;
        }
        
        notifyListeners();
        return order;
      }
      return null;
    });
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.update('orders', orderId, {
        'status': OrderStatus.cancelled.toString().split('.').last,
      });

      // Reload orders
      await loadUserOrders();
    } catch (e) {
      _setError('Erro ao cancelar pedido: $e');
    } finally {
      _setLoading(false);
    }
  }

  Order _mapOrderFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Order(
      id: doc.id,
      userId: data['userId'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => _mapOrderItemFromFirestore(item as Map<String, dynamic>))
          .toList() ?? [],
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0.0).toDouble(),
      total: (data['total'] ?? 0.0).toDouble(),
      status: _mapOrderStatus(data['status']),
      paymentMethod: _mapPaymentMethod(data['paymentMethod']),
      deliveryAddress: _mapAddressFromFirestore(data['deliveryAddress'] ?? {}),
      notes: data['notes'],
      couponCode: data['couponCode'],
      couponDiscount: data['couponDiscount']?.toDouble(),
      orderTime: (data['orderTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estimatedDeliveryTime: (data['estimatedDeliveryTime'] as Timestamp?)?.toDate(),
      trackingCode: data['trackingCode'],
    );
  }

  OrderItem _mapOrderItemFromFirestore(Map<String, dynamic> data) {
    return OrderItem(
      id: data['id'] ?? '',
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 1,
      notes: data['notes'],
      selectedOptions: (data['selectedOptions'] as List<dynamic>?)
          ?.map((option) => OrderItemOption(
                optionId: option['optionId'] ?? '',
                itemId: option['itemId'] ?? '',
                name: option['name'] ?? '',
                price: (option['price'] ?? 0.0).toDouble(),
              ))
          .toList() ?? [],
      selectedAddons: (data['selectedAddons'] as List<dynamic>?)
          ?.map((addon) => OrderItemAddon(
                addonId: addon['addonId'] ?? '',
                name: addon['name'] ?? '',
                price: (addon['price'] ?? 0.0).toDouble(),
              ))
          .toList() ?? [],
    );
  }

  app_user.Address _mapAddressFromFirestore(Map<String, dynamic> data) {
    return app_user.Address(
      id: data['id'] ?? '',
      label: data['label'] ?? '',
      street: data['street'] ?? '',
      number: data['number'] ?? '',
      complement: data['complement'],
      neighborhood: data['neighborhood'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      zipCode: data['zipCode'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      isDefault: data['isDefault'] ?? false,
    );
  }

  OrderStatus _mapOrderStatus(String? status) {
    switch (status) {
      case 'pending': return OrderStatus.pending;
      case 'confirmed': return OrderStatus.confirmed;
      case 'preparing': return OrderStatus.preparing;
      case 'ready': return OrderStatus.ready;
      case 'onTheWay': return OrderStatus.onTheWay;
      case 'delivered': return OrderStatus.delivered;
      case 'cancelled': return OrderStatus.cancelled;
      default: return OrderStatus.pending;
    }
  }

  PaymentMethod _mapPaymentMethod(String? method) {
    switch (method) {
      case 'pix': return PaymentMethod.pix;
      case 'creditCard': return PaymentMethod.creditCard;
      case 'debitCard': return PaymentMethod.debitCard;
      case 'cash': return PaymentMethod.cash;
      default: return PaymentMethod.pix;
    }
  }

  Map<String, dynamic> _orderItemToMap(OrderItem item) {
    return {
      'id': item.id,
      'productId': item.productId,
      'name': item.name,
      'price': item.price,
      'quantity': item.quantity,
      'notes': item.notes,
      'selectedOptions': item.selectedOptions.map((option) => {
        'optionId': option.optionId,
        'itemId': option.itemId,
        'name': option.name,
        'price': option.price,
      }).toList(),
      'selectedAddons': item.selectedAddons.map((addon) => {
        'addonId': addon.addonId,
        'name': addon.name,
        'price': addon.price,
      }).toList(),
    };
  }

  Map<String, dynamic> _addressToMap(app_user.Address address) {
    return {
      'id': address.id,
      'label': address.label,
      'street': address.street,
      'number': address.number,
      'complement': address.complement,
      'neighborhood': address.neighborhood,
      'city': address.city,
      'state': address.state,
      'zipCode': address.zipCode,
      'latitude': address.latitude,
      'longitude': address.longitude,
      'isDefault': address.isDefault,
    };
  }

  String _generateTrackingCode() {
    final now = DateTime.now();
    return 'TRK${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.millisecond}';
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}


import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled
}

class PaymentService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'YOUR_BACKEND_API_URL'; // Replace with your API

  // Mercado Pago Integration
  Future<PaymentResponse> createPixPayment({
    required double amount,
    required String description,
    required String payerEmail,
    required String orderId,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/payments/pix',
        data: {
          'transaction_amount': amount,
          'description': description,
          'payment_method_id': 'pix',
          'payer': {
            'email': payerEmail,
          },
          'external_reference': orderId,
          'notification_url': '$_baseUrl/webhooks/mercadopago',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer YOUR_MERCADOPAGO_ACCESS_TOKEN',
            'Content-Type': 'application/json',
          },
        ),
      );

      return PaymentResponse.fromJson(response.data);
    } catch (e) {
      throw PaymentException('Erro ao criar pagamento PIX: $e');
    }
  }

  Future<PaymentResponse> createCardPayment({
    required double amount,
    required String description,
    required String payerEmail,
    required String orderId,
    required CardInfo cardInfo,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/payments/card',
        data: {
          'transaction_amount': amount,
          'description': description,
          'payment_method_id': cardInfo.paymentMethodId,
          'payer': {
            'email': payerEmail,
          },
          'token': cardInfo.token, // Card token from frontend
          'installments': cardInfo.installments,
          'external_reference': orderId,
          'notification_url': '$_baseUrl/webhooks/mercadopago',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer YOUR_MERCADOPAGO_ACCESS_TOKEN',
            'Content-Type': 'application/json',
          },
        ),
      );

      return PaymentResponse.fromJson(response.data);
    } catch (e) {
      throw PaymentException('Erro ao processar pagamento: $e');
    }
  }

  Future<PaymentStatus> getPaymentStatus(String paymentId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/payments/$paymentId/status',
        options: Options(
          headers: {
            'Authorization': 'Bearer YOUR_MERCADOPAGO_ACCESS_TOKEN',
          },
        ),
      );

      final status = response.data['status'];
      return _mapPaymentStatus(status);
    } catch (e) {
      throw PaymentException('Erro ao consultar status do pagamento: $e');
    }
  }

  PaymentStatus _mapPaymentStatus(String status) {
    switch (status) {
      case 'pending':
        return PaymentStatus.pending;
      case 'in_process':
        return PaymentStatus.processing;
      case 'approved':
        return PaymentStatus.completed;
      case 'rejected':
        return PaymentStatus.failed;
      case 'cancelled':
        return PaymentStatus.cancelled;
      default:
        return PaymentStatus.pending;
    }
  }

  // Generate card token (should be done on frontend for security)
  Future<String> createCardToken({
    required String cardNumber,
    required String expirationMonth,
    required String expirationYear,
    required String securityCode,
    required String cardHolderName,
    required String cardHolderCpf,
  }) async {
    try {
      // This should use Mercado Pago JS SDK on web
      // For demonstration purposes only
      final response = await _dio.post(
        'https://api.mercadopago.com/v1/card_tokens',
        data: {
          'card_number': cardNumber,
          'expiration_month': int.parse(expirationMonth),
          'expiration_year': int.parse(expirationYear),
          'security_code': securityCode,
          'cardholder': {
            'name': cardHolderName,
            'identification': {
              'type': 'CPF',
              'number': cardHolderCpf,
            },
          },
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer YOUR_MERCADOPAGO_PUBLIC_KEY',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.data['id'];
    } catch (e) {
      throw PaymentException('Erro ao criar token do cartão: $e');
    }
  }

  // Validate coupon
  Future<CouponValidation> validateCoupon({
    required String couponCode,
    required String restaurantId,
    required double orderAmount,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/coupons/validate',
        data: {
          'code': couponCode,
          'restaurant_id': restaurantId,
          'order_amount': orderAmount,
        },
      );

      return CouponValidation.fromJson(response.data);
    } catch (e) {
      throw PaymentException('Erro ao validar cupom: $e');
    }
  }

  // Calculate delivery fee
  Future<DeliveryFeeCalculation> calculateDeliveryFee({
    required String restaurantId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/delivery/calculate-fee',
        data: {
          'restaurant_id': restaurantId,
          'delivery_latitude': latitude,
          'delivery_longitude': longitude,
        },
      );

      return DeliveryFeeCalculation.fromJson(response.data);
    } catch (e) {
      throw PaymentException('Erro ao calcular taxa de entrega: $e');
    }
  }
}

class PaymentResponse {
  final String id;
  final String status;
  final String? qrCode;
  final String? qrCodeBase64;
  final String? pixCopyAndPaste;
  final DateTime? expirationDate;

  PaymentResponse({
    required this.id,
    required this.status,
    this.qrCode,
    this.qrCodeBase64,
    this.pixCopyAndPaste,
    this.expirationDate,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      id: json['id'].toString(),
      status: json['status'],
      qrCode: json['point_of_interaction']?['transaction_data']?['qr_code'],
      qrCodeBase64: json['point_of_interaction']?['transaction_data']?['qr_code_base64'],
      pixCopyAndPaste: json['point_of_interaction']?['transaction_data']?['qr_code'],
      expirationDate: json['date_of_expiration'] != null 
        ? DateTime.parse(json['date_of_expiration'])
        : null,
    );
  }
}

class CardInfo {
  final String token;
  final String paymentMethodId;
  final int installments;

  CardInfo({
    required this.token,
    required this.paymentMethodId,
    required this.installments,
  });
}

class CouponValidation {
  final bool isValid;
  final double discountAmount;
  final String? discountType; // 'percentage' or 'fixed'
  final String? message;

  CouponValidation({
    required this.isValid,
    required this.discountAmount,
    this.discountType,
    this.message,
  });

  factory CouponValidation.fromJson(Map<String, dynamic> json) {
    return CouponValidation(
      isValid: json['is_valid'] ?? false,
      discountAmount: (json['discount_amount'] ?? 0.0).toDouble(),
      discountType: json['discount_type'],
      message: json['message'],
    );
  }
}

class DeliveryFeeCalculation {
  final double fee;
  final int estimatedTime; // in minutes
  final double distance; // in kilometers

  DeliveryFeeCalculation({
    required this.fee,
    required this.estimatedTime,
    required this.distance,
  });

  factory DeliveryFeeCalculation.fromJson(Map<String, dynamic> json) {
    return DeliveryFeeCalculation(
      fee: (json['fee'] ?? 0.0).toDouble(),
      estimatedTime: json['estimated_time'] ?? 30,
      distance: (json['distance'] ?? 0.0).toDouble(),
    );
  }
}

class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);
}

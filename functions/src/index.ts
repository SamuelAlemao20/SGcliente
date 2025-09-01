
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { MercadoPagoConfig, Payment } from 'mercadopago';

admin.initializeApp();

// Initialize MercadoPago
const client = new MercadoPagoConfig({
  accessToken: functions.config().mercadopago.access_token,
  options: { timeout: 5000 }
});

const payment = new Payment(client);

// Create PIX Payment
export const createPixPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Usuário não autenticado');
  }

  try {
    const paymentData = {
      transaction_amount: data.amount,
      description: data.description,
      payment_method_id: 'pix',
      payer: {
        email: data.payerEmail,
      },
      external_reference: data.orderId,
    };

    const result = await payment.create({ body: paymentData });
    
    return {
      id: result.id,
      status: result.status,
      qr_code: result.point_of_interaction?.transaction_data?.qr_code,
      qr_code_base64: result.point_of_interaction?.transaction_data?.qr_code_base64,
    };
  } catch (error) {
    console.error('Error creating PIX payment:', error);
    throw new functions.https.HttpsError('internal', 'Erro ao criar pagamento PIX');
  }
});

// MercadoPago Webhook
export const mercadopagoWebhook = functions.https.onRequest(async (req, res) => {
  try {
    const { type, data } = req.body;
    
    if (type === 'payment') {
      const paymentId = data.id;
      const paymentInfo = await payment.get({ id: paymentId });
      
      if (paymentInfo.external_reference) {
        const orderId = paymentInfo.external_reference;
        
        // Update order status based on payment status
        let orderStatus = 'pending';
        if (paymentInfo.status === 'approved') {
          orderStatus = 'confirmed';
        } else if (paymentInfo.status === 'rejected') {
          orderStatus = 'cancelled';
        }
        
        await admin.firestore()
          .collection('orders')
          .doc(orderId)
          .update({
            paymentStatus: paymentInfo.status,
            status: orderStatus,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

        // Send notification to user
        await sendOrderUpdateNotification(orderId, orderStatus);
      }
    }
    
    res.status(200).send('OK');
  } catch (error) {
    console.error('Webhook error:', error);
    res.status(500).send('Error');
  }
});

// Send Order Update Notification
export const sendOrderUpdateNotification = functions.firestore
  .document('orders/{orderId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    
    // Only send notification if status changed
    if (before.status !== after.status) {
      const orderId = context.params.orderId;
      const userId = after.userId;
      
      // Get user FCM token
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(userId)
        .get();
      
      const fcmToken = userDoc.data()?.fcmToken;
      
      if (fcmToken) {
        const statusMessages = {
          confirmed: 'Seu pedido foi confirmado!',
          preparing: 'Seu pedido está sendo preparado',
          ready: 'Seu pedido está pronto!',
          onTheWay: 'Seu pedido saiu para entrega',
          delivered: 'Seu pedido foi entregue!',
          cancelled: 'Seu pedido foi cancelado',
        };
        
        const message = {
          token: fcmToken,
          notification: {
            title: 'Atualização do Pedido',
            body: statusMessages[after.status] || 'Status do pedido atualizado',
          },
          data: {
            type: 'order_update',
            orderId: orderId,
            status: after.status,
          },
        };
        
        await admin.messaging().send(message);
      }
    }
  });

// Calculate Delivery Fee
export const calculateDeliveryFee = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Usuário não autenticado');
  }

  try {
    const { restaurantId, deliveryLatitude, deliveryLongitude } = data;
    
    // Get restaurant location
    const restaurantDoc = await admin.firestore()
      .collection('restaurants')
      .doc(restaurantId)
      .get();
    
    if (!restaurantDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Restaurante não encontrado');
    }
    
    const restaurant = restaurantDoc.data()!;
    const restaurantLat = restaurant.address.latitude;
    const restaurantLng = restaurant.address.longitude;
    
    // Calculate distance (Haversine formula)
    const distance = calculateDistance(
      restaurantLat,
      restaurantLng,
      deliveryLatitude,
      deliveryLongitude
    );
    
    // Calculate fee based on distance
    let fee = restaurant.deliveryFee || 0;
    if (distance > 5) {
      fee += (distance - 5) * 2; // R$ 2 per additional km
    }
    
    // Calculate estimated time
    const estimatedTime = Math.ceil(distance * 8 + 20); // 8 min per km + 20 min preparation
    
    return {
      fee: Math.round(fee * 100) / 100, // Round to 2 decimal places
      estimated_time: estimatedTime,
      distance: Math.round(distance * 100) / 100,
    };
  } catch (error) {
    console.error('Error calculating delivery fee:', error);
    throw new functions.https.HttpsError('internal', 'Erro ao calcular taxa de entrega');
  }
});

// Validate Coupon
export const validateCoupon = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Usuário não autenticado');
  }

  try {
    const { code, restaurantId, orderAmount } = data;
    
    const couponQuery = await admin.firestore()
      .collection('coupons')
      .where('code', '==', code)
      .where('isActive', '==', true)
      .limit(1)
      .get();
    
    if (couponQuery.empty) {
      return {
        is_valid: false,
        message: 'Cupom não encontrado ou inválido',
        discount_amount: 0,
      };
    }
    
    const coupon = couponQuery.docs[0].data();
    
    // Check expiration
    if (coupon.expirationDate && coupon.expirationDate.toDate() < new Date()) {
      return {
        is_valid: false,
        message: 'Cupom expirado',
        discount_amount: 0,
      };
    }
    
    // Check minimum order amount
    if (coupon.minimumAmount && orderAmount < coupon.minimumAmount) {
      return {
        is_valid: false,
        message: `Pedido mínimo de R$ ${coupon.minimumAmount.toFixed(2)}`,
        discount_amount: 0,
      };
    }
    
    // Check restaurant restriction
    if (coupon.restaurantIds && !coupon.restaurantIds.includes(restaurantId)) {
      return {
        is_valid: false,
        message: 'Cupom não válido para este restaurante',
        discount_amount: 0,
      };
    }
    
    // Calculate discount
    let discountAmount = 0;
    if (coupon.discountType === 'percentage') {
      discountAmount = (orderAmount * coupon.discountValue) / 100;
      if (coupon.maxDiscountAmount) {
        discountAmount = Math.min(discountAmount, coupon.maxDiscountAmount);
      }
    } else {
      discountAmount = coupon.discountValue;
    }
    
    return {
      is_valid: true,
      discount_amount: Math.round(discountAmount * 100) / 100,
      discount_type: coupon.discountType,
      message: 'Cupom aplicado com sucesso!',
    };
  } catch (error) {
    console.error('Error validating coupon:', error);
    throw new functions.https.HttpsError('internal', 'Erro ao validar cupom');
  }
});

// Helper function to calculate distance between two coordinates
function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371; // Earth radius in kilometers
  const dLat = deg2rad(lat2 - lat1);
  const dLon = deg2rad(lon2 - lon1);
  const a = 
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * 
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const distance = R * c;
  return distance;
}

function deg2rad(deg: number): number {
  return deg * (Math.PI / 180);
}


import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _token;

  String? get token => _token;

  Future<void> initialize() async {
    try {
      // Request permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission for notifications');
        
        // Get token
        _token = await _messaging.getToken(
          vapidKey: 'YOUR_VAPID_KEY', // Replace with your VAPID key
        );
        debugPrint('FCM Token: $_token');

        // Listen to token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          _token = newToken;
          debugPrint('FCM Token refreshed: $newToken');
          // Update token on server
          _updateTokenOnServer(newToken);
        });

        // Configure message handling
        _configureMessageHandling();
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  void _configureMessageHandling() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received message in foreground: ${message.messageId}');
      _handleMessage(message);
    });

    // Handle messages when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message clicked!');
      _handleMessageClick(message);
    });

    // Handle messages when app is opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('App opened from terminated state via notification');
        _handleMessageClick(message);
      }
    });
  }

  void _handleMessage(RemoteMessage message) {
    if (kIsWeb) {
      // Show browser notification for web
      _showWebNotification(message);
    } else {
      // Handle mobile notification
      // You can use local notifications package here
    }
  }

  void _handleMessageClick(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    
    switch (type) {
      case 'order_update':
        final orderId = data['orderId'];
        if (orderId != null) {
          // Navigate to order tracking
          // GoRouter.of(context).go('/orders/tracking/$orderId');
        }
        break;
      case 'promotion':
        final restaurantId = data['restaurantId'];
        if (restaurantId != null) {
          // Navigate to restaurant
          // GoRouter.of(context).go('/restaurants/$restaurantId');
        }
        break;
      default:
        // Handle other notification types
        break;
    }
  }

  void _showWebNotification(RemoteMessage message) {
    if (kIsWeb) {
      try {
        final notification = html.Notification(
          message.notification?.title ?? 'Nova notificação',
          body: message.notification?.body ?? '',
          icon: message.notification?.android?.imageUrl ?? '/icons/icon-192.png',
        );

        notification.onClick.listen((event) {
          _handleMessageClick(message);
          notification.close();
        });

        // Auto close after 5 seconds
        Future.delayed(Duration(seconds: 5), () {
          notification.close();
        });
      } catch (e) {
        debugPrint('Error showing web notification: $e');
      }
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }

  void _updateTokenOnServer(String token) {
    // Update user's FCM token in Firestore
    // This should be called whenever the token changes
    // Implementation depends on your user management system
  }

  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // This would typically be handled by Cloud Functions
    // Include this structure for reference
    /*
    {
      "message": {
        "token": "user_fcm_token",
        "notification": {
          "title": title,
          "body": body,
          "image": "image_url"
        },
        "data": data,
        "webpush": {
          "fcm_options": {
            "link": "https://your-app.com"
          }
        }
      }
    }
    */
  }
}

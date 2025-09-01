
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../presentation/pages/splash_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/auth/forgot_password_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/restaurants/restaurant_list_page.dart';
import '../../presentation/pages/restaurants/restaurant_detail_page.dart';
import '../../presentation/pages/menu/menu_page.dart';
import '../../presentation/pages/cart/cart_page.dart';
import '../../presentation/pages/checkout/checkout_page.dart';
import '../../presentation/pages/orders/order_tracking_page.dart';
import '../../presentation/pages/orders/order_history_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/profile/edit_profile_page.dart';
import '../../presentation/pages/profile/address_page.dart';
import '../../presentation/providers/auth_provider.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isAuthenticated;
      final isAuthRoute = state.location.startsWith('/auth');

      if (!isLoggedIn && !isAuthRoute && state.location != '/splash') {
        return '/auth/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => const MaterialPage(
          child: SplashPage(),
        ),
      ),

      // Auth Routes
      GoRoute(
        path: '/auth/login',
        pageBuilder: (context, state) => const MaterialPage(
          child: LoginPage(),
        ),
      ),
      GoRoute(
        path: '/auth/register',
        pageBuilder: (context, state) => const MaterialPage(
          child: RegisterPage(),
        ),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        pageBuilder: (context, state) => const MaterialPage(
          child: ForgotPasswordPage(),
        ),
      ),

      // Main App Routes
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => const MaterialPage(
          child: HomePage(),
        ),
      ),

      // Restaurants
      GoRoute(
        path: '/restaurants',
        pageBuilder: (context, state) => const MaterialPage(
          child: RestaurantListPage(),
        ),
      ),
      GoRoute(
        path: '/restaurants/:restaurantId',
        pageBuilder: (context, state) {
          final restaurantId = state.pathParameters['restaurantId']!;
          return MaterialPage(
            child: RestaurantDetailPage(restaurantId: restaurantId),
          );
        },
      ),

      // Menu
      GoRoute(
        path: '/menu/:restaurantId',
        pageBuilder: (context, state) {
          final restaurantId = state.pathParameters['restaurantId']!;
          return MaterialPage(
            child: MenuPage(restaurantId: restaurantId),
          );
        },
      ),

      // Cart & Checkout
      GoRoute(
        path: '/cart',
        pageBuilder: (context, state) => const MaterialPage(
          child: CartPage(),
        ),
      ),
      GoRoute(
        path: '/checkout',
        pageBuilder: (context, state) => const MaterialPage(
          child: CheckoutPage(),
        ),
      ),

      // Orders
      GoRoute(
        path: '/orders/tracking/:orderId',
        pageBuilder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return MaterialPage(
            child: OrderTrackingPage(orderId: orderId),
          );
        },
      ),
      GoRoute(
        path: '/orders/history',
        pageBuilder: (context, state) => const MaterialPage(
          child: OrderHistoryPage(),
        ),
      ),

      // Profile
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => const MaterialPage(
          child: ProfilePage(),
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        pageBuilder: (context, state) => const MaterialPage(
          child: EditProfilePage(),
        ),
      ),
      GoRoute(
        path: '/profile/address',
        pageBuilder: (context, state) => const MaterialPage(
          child: AddressPage(),
        ),
      ),
    ],
  );
}

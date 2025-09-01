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
import '../../presentation/providers/auth_provider.dart';

// O resto do código do router permanece o mesmo que enviei anteriormente
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // ... todas as suas rotas aqui
    ],
    redirect: (context, state) {
      return null;

      // ... sua lógica de redirect aqui
    },
  );
}

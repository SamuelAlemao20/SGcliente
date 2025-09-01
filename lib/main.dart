import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sg_sabores_cliente/core/utils/service_locator.dart';
import 'package:sg_sabores_cliente/firebase_options.dart';
import 'package:sg_sabores_cliente/core/theme/app_theme.dart';
import 'package:sg_sabores_cliente/core/router/app_router.dart';
import 'package:sg_sabores_cliente/presentation/providers/auth_provider.dart';
import 'package:sg_sabores_cliente/presentation/providers/cart_provider.dart';
import 'package:sg_sabores_cliente/presentation/providers/restaurant_provider.dart';
import 'package:sg_sabores_cliente/presentation/providers/order_provider.dart';
import 'package:sg_sabores_cliente/presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<CartProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<RestaurantProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<OrderProvider>()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'SG Sabores',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sg_sabores_cliente/presentation/providers/auth_provider.dart';
import 'package:sg_sabores_cliente/presentation/providers/cart_provider.dart';
import 'package:sg_sabores_cliente/presentation/pages/profile/profile_page.dart';
import 'package:sg_sabores_cliente/presentation/pages/restaurants/restaurant_list_page.dart';
import 'package:sg_sabores_cliente/presentation/pages/orders/order_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final cartProvider = context.watch<CartProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Olá, ${authProvider.userProfile?.name.split(' ').first ?? 'Cliente'}!'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Início'),
            Tab(icon: Icon(Icons.restaurant), text: 'Restaurantes'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Pedidos'),
            Tab(icon: Icon(Icons.person), text: 'Perfil'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Center(child: Text('Início')),
          RestaurantListPage(),
          OrderHistoryPage(),
          ProfilePage(),
        ],
      ),
    );
  }
}

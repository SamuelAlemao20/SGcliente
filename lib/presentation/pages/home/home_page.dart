
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/auth_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/floating_cart_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantProvider>(context, listen: false).loadRestaurants();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, ${authProvider.userProfile?.name ?? 'Usuário'}!',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'O que você quer comer hoje?',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundImage: authProvider.userProfile?.photoUrl != null
                  ? CachedNetworkImageProvider(authProvider.userProfile!.photoUrl!)
                  : null,
              child: authProvider.userProfile?.photoUrl == null
                  ? Icon(Icons.person, size: 20)
                  : null,
            ),
            onPressed: () {
              context.push('/profile');
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onBackground.withOpacity(0.6),
          tabs: [
            Tab(text: 'Início'),
            Tab(text: 'Restaurantes'),
            Tab(text: 'Pedidos'),
            Tab(text: 'Perfil'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          _buildRestaurantsTab(),
          _buildOrdersTab(),
          _buildProfileTab(),
        ],
      ),
      floatingActionButton: cartProvider.isNotEmpty
          ? FloatingCartButton(
              itemCount: cartProvider.itemCount,
              total: cartProvider.total,
              onTap: () => context.push('/cart'),
            )
          : null,
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBarWidget(
              onChanged: (query) {
                Provider.of<RestaurantProvider>(context, listen: false)
                    .setSearchQuery(query);
              },
            ),
          ),

          // Featured Banners
          _buildFeaturedBanners(),

          // Categories
          _buildCategoriesSection(),

          // Featured Restaurants
          _buildFeaturedRestaurantsSection(),

          // All Restaurants
          _buildAllRestaurantsSection(),

          const SizedBox(height: 80), // Bottom padding for FAB
        ],
      ),
    );
  }

  Widget _buildFeaturedBanners() {
    return SizedBox(
      height: 180,
      child: PageView(
        children: [
          _buildBanner(
            'Delivery Grátis',
            'Em pedidos acima de R\$ 30',
            'assets/images/banner1.jpg',
            Colors.orange,
          ),
          _buildBanner(
            '20% OFF',
            'Na sua primeira compra',
            'assets/images/banner2.jpg',
            Colors.green,
          ),
          _buildBanner(
            'Promoção',
            'Pizza + Refrigerante',
            'assets/images/banner3.jpg',
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(String title, String subtitle, String image, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.fastfood,
                  size: 60,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Consumer<RestaurantProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Categorias',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: provider.categories.length,
                itemBuilder: (context, index) {
                  final category = provider.categories[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CategoryChip(
                      label: category,
                      isSelected: provider.selectedCategory == category,
                      onTap: () => provider.setSelectedCategory(category),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeaturedRestaurantsSection() {
    return Consumer<RestaurantProvider>(
      builder: (context, provider, child) {
        final featuredRestaurants = provider.restaurants
            .where((r) => r.isFeatured)
            .take(5)
            .toList();

        if (featuredRestaurants.isEmpty) return SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Text(
                'Destaques',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: featuredRestaurants.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 240,
                    child: RestaurantCard(
                      restaurant: featuredRestaurants[index],
                      onTap: () {
                        context.push('/restaurants/${featuredRestaurants[index].id}');
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAllRestaurantsSection() {
    return Consumer<RestaurantProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Todos os restaurantes',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _tabController.animateTo(1); // Switch to restaurants tab
                    },
                    child: Text('Ver todos'),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: provider.restaurants.length > 6 ? 6 : provider.restaurants.length,
              itemBuilder: (context, index) {
                return RestaurantCard(
                  restaurant: provider.restaurants[index],
                  onTap: () {
                    context.push('/restaurants/${provider.restaurants[index].id}');
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRestaurantsTab() {
    return Consumer<RestaurantProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Search and Filter
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SearchBarWidget(
                    onChanged: (query) => provider.setSearchQuery(query),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: provider.categories.length,
                      itemBuilder: (context, index) {
                        final category = provider.categories[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CategoryChip(
                            label: category,
                            isSelected: provider.selectedCategory == category,
                            onTap: () => provider.setSelectedCategory(category),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Restaurants List
            Expanded(
              child: provider.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : provider.restaurants.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant,
                                size: 64,
                                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhum restaurante encontrado',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => provider.loadRestaurants(),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: provider.restaurants.length,
                            itemBuilder: (context, index) {
                              return RestaurantCard(
                                restaurant: provider.restaurants[index],
                                onTap: () {
                                  context.push('/restaurants/${provider.restaurants[index].id}');
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrdersTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Histórico de Pedidos',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Seus pedidos aparecerão aqui',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.push('/orders/history');
            },
            child: Text('Ver histórico completo'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: authProvider.userProfile?.photoUrl != null
                      ? CachedNetworkImageProvider(authProvider.userProfile!.photoUrl!)
                      : null,
                  child: authProvider.userProfile?.photoUrl == null
                      ? Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  authProvider.userProfile?.name ?? 'Usuário',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  authProvider.userProfile?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Profile Options
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildProfileOption(
                  icon: Icons.person_outline,
                  title: 'Editar Perfil',
                  onTap: () => context.push('/profile/edit'),
                ),
                _buildProfileOption(
                  icon: Icons.location_on_outlined,
                  title: 'Endereços',
                  onTap: () => context.push('/profile/address'),
                ),
                _buildProfileOption(
                  icon: Icons.receipt_long_outlined,
                  title: 'Histórico de Pedidos',
                  onTap: () => context.push('/orders/history'),
                ),
                _buildProfileOption(
                  icon: Icons.dark_mode_outlined,
                  title: 'Tema Escuro',
                  trailing: Switch(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (value) {
                      // Handle theme change
                    },
                  ),
                ),
                _buildProfileOption(
                  icon: Icons.help_outline,
                  title: 'Ajuda',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.logout,
                  title: 'Sair',
                  onTap: () => authProvider.signOut(),
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive 
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive 
              ? Theme.of(context).colorScheme.error
              : null,
        ),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

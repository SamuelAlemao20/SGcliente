
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/restaurant_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/floating_cart_button.dart';

class RestaurantListPage extends StatefulWidget {
  const RestaurantListPage({Key? key}) : super(key: key);

  @override
  State<RestaurantListPage> createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantProvider>(context, listen: false).loadRestaurants();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurantes'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<RestaurantProvider>(
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

              // Results Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      '${provider.restaurants.length} restaurantes encontrados',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
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
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () => provider.loadRestaurants(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16.0),
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

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 64,
            color: theme.colorScheme.onBackground.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum restaurante encontrado',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros de busca',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

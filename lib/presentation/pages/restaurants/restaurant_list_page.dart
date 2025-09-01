import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/search_bar_widget.dart';

class RestaurantListPage extends StatelessWidget {
  const RestaurantListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
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
                              onTap: () =>
                                  provider.setSelectedCategory(category),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.restaurants.isEmpty
                        ? _buildEmptyState(context)
                        : RefreshIndicator(
                            onRefresh: () => provider.loadRestaurants(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: provider.restaurants.length,
                              itemBuilder: (context, index) {
                                return RestaurantCard(
                                  restaurant: provider.restaurants[index],
                                  onTap: () => context.push(
                                      '/restaurants/${provider.restaurants[index].id}'),
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu_outlined,
              size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Nenhum restaurante encontrado',
              style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Tente ajustar os filtros de busca',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}

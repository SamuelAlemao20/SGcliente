
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/restaurant_provider.dart';
import '../../providers/cart_provider.dart';
import '../../domain/entities/product.dart';
import '../../widgets/floating_cart_button.dart';
import '../../widgets/product_option_modal.dart';

class MenuPage extends StatefulWidget {
  final String restaurantId;

  const MenuPage({
    Key? key,
    required this.restaurantId,
  }) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MenuCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMenu() async {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    final categories = await provider.getRestaurantMenu(widget.restaurantId);
    
    setState(() {
      _categories = categories;
      _isLoading = false;
      _tabController = TabController(length: categories.length, vsync: this);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartProvider = Provider.of<CartProvider>(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Cardápio')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Cardápio')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 64,
                color: theme.colorScheme.onBackground.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text('Nenhum item disponível no momento'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Cardápio'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onBackground.withOpacity(0.6),
          tabs: _categories.map((category) {
            return Tab(text: category.name);
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((category) {
          return _buildCategoryTab(category);
        }).toList(),
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

  Widget _buildCategoryTab(MenuCategory category) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: category.products.length,
      itemBuilder: (context, index) {
        final product = category.products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showProductOptions(product),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: theme.colorScheme.surface,
                    child: Icon(Icons.fastfood),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: theme.colorScheme.surface,
                    child: Icon(Icons.fastfood),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      product.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Price
                    Row(
                      children: [
                        if (product.hasDiscount) ...[
                          Text(
                            'R\$ ${product.price.toStringAsFixed(2)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          'R\$ ${product.finalPrice.toStringAsFixed(2)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${((product.discount! / product.price) * 100).round()}% OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Allergens
                    if (product.allergens.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: product.allergens.map((allergen) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              allergen,
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),

              // Add Button
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: product.isAvailable 
                          ? () => _showProductOptions(product)
                          : null,
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.preparationTime} min',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductOptions(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductOptionModal(
        product: product,
        restaurantId: widget.restaurantId,
        onAddToCart: (product, options, addons, quantity, notes) {
          final cartProvider = Provider.of<CartProvider>(context, listen: false);
          final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
          
          // Get restaurant name (you might want to cache this)
          restaurantProvider.getRestaurantById(widget.restaurantId).then((restaurant) {
            try {
              cartProvider.addItem(
                product: product,
                restaurantId: widget.restaurantId,
                restaurantName: restaurant?.name ?? 'Restaurante',
                quantity: quantity,
                selectedOptions: options,
                selectedAddons: addons,
                notes: notes,
              );
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} adicionado ao carrinho!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          });
        },
      ),
    );
  }
}

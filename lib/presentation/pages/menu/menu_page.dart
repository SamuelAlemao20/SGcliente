import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sg_sabores_cliente/domain/entities/product.dart';
import 'package:sg_sabores_cliente/presentation/providers/restaurant_provider.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key, required this.restaurantId}) : super(key: key);
  final String restaurantId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cardápio')),
      body: FutureBuilder<List<MenuCategory>>(
        future:
            context.read<RestaurantProvider>().getRestaurantMenu(restaurantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Cardápio indisponível.'));
          }
          final categories = snapshot.data!;
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ExpansionTile(
                title: Text(category.name,
                    style: Theme.of(context).textTheme.titleLarge),
                children: category.products
                    .map((product) => ListTile(title: Text(product.name)))
                    .toList(),
              );
            },
          );
        },
      ),
    );
  }
}

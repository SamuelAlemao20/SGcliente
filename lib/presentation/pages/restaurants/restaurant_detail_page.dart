import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sg_sabores_cliente/domain/entities/restaurant.dart';
import 'package:sg_sabores_cliente/presentation/providers/restaurant_provider.dart';

class RestaurantDetailPage extends StatelessWidget {
  const RestaurantDetailPage({Key? key, required this.restaurantId})
      : super(key: key);
  final String restaurantId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<Restaurant?>(
        future:
            context.read<RestaurantProvider>().getRestaurantById(restaurantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Restaurante não encontrado.'));
          }
          final restaurant = snapshot.data!;
          return Center(
            child: Text(restaurant.name,
                style: Theme.of(context).textTheme.headlineMedium),
          );
        },
      ),
    );
  }
}

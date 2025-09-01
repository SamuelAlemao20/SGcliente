import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sg_sabores_cliente/presentation/providers/cart_provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Carrinho')),
      body: cartProvider.isEmpty
          ? const Center(child: Text('Seu carrinho está vazio.'))
          : ListView.builder(
              itemCount: cartProvider.items.length,
              itemBuilder: (context, index) {
                final item = cartProvider.items[index];
                return ListTile(
                  title: Text(item.product.name),
                  subtitle: Text('Qtd: ${item.quantity}'),
                  trailing: Text('R\$ ${item.totalPrice.toStringAsFixed(2)}'),
                );
              },
            ),
    );
  }
}

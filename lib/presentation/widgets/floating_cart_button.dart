import 'package:flutter/material.dart';

class FloatingCartButton extends StatelessWidget {
  const FloatingCartButton({
    Key? key,
    required this.itemCount,
    required this.total,
    required this.onTap,
  }) : super(key: key);
  final int itemCount;
  final double total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onTap,
      label: Text('Ver Carrinho (R\$ ${total.toStringAsFixed(2)})'),
      icon: Badge(
        label: Text(itemCount.toString()),
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}

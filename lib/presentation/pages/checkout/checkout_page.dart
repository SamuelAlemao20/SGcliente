import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sg_sabores_cliente/domain/entities/order.dart';
import 'package:sg_sabores_cliente/domain/entities/user.dart' as app_user;
import 'package:sg_sabores_cliente/domain/entities/address.dart';
import 'package:sg_sabores_cliente/presentation/providers/cart_provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.pix;
  Address? _selectedAddress;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar Pedido')),
      body: Center(child: Text('Total: R\$ ${cart.total.toStringAsFixed(2)}')),
    );
  }
}

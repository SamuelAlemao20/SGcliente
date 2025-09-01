import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sg_sabores_cliente/domain/entities/order.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key, required this.orderId}) : super(key: key);
  final String orderId;
  @override
  _OrderTrackingPageState createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pedido #${widget.orderId}')),
      body: const Center(child: Text('Acompanhamento do Pedido')),
    );
  }
}

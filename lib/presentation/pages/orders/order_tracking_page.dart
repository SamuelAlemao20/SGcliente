
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../providers/order_provider.dart';
import '../../domain/entities/order.dart';
import '../../widgets/custom_button.dart';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;

  const OrderTrackingPage({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  StreamSubscription<Order?>? _orderSubscription;

  @override
  void initState() {
    super.initState();
    _startOrderTracking();
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }

  void _startOrderTracking() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    
    _orderSubscription = orderProvider.watchOrder(widget.orderId).listen((order) {
      // Order updates are handled automatically by the provider
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final order = orderProvider.currentOrder;

    return Scaffold(
      appBar: AppBar(
        title: Text('Acompanhar Pedido'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              orderProvider.loadOrderById(widget.orderId);
            },
          ),
        ],
      ),
      body: orderProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : order == null
              ? _buildOrderNotFound()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Order Header
                      _buildOrderHeader(order),

                      // Order Status Timeline
                      _buildStatusTimeline(order),

                      // Order Details
                      _buildOrderDetails(order),

                      // Payment Info
                      if (order.paymentMethod == PaymentMethod.pix)
                        _buildPixPaymentInfo(order),

                      // Actions
                      _buildActionButtons(order),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildOrderNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text('Pedido não encontrado'),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(Order order) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
      ),
      child: Column(
        children: [
          Text(
            'Pedido #${order.trackingCode}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order.statusText,
            style: theme.textTheme.titleMedium?.copyWith(
              color: _getStatusColor(order.status),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (order.estimatedDeliveryTime != null) ...[
            const SizedBox(height: 8),
            Text(
              'Previsão: ${_formatTime(order.estimatedDeliveryTime!)}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(Order order) {
    final theme = Theme.of(context);
    final statuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.onTheWay,
      OrderStatus.delivered,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status do Pedido',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...statuses.map((status) {
            final isCompleted = _isStatusCompleted(order.status, status);
            final isCurrent = order.status == status;
            
            return _buildTimelineItem(
              title: _getStatusTitle(status),
              subtitle: _getStatusSubtitle(status),
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLast: status == statuses.last,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        // Timeline Indicator
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted || isCurrent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? Icon(Icons.check, color: Colors.white, size: 16)
                  : isCurrent
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.3),
              ),
          ],
        ),

        const SizedBox(width: 16),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted || isCurrent
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              if (!isLast) const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails(Order order) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detalhes do Pedido',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Items
              ...order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text('${item.quantity}x '),
                      Expanded(child: Text(item.name)),
                      Text('R\$ ${item.totalPrice.toStringAsFixed(2)}'),
                    ],
                  ),
                );
              }).toList(),

              const Divider(),

              // Summary
              _buildSummaryRow('Subtotal', order.subtotal),
              _buildSummaryRow('Taxa de entrega', order.deliveryFee),
              if (order.couponDiscount != null && order.couponDiscount! > 0)
                _buildSummaryRow('Desconto', -order.couponDiscount!, isDiscount: true),
              const SizedBox(height: 8),
              _buildSummaryRow('Total', order.total, isTotal: true),

              const SizedBox(height: 12),

              // Payment Method
              Row(
                children: [
                  Icon(Icons.payment, size: 16),
                  const SizedBox(width: 8),
                  Text('Pagamento: ${order.paymentMethodText}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPixPaymentInfo(Order order) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Pagamento PIX',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Escaneie o QR Code ou copie o código PIX para efetuar o pagamento',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              
              // QR Code placeholder
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code, size: 60),
                      const SizedBox(height: 8),
                      Text('QR Code PIX'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              CustomButton(
                text: 'Copiar código PIX',
                onPressed: () {
                  // Copy PIX code to clipboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Código PIX copiado!')),
                  );
                },
                isOutlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(Order order) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // WhatsApp Button
          CustomButton(
            text: 'Falar com Restaurante',
            onPressed: () {
              _openWhatsApp();
            },
            icon: Icons.chat,
            isOutlined: true,
          ),
          
          const SizedBox(height: 12),
          
          // Cancel Button (only if order can be cancelled)
          if (_canCancelOrder(order.status))
            CustomButton(
              text: 'Cancelar Pedido',
              onPressed: () => _cancelOrder(order.id),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isTotal = false, bool isDiscount = false}) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal 
                ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)
                : theme.textTheme.bodyMedium,
          ),
          Text(
            '${value < 0 ? '-' : ''}R\$ ${value.abs().toStringAsFixed(2)}',
            style: isTotal 
                ? theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  )
                : isDiscount
                    ? theme.textTheme.bodyMedium?.copyWith(color: Colors.green)
                    : theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.ready:
      case OrderStatus.onTheWay:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  bool _isStatusCompleted(OrderStatus currentStatus, OrderStatus checkStatus) {
    final statusOrder = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.onTheWay,
      OrderStatus.delivered,
    ];

    final currentIndex = statusOrder.indexOf(currentStatus);
    final checkIndex = statusOrder.indexOf(checkStatus);

    return currentIndex >= checkIndex;
  }

  String _getStatusTitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pedido Realizado';
      case OrderStatus.confirmed:
        return 'Pedido Confirmado';
      case OrderStatus.preparing:
        return 'Preparando';
      case OrderStatus.ready:
        return 'Pronto';
      case OrderStatus.onTheWay:
        return 'Saiu para Entrega';
      case OrderStatus.delivered:
        return 'Entregue';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  String _getStatusSubtitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Aguardando confirmação do restaurante';
      case OrderStatus.confirmed:
        return 'Restaurante confirmou seu pedido';
      case OrderStatus.preparing:
        return 'Seu pedido está sendo preparado';
      case OrderStatus.ready:
        return 'Pedido pronto para entrega';
      case OrderStatus.onTheWay:
        return 'Entregador a caminho';
      case OrderStatus.delivered:
        return 'Pedido entregue com sucesso';
      case OrderStatus.cancelled:
        return 'Pedido foi cancelado';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  bool _canCancelOrder(OrderStatus status) {
    return status == OrderStatus.pending || status == OrderStatus.confirmed;
  }

  void _openWhatsApp() {
    // Open WhatsApp or show restaurant contact
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abrindo WhatsApp...')),
    );
  }

  Future<void> _cancelOrder(String orderId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancelar Pedido'),
        content: Text('Tem certeza que deseja cancelar este pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Sim, cancelar'),
          ),
        ],
      ),
    );

    if (result == true) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      await orderProvider.cancelOrder(orderId);
    }
  }
}

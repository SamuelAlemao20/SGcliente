
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/user.dart' as app_user;
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.pix;
  app_user.Address? _selectedAddress;
  final _notesController = TextEditingController();
  final _changeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _changeController.dispose();
    super.dispose();
  }

  void _loadDefaultAddress() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final addresses = authProvider.userProfile?.addresses ?? [];
    
    if (addresses.isNotEmpty) {
      _selectedAddress = addresses.firstWhere(
        (addr) => addr.isDefault,
        orElse: () => addresses.first,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    return LoadingOverlay(
      isLoading: orderProvider.isLoading,
      message: 'Finalizando pedido...',
      child: Scaffold(
        appBar: AppBar(
          title: Text('Finalizar Pedido'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Address
              _buildAddressSection(authProvider),

              const Divider(),

              // Payment Method
              _buildPaymentSection(),

              const Divider(),

              // Order Notes
              _buildNotesSection(),

              const Divider(),

              // Order Summary
              _buildOrderSummary(cartProvider),

              const SizedBox(height: 20),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: CustomButton(
            text: 'Confirmar Pedido - R\$ ${cartProvider.total.toStringAsFixed(2)}',
            onPressed: _canPlaceOrder() ? _placeOrder : null,
          ),
        ),
      ),
    );
  }

  Widget _buildAddressSection(AuthProvider authProvider) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Endereço de Entrega',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          if (_selectedAddress != null) ...[
            Card(
              child: ListTile(
                leading: Icon(Icons.location_on, color: theme.colorScheme.primary),
                title: Text(_selectedAddress!.label),
                subtitle: Text(_selectedAddress!.fullAddress),
                trailing: Icon(Icons.edit),
                onTap: () => context.push('/profile/address'),
              ),
            ),
          ] else ...[
            Card(
              child: ListTile(
                leading: Icon(Icons.add_location, color: theme.colorScheme.primary),
                title: Text('Adicionar endereço'),
                subtitle: Text('Você precisa de um endereço para continuar'),
                trailing: Icon(Icons.chevron_right),
                onTap: () => context.push('/profile/address'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Forma de Pagamento',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // PIX
          _buildPaymentOption(
            method: PaymentMethod.pix,
            icon: Icons.pix,
            title: 'PIX',
            subtitle: 'Aprovação imediata',
          ),
          
          // Credit Card
          _buildPaymentOption(
            method: PaymentMethod.creditCard,
            icon: Icons.credit_card,
            title: 'Cartão de Crédito',
            subtitle: 'Visa, Master, Elo',
          ),
          
          // Debit Card
          _buildPaymentOption(
            method: PaymentMethod.debitCard,
            icon: Icons.credit_card,
            title: 'Cartão de Débito',
            subtitle: 'Débito online',
          ),
          
          // Cash
          _buildPaymentOption(
            method: PaymentMethod.cash,
            icon: Icons.attach_money,
            title: 'Dinheiro',
            subtitle: 'Pagamento na entrega',
          ),

          // Change field for cash payment
          if (_selectedPaymentMethod == PaymentMethod.cash) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _changeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Troco para quanto?',
                hintText: 'Ex: 50.00',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: RadioListTile<PaymentMethod>(
        value: method,
        groupValue: _selectedPaymentMethod,
        onChanged: (value) {
          setState(() {
            _selectedPaymentMethod = value!;
          });
        },
        title: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Observações (Opcional)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ex: Sem cebola, ponto da carne, etc.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo do Pedido',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Items count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${cartProvider.itemCount} itens'),
                      Text('R\$ ${cartProvider.subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Delivery fee
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Taxa de entrega'),
                      Text(
                        cartProvider.deliveryFee == 0
                            ? 'Grátis'
                            : 'R\$ ${cartProvider.deliveryFee.toStringAsFixed(2)}',
                        style: cartProvider.deliveryFee == 0
                            ? TextStyle(color: Colors.green)
                            : null,
                      ),
                    ],
                  ),
                  
                  // Coupon discount
                  if (cartProvider.couponDiscount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Desconto (${cartProvider.couponCode})'),
                        Text(
                          '- R\$ ${cartProvider.couponDiscount.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                  
                  const Divider(),
                  
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'R\$ ${cartProvider.total.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canPlaceOrder() {
    return _selectedAddress != null && 
           !Provider.of<OrderProvider>(context, listen: false).isLoading;
  }

  Future<void> _placeOrder() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final orderId = await orderProvider.createOrder(
      restaurantId: cartProvider.restaurantId!,
      items: cartProvider.toOrderItems(),
      subtotal: cartProvider.subtotal,
      deliveryFee: cartProvider.deliveryFee,
      paymentMethod: _selectedPaymentMethod,
      deliveryAddress: _selectedAddress!,
      notes: _notesController.text.trim().isNotEmpty 
          ? _notesController.text.trim()
          : null,
      couponCode: cartProvider.couponCode,
      couponDiscount: cartProvider.couponDiscount,
    );

    if (orderId != null) {
      // Clear cart
      cartProvider.clearCart();
      
      // Navigate to order tracking
      context.go('/orders/tracking/$orderId');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pedido realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.error ?? 'Erro ao criar pedido'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

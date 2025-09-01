
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/product.dart';
import 'custom_button.dart';

class ProductOptionModal extends StatefulWidget {
  final Product product;
  final String restaurantId;
  final Function(
    Product product,
    List<ProductOptionItem> selectedOptions,
    List<ProductAddon> selectedAddons,
    int quantity,
    String? notes,
  ) onAddToCart;

  const ProductOptionModal({
    Key? key,
    required this.product,
    required this.restaurantId,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  State<ProductOptionModal> createState() => _ProductOptionModalState();
}

class _ProductOptionModalState extends State<ProductOptionModal> {
  int _quantity = 1;
  Map<String, ProductOptionItem> _selectedOptions = {};
  Set<ProductAddon> _selectedAddons = {};
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    double basePrice = widget.product.finalPrice;
    double optionsPrice = _selectedOptions.values.fold(0, (sum, option) => sum + option.additionalPrice);
    double addonsPrice = _selectedAddons.fold(0, (sum, addon) => sum + addon.price);
    return (basePrice + optionsPrice + addonsPrice) * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  CachedNetworkImage(
                    imageUrl: widget.product.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: theme.colorScheme.surface,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: theme.colorScheme.surface,
                      child: Icon(Icons.fastfood, size: 60),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name and Price
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.name,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              'R\$ ${widget.product.finalPrice.toStringAsFixed(2)}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Description
                        Text(
                          widget.product.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Product Options
                        ...widget.product.options.map((option) => _buildOptionSection(option)),

                        // Product Addons
                        if (widget.product.addons.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildAddonsSection(),
                        ],

                        // Notes
                        const SizedBox(height: 16),
                        _buildNotesSection(),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Section
          Container(
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
            child: Row(
              children: [
                // Quantity Controls
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _quantity > 1 ? () {
                          setState(() {
                            _quantity--;
                          });
                        } : null,
                        icon: Icon(Icons.remove),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _quantity.toString(),
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _quantity++;
                          });
                        },
                        icon: Icon(Icons.add),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Add to Cart Button
                Expanded(
                  child: CustomButton(
                    text: 'Adicionar - R\$ ${_totalPrice.toStringAsFixed(2)}',
                    onPressed: _addToCart,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionSection(ProductOption option) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          option.name + (option.isRequired ? ' *' : ' (Opcional)'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        ...option.items.map((item) {
          final isSelected = _selectedOptions[option.id]?.id == item.id;
          
          return Card(
            child: CheckboxListTile(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedOptions[option.id] = item;
                  } else {
                    _selectedOptions.remove(option.id);
                  }
                });
              },
              title: Text(item.name),
              subtitle: item.additionalPrice > 0
                  ? Text('+ R\$ ${item.additionalPrice.toStringAsFixed(2)}')
                  : null,
            ),
          );
        }).toList(),
        
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAddonsSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adicionais (Opcional)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        ...widget.product.addons.map((addon) {
          final isSelected = _selectedAddons.contains(addon);
          
          return Card(
            child: CheckboxListTile(
              value: isSelected,
              onChanged: addon.isAvailable ? (value) {
                setState(() {
                  if (value == true) {
                    _selectedAddons.add(addon);
                  } else {
                    _selectedAddons.remove(addon);
                  }
                });
              } : null,
              title: Text(addon.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (addon.description != null)
                    Text(addon.description!),
                  Text('+ R\$ ${addon.price.toStringAsFixed(2)}'),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildNotesSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observações (Opcional)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Ex: Sem cebola, ponto da carne, etc.',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  void _addToCart() {
    // Validate required options
    for (final option in widget.product.options) {
      if (option.isRequired && !_selectedOptions.containsKey(option.id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor, selecione uma opção para ${option.name}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
    }

    widget.onAddToCart(
      widget.product,
      _selectedOptions.values.toList(),
      _selectedAddons.toList(),
      _quantity,
      _notesController.text.trim().isNotEmpty 
          ? _notesController.text.trim() 
          : null,
    );

    Navigator.of(context).pop();
  }
}

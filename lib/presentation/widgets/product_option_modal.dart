import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/product.dart';
import 'custom_button.dart';

class ProductOptionModal extends StatefulWidget {
  const ProductOptionModal({
    Key? key,
    required this.product,
    required this.restaurantId,
    required this.onAddToCart,
  }) : super(key: key);
  final Product product;
  final String restaurantId;
  final Function(
    Product product,
    List<ProductOptionItem> selectedOptions,
    List<ProductAddon> selectedAddons,
    int quantity,
    String? notes,
  ) onAddToCart;

  @override
  State<ProductOptionModal> createState() => _ProductOptionModalState();
}

class _ProductOptionModalState extends State<ProductOptionModal> {
  int _quantity = 1;
  // Simplificando o estado para opções e adicionais
  final Map<String, ProductOptionItem> _selectedOptions = {};
  final Set<String> _selectedAddons = {};
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    var basePrice = widget.product.finalPrice;

    double optionsPrice = 0;
    _selectedOptions.forEach((key, value) {
      optionsPrice += value.additionalPrice;
    });

    double addonsPrice = 0;
    for (final addonId in _selectedAddons) {
      addonsPrice +=
          widget.product.addons.firstWhere((a) => a.id == addonId).price;
    }

    return (basePrice + optionsPrice + addonsPrice) * _quantity;
  }

  void _addToCart() {
    // Validação de opções obrigatórias
    for (final option in widget.product.options) {
      if (option.isRequired && !_selectedOptions.containsKey(option.id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selecione uma opção para "${option.name}"')),
        );
        return;
      }
    }

    final selectedAddonsList = widget.product.addons
        .where((addon) => _selectedAddons.contains(addon.id))
        .toList();

    widget.onAddToCart(
      widget.product,
      _selectedOptions.values.toList(),
      selectedAddonsList,
      _quantity,
      _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    _buildHeader(theme),
                    ...widget.product.options
                        .map((option) => _buildOptionSection(theme, option)),
                    if (widget.product.addons.isNotEmpty)
                      _buildAddonsSection(theme),
                    _buildNotesSection(theme),
                  ],
                ),
              ),
              _buildBottomBar(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.product.name,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(widget.product.description,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildOptionSection(ThemeData theme, ProductOption option) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              '${option.name} ${option.isRequired ? "(Obrigatório)" : "(Opcional)"}',
              style: theme.textTheme.titleLarge),
          ...option.items.map((item) {
            return RadioListTile<String>(
              title: Text(item.name),
              subtitle: item.additionalPrice > 0
                  ? Text('+ R\$ ${item.additionalPrice.toStringAsFixed(2)}')
                  : null,
              value: item.id,
              groupValue: _selectedOptions[option.id]?.id,
              onChanged: (value) {
                setState(() {
                  _selectedOptions[option.id] = item;
                });
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAddonsSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Adicionais', style: theme.textTheme.titleLarge),
          ...widget.product.addons.map((addon) {
            return CheckboxListTile(
              title: Text(addon.name),
              subtitle: Text('+ R\$ ${addon.price.toStringAsFixed(2)}'),
              value: _selectedAddons.contains(addon.id),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedAddons.add(addon.id);
                  } else {
                    _selectedAddons.remove(addon.id);
                  }
                });
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotesSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Observações (Opcional)',
          hintText: 'Ex: Sem cebola, ponto da carne, etc.',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Row(
            children: [
              IconButton(
                  onPressed:
                      _quantity > 1 ? () => setState(() => _quantity--) : null,
                  icon: const Icon(Icons.remove)),
              Text(_quantity.toString(), style: theme.textTheme.titleLarge),
              IconButton(
                  onPressed: () => setState(() => _quantity++),
                  icon: const Icon(Icons.add)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: 'Adicionar - R\$ ${_totalPrice.toStringAsFixed(2)}',
              onPressed: _addToCart,
            ),
          ),
        ],
      ),
    );
  }
}

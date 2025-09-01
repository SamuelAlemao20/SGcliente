
class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String categoryId;
  final bool isAvailable;
  final List<ProductOption> options;
  final List<ProductAddon> addons;
  final int preparationTime;
  final List<String> allergens;
  final double? discount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.categoryId,
    this.isAvailable = true,
    this.options = const [],
    this.addons = const [],
    this.preparationTime = 15,
    this.allergens = const [],
    this.discount,
    required this.createdAt,
    required this.updatedAt,
  });

  double get finalPrice {
    if (discount != null && discount! > 0) {
      return price - discount!;
    }
    return price;
  }

  bool get hasDiscount => discount != null && discount! > 0;

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    double? price,
    String? categoryId,
    bool? isAvailable,
    List<ProductOption>? options,
    List<ProductAddon>? addons,
    int? preparationTime,
    List<String>? allergens,
    double? discount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      isAvailable: isAvailable ?? this.isAvailable,
      options: options ?? this.options,
      addons: addons ?? this.addons,
      preparationTime: preparationTime ?? this.preparationTime,
      allergens: allergens ?? this.allergens,
      discount: discount ?? this.discount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ProductOption {
  final String id;
  final String name;
  final double additionalPrice;
  final bool isRequired;
  final List<ProductOptionItem> items;

  ProductOption({
    required this.id,
    required this.name,
    this.additionalPrice = 0.0,
    this.isRequired = false,
    this.items = const [],
  });
}

class ProductOptionItem {
  final String id;
  final String name;
  final double additionalPrice;

  ProductOptionItem({
    required this.id,
    required this.name,
    this.additionalPrice = 0.0,
  });
}

class ProductAddon {
  final String id;
  final String name;
  final double price;
  final String? description;
  final bool isAvailable;

  ProductAddon({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.isAvailable = true,
  });
}

class MenuCategory {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int order;
  final List<Product> products;

  MenuCategory({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.order = 0,
    this.products = const [],
  });

  MenuCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? order,
    List<Product>? products,
  }) {
    return MenuCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
      products: products ?? this.products,
    );
  }
}

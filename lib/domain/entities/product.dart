class Product {
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.categoryId,
    this.discount,
    this.options = const [],
    this.addons = const [],
    required this.createdAt,
    required this.updatedAt,
  });
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String categoryId;
  final double? discount;
  final List<ProductOption> options;
  final List<ProductAddon> addons;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get finalPrice =>
      (discount != null && discount! > 0) ? price - discount! : price;
}

class MenuCategory {
  MenuCategory(
      {required this.id, required this.name, this.products = const []});
  final String id;
  final String name;
  final List<Product> products;
}

class ProductOption {
  ProductOption(
      {required this.id,
      required this.name,
      this.isRequired = false,
      this.items = const []});
  final String id;
  final String name;
  final bool isRequired;
  final List<ProductOptionItem> items;
}

class ProductOptionItem {
  ProductOptionItem(
      {required this.id, required this.name, this.additionalPrice = 0.0});
  final String id;
  final String name;
  final double additionalPrice;
}

class ProductAddon {
  ProductAddon({required this.id, required this.name, required this.price});
  final String id;
  final String name;
  final double price;
}

import 'package:sg_sabores_cliente/domain/entities/address.dart';

class Restaurant {
  // Opcional: Adicionar workingHours se necessário no futuro
  // final WorkingHours workingHours;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.deliveryFee,
    required this.deliveryTime,
    required this.isOpen,
    required this.isFeatured,
    required this.tags,
    required this.address,
  });
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final double deliveryFee;
  final int deliveryTime;
  final bool isOpen;
  final bool isFeatured;
  final List<String> tags;
  final Address address;
}

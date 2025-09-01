import 'package:sg_sabores_cliente/domain/entities/address.dart';

class User {
  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.addresses = const [],
    required this.createdAt,
    required this.updatedAt,
  });
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final List<Address> addresses;
  final DateTime createdAt;
  final DateTime updatedAt;
}

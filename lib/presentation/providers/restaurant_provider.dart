import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sg_sabores_cliente/domain/entities/restaurant.dart';
import 'package:sg_sabores_cliente/domain/entities/product.dart';
import 'package:sg_sabores_cliente/domain/entities/address.dart';
import 'package:sg_sabores_cliente/services/firestore_service.dart';
import 'package:sg_sabores_cliente/core/utils/service_locator.dart';

class RestaurantProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = getIt<FirestoreService>();

  List<Restaurant> _restaurants = [];
  List<Restaurant> get restaurants => _restaurants;

  List<String> _categories = [];
  List<String> get categories => _categories;

  String _selectedCategory = 'Todos';
  String get selectedCategory => _selectedCategory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setSearchQuery(String query) {
    // Lógica de busca
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<Restaurant?> getRestaurantById(String id) async {
    return null;
  }

  Future<List<MenuCategory>> getRestaurantMenu(String restaurantId) async {
    return [];
  }

  Restaurant _mapRestaurantFromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Restaurant(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      deliveryFee: (data['deliveryFee'] ?? 0.0).toDouble(),
      deliveryTime: data['deliveryTime'] ?? 0,
      isOpen: data['isOpen'] ?? false,
      isFeatured: data['isFeatured'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
      address: _mapAddressFromFirestore(data['address'] ?? {}),
    );
  }

  Address _mapAddressFromFirestore(Map<String, dynamic> data) {
    return Address(
        id: '',
        label: '',
        street: '',
        number: '',
        neighborhood: '',
        city: '',
        state: '',
        zipCode: '');
  }
}

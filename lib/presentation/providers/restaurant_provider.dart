
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/restaurant.dart';
import '../../domain/entities/product.dart';
import '../../services/firestore_service.dart';
import '../../core/utils/service_locator.dart';

class RestaurantProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = getIt<FirestoreService>();

  List<Restaurant> _restaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  List<String> _categories = [];
  String _selectedCategory = 'Todos';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  List<Restaurant> get restaurants => _filteredRestaurants;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  RestaurantProvider() {
    loadRestaurants();
  }

  Future<void> loadRestaurants() async {
    try {
      _setLoading(true);
      _clearError();

      final querySnapshot = await _firestoreService.readCollection(
        'restaurants',
        queryBuilder: (query) => query.orderBy('name'),
      );

      _restaurants = querySnapshot.docs
          .map((doc) => _mapRestaurantFromFirestore(doc))
          .toList();

      _extractCategories();
      _applyFilters();
    } catch (e) {
      _setError('Erro ao carregar restaurantes: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<Restaurant?> getRestaurantById(String id) async {
    try {
      final doc = await _firestoreService.read('restaurants', id);
      if (doc.exists) {
        return _mapRestaurantFromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error loading restaurant: $e');
      return null;
    }
  }

  Future<List<MenuCategory>> getRestaurantMenu(String restaurantId) async {
    try {
      final querySnapshot = await _firestoreService.readCollection(
        'products',
        queryBuilder: (query) => query
            .where('restaurantId', isEqualTo: restaurantId)
            .where('isAvailable', isEqualTo: true)
            .orderBy('categoryId')
            .orderBy('name'),
      );

      final products = querySnapshot.docs
          .map((doc) => _mapProductFromFirestore(doc))
          .toList();

      // Group products by category
      final Map<String, List<Product>> groupedProducts = {};
      for (final product in products) {
        if (!groupedProducts.containsKey(product.categoryId)) {
          groupedProducts[product.categoryId] = [];
        }
        groupedProducts[product.categoryId]!.add(product);
      }

      // Load category information
      final categories = <MenuCategory>[];
      for (final categoryId in groupedProducts.keys) {
        final categoryDoc = await _firestoreService.read('categories', categoryId);
        if (categoryDoc.exists) {
          final categoryData = categoryDoc.data() as Map<String, dynamic>;
          categories.add(MenuCategory(
            id: categoryId,
            name: categoryData['name'] ?? 'Categoria',
            description: categoryData['description'],
            imageUrl: categoryData['imageUrl'],
            order: categoryData['order'] ?? 0,
            products: groupedProducts[categoryId]!,
          ));
        }
      }

      // Sort categories by order
      categories.sort((a, b) => a.order.compareTo(b.order));
      return categories;
    } catch (e) {
      debugPrint('Error loading menu: $e');
      return [];
    }
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredRestaurants = _restaurants.where((restaurant) {
      // Category filter
      bool categoryMatch = _selectedCategory == 'Todos' || restaurant.category == _selectedCategory;
      
      // Search filter
      bool searchMatch = _searchQuery.isEmpty ||
          restaurant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          restaurant.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          restaurant.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));

      return categoryMatch && searchMatch;
    }).toList();

    // Sort by featured first, then by rating
    _filteredRestaurants.sort((a, b) {
      if (a.isFeatured && !b.isFeatured) return -1;
      if (!a.isFeatured && b.isFeatured) return 1;
      return b.rating.compareTo(a.rating);
    });
  }

  void _extractCategories() {
    final Set<String> categorySet = {'Todos'};
    for (final restaurant in _restaurants) {
      categorySet.add(restaurant.category);
    }
    _categories = categorySet.toList();
  }

  Restaurant _mapRestaurantFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Restaurant(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      deliveryFee: (data['deliveryFee'] ?? 0.0).toDouble(),
      deliveryTime: data['deliveryTime'] ?? 30,
      isOpen: data['isOpen'] ?? false,
      isFeatured: data['isFeatured'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
      address: _mapAddressFromFirestore(data['address'] ?? {}),
      workingHours: _mapWorkingHoursFromFirestore(data['workingHours'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Product _mapProductFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      categoryId: data['categoryId'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      options: (data['options'] as List<dynamic>?)
          ?.map((o) => _mapProductOptionFromFirestore(o as Map<String, dynamic>))
          .toList() ?? [],
      addons: (data['addons'] as List<dynamic>?)
          ?.map((a) => _mapProductAddonFromFirestore(a as Map<String, dynamic>))
          .toList() ?? [],
      preparationTime: data['preparationTime'] ?? 15,
      allergens: List<String>.from(data['allergens'] ?? []),
      discount: data['discount']?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  ProductOption _mapProductOptionFromFirestore(Map<String, dynamic> data) {
    return ProductOption(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      additionalPrice: (data['additionalPrice'] ?? 0.0).toDouble(),
      isRequired: data['isRequired'] ?? false,
      items: (data['items'] as List<dynamic>?)
          ?.map((i) => ProductOptionItem(
                id: i['id'] ?? '',
                name: i['name'] ?? '',
                additionalPrice: (i['additionalPrice'] ?? 0.0).toDouble(),
              ))
          .toList() ?? [],
    );
  }

  ProductAddon _mapProductAddonFromFirestore(Map<String, dynamic> data) {
    return ProductAddon(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      description: data['description'],
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  Address _mapAddressFromFirestore(Map<String, dynamic> data) {
    return Address(
      street: data['street'] ?? '',
      number: data['number'] ?? '',
      complement: data['complement'],
      neighborhood: data['neighborhood'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      zipCode: data['zipCode'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
    );
  }

  WorkingHours _mapWorkingHoursFromFirestore(Map<String, dynamic> data) {
    final schedule = <String, DaySchedule>{};
    
    data.forEach((day, scheduleData) {
      if (scheduleData is Map<String, dynamic>) {
        schedule[day] = DaySchedule(
          isOpen: scheduleData['isOpen'] ?? false,
          openTime: _parseTimeOfDay(scheduleData['openTime']),
          closeTime: _parseTimeOfDay(scheduleData['closeTime']),
        );
      }
    });

    return WorkingHours(schedule: schedule);
  }

  TimeOfDay _parseTimeOfDay(dynamic time) {
    if (time is String) {
      final parts = time.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    return TimeOfDay(hour: 9, minute: 0); // Default
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}

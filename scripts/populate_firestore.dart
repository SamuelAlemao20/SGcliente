import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:sg_sabores_cliente/firebase_options.dart';

// Script para popular dados iniciais no Firestore
// Execute com: dart run scripts/populate_firestore.dart

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  print('Populando dados iniciais...');

  // Categories
  await populateCategories(firestore);

  // Restaurants
  await populateRestaurants(firestore);

  // Products
  await populateProducts(firestore);

  // Coupons
  await populateCoupons(firestore);

  print('Dados populados com sucesso!');
}

Future<void> populateCategories(FirebaseFirestore firestore) async {
  final categories = [
    {
      'name': 'Pizzas',
      'description': 'Deliciosas pizzas artesanais',
      'imageUrl':
          'https://i.ytimg.com/vi/p6sYCzq9twY/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLDhs1VNbxQHaRHYYOrRTUHCsW3wGQ',
      'order': 1,
    },
    {
      'name': 'Hambúrgueres',
      'description': 'Hambúrgueres suculentos',
      'imageUrl':
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300',
      'order': 2,
    },
    {
      'name': 'Japonesa',
      'description': 'Sushi e pratos japoneses',
      'imageUrl':
          'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=300',
      'order': 3,
    },
    {
      'name': 'Brasileira',
      'description': 'Comida caseira brasileira',
      'imageUrl':
          'https://i.ytimg.com/vi/0wOyK8JYyZ8/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLBxumwXhgMXa0CtatzQ6HdHe_ySmg',
      'order': 4,
    },
  ];

  for (final category in categories) {
    await firestore.collection('categories').add({
      ...category,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  print('✅ Categorias criadas');
}

Future<void> populateRestaurants(FirebaseFirestore firestore) async {
  final restaurants = [
    {
      'name': 'Pizzaria Italiana',
      'description':
          'Autênticas pizzas italianas feitas com ingredientes importados',
      'imageUrl':
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500',
      'category': 'Pizzas',
      'rating': 4.5,
      'reviewCount': 150,
      'deliveryFee': 0.0,
      'deliveryTime': 35,
      'isOpen': true,
      'isFeatured': true,
      'tags': ['pizza', 'italiana', 'massa'],
      'address': {
        'street': 'Rua das Flores',
        'number': '123',
        'neighborhood': 'Centro',
        'city': 'São Paulo',
        'state': 'SP',
        'zipCode': '01234-567',
        'latitude': -23.5505,
        'longitude': -46.6333,
      },
      'workingHours': {
        'monday': {'isOpen': true, 'openTime': '18:00', 'closeTime': '23:00'},
        'tuesday': {'isOpen': true, 'openTime': '18:00', 'closeTime': '23:00'},
        'wednesday': {
          'isOpen': true,
          'openTime': '18:00',
          'closeTime': '23:00'
        },
        'thursday': {'isOpen': true, 'openTime': '18:00', 'closeTime': '23:00'},
        'friday': {'isOpen': true, 'openTime': '18:00', 'closeTime': '00:00'},
        'saturday': {'isOpen': true, 'openTime': '18:00', 'closeTime': '00:00'},
        'sunday': {'isOpen': true, 'openTime': '18:00', 'closeTime': '23:00'},
      },
    },
    {
      'name': 'Burger House',
      'description': 'Os melhores hambúrgueres artesanais da cidade',
      'imageUrl':
          'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=500',
      'category': 'Hambúrgueres',
      'rating': 4.7,
      'reviewCount': 89,
      'deliveryFee': 4.99,
      'deliveryTime': 25,
      'isOpen': true,
      'isFeatured': true,
      'tags': ['burger', 'artesanal', 'carne'],
      'address': {
        'street': 'Av. Paulista',
        'number': '456',
        'neighborhood': 'Bela Vista',
        'city': 'São Paulo',
        'state': 'SP',
        'zipCode': '01310-100',
        'latitude': -23.5618,
        'longitude': -46.6565,
      },
      'workingHours': {
        'monday': {'isOpen': true, 'openTime': '11:00', 'closeTime': '23:00'},
        'tuesday': {'isOpen': true, 'openTime': '11:00', 'closeTime': '23:00'},
        'wednesday': {
          'isOpen': true,
          'openTime': '11:00',
          'closeTime': '23:00'
        },
        'thursday': {'isOpen': true, 'openTime': '11:00', 'closeTime': '23:00'},
        'friday': {'isOpen': true, 'openTime': '11:00', 'closeTime': '00:00'},
        'saturday': {'isOpen': true, 'openTime': '11:00', 'closeTime': '00:00'},
        'sunday': {'isOpen': true, 'openTime': '11:00', 'closeTime': '23:00'},
      },
    },
    {
      'name': 'Sushi Zen',
      'description': 'Sushi fresco e pratos japoneses tradicionais',
      'imageUrl':
          'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=500',
      'category': 'Japonesa',
      'rating': 4.8,
      'reviewCount': 203,
      'deliveryFee': 6.99,
      'deliveryTime': 40,
      'isOpen': true,
      'isFeatured': false,
      'tags': ['sushi', 'japonesa', 'peixe'],
      'address': {
        'street': 'Rua da Liberdade',
        'number': '789',
        'neighborhood': 'Liberdade',
        'city': 'São Paulo',
        'state': 'SP',
        'zipCode': '01503-001',
        'latitude': -23.5589,
        'longitude': -46.6250,
      },
      'workingHours': {
        'monday': {'isOpen': false, 'openTime': '19:00', 'closeTime': '23:00'},
        'tuesday': {'isOpen': true, 'openTime': '19:00', 'closeTime': '23:00'},
        'wednesday': {
          'isOpen': true,
          'openTime': '19:00',
          'closeTime': '23:00'
        },
        'thursday': {'isOpen': true, 'openTime': '19:00', 'closeTime': '23:00'},
        'friday': {'isOpen': true, 'openTime': '19:00', 'closeTime': '00:00'},
        'saturday': {'isOpen': true, 'openTime': '19:00', 'closeTime': '00:00'},
        'sunday': {'isOpen': true, 'openTime': '19:00', 'closeTime': '23:00'},
      },
    },
  ];

  for (final restaurant in restaurants) {
    await firestore.collection('restaurants').add({
      ...restaurant,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  print('✅ Restaurantes criados');
}

Future<void> populateProducts(FirebaseFirestore firestore) async {
  // Get restaurant and category IDs
  final restaurantsQuery = await firestore.collection('restaurants').get();
  final categoriesQuery = await firestore.collection('categories').get();

  final pizzaCategory =
      categoriesQuery.docs.firstWhere((doc) => doc.data()['name'] == 'Pizzas');

  final pizzaRestaurant = restaurantsQuery.docs
      .firstWhere((doc) => doc.data()['name'] == 'Pizzaria Italiana');

  final products = [
    {
      'name': 'Pizza Margherita',
      'description': 'Molho de tomate, mussarela, manjericão fresco e azeite',
      'imageUrl':
          'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=400',
      'price': 35.90,
      'categoryId': pizzaCategory.id,
      'restaurantId': pizzaRestaurant.id,
      'isAvailable': true,
      'preparationTime': 25,
      'allergens': ['glúten', 'lactose'],
      'options': [
        {
          'id': 'size',
          'name': 'Tamanho',
          'isRequired': true,
          'additionalPrice': 0,
          'items': [
            {'id': 'small', 'name': 'Pequena (25cm)', 'additionalPrice': 0},
            {'id': 'medium', 'name': 'Média (30cm)', 'additionalPrice': 5.0},
            {'id': 'large', 'name': 'Grande (35cm)', 'additionalPrice': 10.0},
          ],
        },
        {
          'id': 'crust',
          'name': 'Borda',
          'isRequired': false,
          'additionalPrice': 0,
          'items': [
            {'id': 'thin', 'name': 'Fina', 'additionalPrice': 0},
            {'id': 'thick', 'name': 'Grossa', 'additionalPrice': 2.0},
            {'id': 'stuffed', 'name': 'Recheada', 'additionalPrice': 8.0},
          ],
        },
      ],
      'addons': [
        {
          'id': 'extra_cheese',
          'name': 'Queijo Extra',
          'price': 4.50,
          'description': 'Mussarela adicional',
          'isAvailable': true,
        },
        {
          'id': 'bacon',
          'name': 'Bacon',
          'price': 6.00,
          'description': 'Bacon crocante',
          'isAvailable': true,
        },
      ],
    },
    {
      'name': 'Pizza Pepperoni',
      'description': 'Molho de tomate, mussarela e pepperoni',
      'imageUrl':
          'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=400',
      'price': 42.90,
      'categoryId': pizzaCategory.id,
      'restaurantId': pizzaRestaurant.id,
      'isAvailable': true,
      'preparationTime': 25,
      'allergens': ['glúten', 'lactose'],
      'discount': 5.00,
      'options': [
        {
          'id': 'size',
          'name': 'Tamanho',
          'isRequired': true,
          'additionalPrice': 0,
          'items': [
            {'id': 'small', 'name': 'Pequena (25cm)', 'additionalPrice': 0},
            {'id': 'medium', 'name': 'Média (30cm)', 'additionalPrice': 5.0},
            {'id': 'large', 'name': 'Grande (35cm)', 'additionalPrice': 10.0},
          ],
        },
      ],
      'addons': [
        {
          'id': 'extra_cheese',
          'name': 'Queijo Extra',
          'price': 4.50,
          'description': 'Mussarela adicional',
          'isAvailable': true,
        },
      ],
    },
  ];

  for (final product in products) {
    await firestore.collection('products').add({
      ...product,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  print('✅ Produtos criados');
}

Future<void> populateCoupons(FirebaseFirestore firestore) async {
  final coupons = [
    {
      'code': 'WELCOME10',
      'discountType': 'percentage',
      'discountValue': 10.0,
      'minimumAmount': 25.0,
      'maxDiscountAmount': 15.0,
      'isActive': true,
      'expirationDate': DateTime.now().add(const Duration(days: 30)),
      'description': 'Desconto de 10% para novos usuários',
    },
    {
      'code': 'FRETE5',
      'discountType': 'fixed',
      'discountValue': 5.0,
      'minimumAmount': 30.0,
      'isActive': true,
      'expirationDate': DateTime.now().add(const Duration(days: 15)),
      'description': 'R\$ 5 de desconto na taxa de entrega',
    },
  ];

  for (final coupon in coupons) {
    await firestore.collection('coupons').add({
      ...coupon,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  print('✅ Cupons criados');
}

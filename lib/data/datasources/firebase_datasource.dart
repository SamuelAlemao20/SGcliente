
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/entities/order.dart';

class FirebaseDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User operations
  Future<User?> getUser(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        return _mapUserFromFirestore(doc.data()!, id);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar usuário: $e');
    }
  }

  Future<void> createUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(_userToMap(user));
    } catch (e) {
      throw Exception('Erro ao criar usuário: $e');
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(_userToMap(user));
    } catch (e) {
      throw Exception('Erro ao atualizar usuário: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection('users').doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar usuário: $e');
    }
  }

  Future<void> addUserAddress(String userId, Address address) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'addresses': FieldValue.arrayUnion([_addressToMap(address)]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao adicionar endereço: $e');
    }
  }

  Future<void> updateUserAddress(String userId, Address address) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final userData = doc.data()!;
        final addresses = List<Map<String, dynamic>>.from(userData['addresses'] ?? []);
        
        final index = addresses.indexWhere((addr) => addr['id'] == address.id);
        if (index >= 0) {
          addresses[index] = _addressToMap(address);
          
          await _firestore.collection('users').doc(userId).update({
            'addresses': addresses,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      throw Exception('Erro ao atualizar endereço: $e');
    }
  }

  Future<void> deleteUserAddress(String userId, String addressId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final userData = doc.data()!;
        final addresses = List<Map<String, dynamic>>.from(userData['addresses'] ?? []);
        
        addresses.removeWhere((addr) => addr['id'] == addressId);
        
        await _firestore.collection('users').doc(userId).update({
          'addresses': addresses,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Erro ao deletar endereço: $e');
    }
  }

  // Mapping methods
  User _mapUserFromFirestore(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      photoUrl: data['photoUrl'],
      addresses: (data['addresses'] as List<dynamic>?)
          ?.map((a) => _mapAddressFromFirestore(a as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Address _mapAddressFromFirestore(Map<String, dynamic> data) {
    return Address(
      id: data['id'] ?? '',
      label: data['label'] ?? '',
      street: data['street'] ?? '',
      number: data['number'] ?? '',
      complement: data['complement'],
      neighborhood: data['neighborhood'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      zipCode: data['zipCode'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> _userToMap(User user) {
    return {
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'photoUrl': user.photoUrl,
      'addresses': user.addresses.map(_addressToMap).toList(),
      'createdAt': Timestamp.fromDate(user.createdAt),
      'updatedAt': Timestamp.fromDate(user.updatedAt),
    };
  }

  Map<String, dynamic> _addressToMap(Address address) {
    return {
      'id': address.id,
      'label': address.label,
      'street': address.street,
      'number': address.number,
      'complement': address.complement,
      'neighborhood': address.neighborhood,
      'city': address.city,
      'state': address.state,
      'zipCode': address.zipCode,
      'latitude': address.latitude,
      'longitude': address.longitude,
      'isDefault': address.isDefault,
    };
  }
}

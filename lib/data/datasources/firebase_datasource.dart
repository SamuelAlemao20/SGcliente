import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sg_sabores_cliente/domain/entities/user.dart';
import 'package:sg_sabores_cliente/domain/entities/address.dart';

class FirebaseDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> getUser(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    if (doc.exists) {
      return _mapUserFromFirestore(doc.data()!, id);
    }
    return null;
  }

  Future<void> createUser(User user) async {
    await _firestore.collection('users').doc(user.id).set(_userToMap(user));
  }

  Map<String, dynamic> _userToMap(User user) {
    return {
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'photoUrl': user.photoUrl,
      'addresses': user.addresses.map(_addressToMap).toList(),
      'createdAt': user.createdAt,
      'updatedAt': user.updatedAt,
    };
  }

  User _mapUserFromFirestore(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      photoUrl: data['photoUrl'],
      addresses: (data['addresses'] as List<dynamic>?)
              ?.map((a) => _mapAddressFromFirestore(a as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
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
      'isDefault': address.isDefault,
    };
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
      isDefault: data['isDefault'] ?? false,
    );
  }
}

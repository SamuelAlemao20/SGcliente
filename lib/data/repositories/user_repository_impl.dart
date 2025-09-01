import 'package:sg_sabores_cliente/domain/entities/user.dart';
import 'package:sg_sabores_cliente/domain/entities/address.dart';
import 'package:sg_sabores_cliente/domain/repositories/user_repository.dart';
import 'package:sg_sabores_cliente/data/datasources/firebase_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._dataSource);
  final FirebaseDataSource _dataSource;

  @override
  Future<User?> getUserById(String id) => _dataSource.getUser(id);

  @override
  Future<void> createUser(User user) => _dataSource.createUser(user);

  // Implemente os outros métodos se necessário
  @override
  Future<void> addAddress(String userId, Address address) async {}
  @override
  Future<void> deleteAddress(String userId, String addressId) async {}
  @override
  Future<void> deleteUser(String id) async {}
  @override
  Future<void> updateAddress(String userId, Address address) async {}
  @override
  Future<void> updateUser(User user) async {}
}

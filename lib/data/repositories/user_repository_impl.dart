
import '../../domain/repositories/user_repository.dart';
import '../../domain/entities/user.dart';
import '../datasources/firebase_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseDataSource _dataSource;

  UserRepositoryImpl(this._dataSource);

  @override
  Future<User?> getUserById(String id) async {
    return await _dataSource.getUser(id);
  }

  @override
  Future<void> updateUser(User user) async {
    await _dataSource.updateUser(user);
  }

  @override
  Future<void> createUser(User user) async {
    await _dataSource.createUser(user);
  }

  @override
  Future<void> deleteUser(String id) async {
    await _dataSource.deleteUser(id);
  }

  @override
  Future<void> addAddress(String userId, Address address) async {
    await _dataSource.addUserAddress(userId, address);
  }

  @override
  Future<void> updateAddress(String userId, Address address) async {
    await _dataSource.updateUserAddress(userId, address);
  }

  @override
  Future<void> deleteAddress(String userId, String addressId) async {
    await _dataSource.deleteUserAddress(userId, addressId);
  }
}

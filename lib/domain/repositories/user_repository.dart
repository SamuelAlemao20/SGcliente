
import '../entities/user.dart';

abstract class UserRepository {
  Future<User?> getUserById(String id);
  Future<void> updateUser(User user);
  Future<void> createUser(User user);
  Future<void> deleteUser(String id);
  Future<void> addAddress(String userId, Address address);
  Future<void> updateAddress(String userId, Address address);
  Future<void> deleteAddress(String userId, String addressId);
}

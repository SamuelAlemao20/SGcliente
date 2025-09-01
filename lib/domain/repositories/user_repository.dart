import '../entities/user.dart';
import '../entities/address.dart';

/// Define o contrato para todas as operações relacionadas ao usuário.
/// A UI (através dos Providers) interage com esta interface,
/// sem saber os detalhes da implementação (Firebase, etc.).
abstract class UserRepository {
  Future<User?> getUserById(String id);
  Future<void> createUser(User user);
  Future<void> updateUser(User user);
  Future<void> deleteUser(String id);
  Future<void> addAddress(String userId, Address address);
  Future<void> updateAddress(String userId, Address address);
  Future<void> deleteAddress(String userId, String addressId);
}

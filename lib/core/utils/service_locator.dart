import 'package:get_it/get_it.dart';
import 'package:sg_sabores_cliente/data/datasources/firebase_datasource.dart';
import 'package:sg_sabores_cliente/data/repositories/user_repository_impl.dart';
import 'package:sg_sabores_cliente/domain/repositories/user_repository.dart';
import 'package:sg_sabores_cliente/presentation/providers/auth_provider.dart';
import 'package:sg_sabores_cliente/presentation/providers/cart_provider.dart';
import 'package:sg_sabores_cliente/presentation/providers/order_provider.dart';
import 'package:sg_sabores_cliente/presentation/providers/restaurant_provider.dart';
import 'package:sg_sabores_cliente/services/auth_service.dart';
import 'package:sg_sabores_cliente/services/firestore_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton(() => AuthService());
  getIt.registerLazySingleton(() => FirestoreService());
  getIt.registerLazySingleton(() => FirebaseDataSource());
  getIt
      .registerLazySingleton<UserRepository>(() => UserRepositoryImpl(getIt()));
  getIt.registerFactory(() => AuthProvider());
  getIt.registerFactory(() => RestaurantProvider());
  getIt.registerFactory(() => OrderProvider());
  getIt.registerFactory(() => CartProvider());
}

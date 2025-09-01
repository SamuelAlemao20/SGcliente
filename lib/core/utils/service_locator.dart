
import 'package:get_it/get_it.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/notification_service.dart';
import '../../services/payment_service.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/restaurant_repository_impl.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/datasources/firebase_datasource.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../../domain/repositories/order_repository.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Services
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<FirestoreService>(() => FirestoreService());
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<PaymentService>(() => PaymentService());

  // Data Sources
  getIt.registerLazySingleton<FirebaseDataSource>(() => FirebaseDataSource());

  // Repositories
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt<FirebaseDataSource>()),
  );
  getIt.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(getIt<FirebaseDataSource>()),
  );
  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(getIt<FirebaseDataSource>()),
  );
}

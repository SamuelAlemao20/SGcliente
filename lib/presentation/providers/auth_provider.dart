import 'package:flutter/foundation.dart';
import 'package.firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sg_sabores_cliente/domain/entities/address.dart';
import 'package:sg_sabores_cliente/domain/entities/user.dart' as app_user;
import 'package:sg_sabores_cliente/services/auth_service.dart';
import 'package:sg_sabores_cliente/services/firestore_service.dart';
import 'package:sg_sabores_cliente/core/utils/service_locator.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = getIt<AuthService>();
  final FirestoreService _firestoreService = getIt<FirestoreService>();

  User? _currentUser;
  app_user.User? _userProfile;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  app_user.User? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _authService.authStateChanges.listen((user) {
      _currentUser = user;
      if (user != null) {
        _loadUserProfile(user.uid);
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile(String userId) async {
    final doc = await _firestoreService.read('users', userId);
    if (doc.exists) {
      _userProfile =
          _mapUserFromFirestore(doc.data()! as Map<String, dynamic>, userId);
      notifyListeners();
    }
  }

  Future<bool> signInWithEmailPassword(
      {required String email, required String password}) async {
    // Lógica de login
    return true;
  }

  Future<bool> signInWithGoogle() async {
    // Lógica de login com Google
    return true;
  }

  Future<bool> signUpWithEmailPassword(
      {required String email,
      required String password,
      required String name}) async {
    // Lógica de cadastro
    return true;
  }

  Future<void> signOut() async {
    // Lógica de logout
  }

  app_user.User _mapUserFromFirestore(Map<String, dynamic> data, String id) {
    return app_user.User(
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
}

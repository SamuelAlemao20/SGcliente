import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../core/utils/service_locator.dart';
import '../../domain/entities/user.dart' as app_user;

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
    _authService.authStateChanges.listen((User? user) {
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
    try {
      final doc = await _firestoreService.read('users', userId);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _userProfile = _mapUserFromFirestore(data, userId);
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<bool> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final credential = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
        name: name,
      );

      if (credential?.user != null) {
        // Create user profile in Firestore
        await _createUserProfile(
          userId: credential!.user!.uid,
          name: name,
          email: email,
          phone: phone,
        );
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final credential = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      return credential?.user != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      final credential = await _authService.signInWithGoogle();

      if (credential?.user != null) {
        final user = credential!.user!;

        // Check if user profile exists, if not create it
        final doc = await _firestoreService.read('users', user.uid);
        if (!doc.exists) {
          await _createUserProfile(
            userId: user.uid,
            name: user.displayName ?? 'Usuário',
            email: user.email!,
            photoUrl: user.photoURL,
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.resetPassword(email);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _userProfile = null;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (_currentUser != null && _userProfile != null) {
        final updates = <String, dynamic>{};

        if (name != null) updates['name'] = name;
        if (phone != null) updates['phone'] = phone;
        if (photoUrl != null) updates['photoUrl'] = photoUrl;

        await _firestoreService.update('users', _currentUser!.uid, updates);

        // Update Firebase Auth profile
        if (name != null || photoUrl != null) {
          await _authService.updateProfile(
            displayName: name,
            photoURL: photoUrl,
          );
        }

        // Reload user profile
        await _loadUserProfile(_currentUser!.uid);
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addAddress(app_user.Address address) async {
    try {
      if (_currentUser != null && _userProfile != null) {
        final addresses = List<app_user.Address>.from(_userProfile!.addresses);

        // If this is the first address or marked as default, make it default
        if (addresses.isEmpty || address.isDefault) {
          // Remove default from other addresses
          addresses.forEach((addr) => addr.copyWith(isDefault: false));
        }

        addresses.add(address);

        await _firestoreService.update('users', _currentUser!.uid, {
          'addresses': addresses.map((a) => _addressToMap(a)).toList(),
        });

        await _loadUserProfile(_currentUser!.uid);
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> _createUserProfile({
    required String userId,
    required String name,
    required String email,
    String? phone,
    String? photoUrl,
  }) async {
    final userData = {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'addresses': [],
    };

    await _firestoreService.createWithId('users', userId, userData);
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
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  app_user.Address _mapAddressFromFirestore(Map<String, dynamic> data) {
    return app_user.Address(
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

  Map<String, dynamic> _addressToMap(app_user.Address address) {
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

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}

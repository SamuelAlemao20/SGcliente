import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// AuthService lida diretamente com o Firebase Authentication.
/// Suas responsabilidades são criar usuário, fazer login, logout, etc.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Retorna o usuário atualmente logado no Firebase.
  User? get currentUser => _auth.currentUser;

  /// Stream que notifica sobre mudanças no estado de autenticação (login/logout).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Cria um novo usuário com e-mail e senha.
  Future<UserCredential?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Atualiza o nome de exibição do usuário no Firebase.
      await credential.user?.updateDisplayName(name);
      return credential;
    } on FirebaseAuthException catch (e) {
      // Converte o erro do Firebase em uma mensagem legível.
      throw _handleAuthException(e);
    }
  }

  /// Autentica um usuário existente com e-mail e senha.
  Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Autentica um usuário usando a conta do Google.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // O fluxo de login com Google é diferente para Web e Mobile.
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(googleProvider);
      } else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      throw Exception('Erro ao fazer login com Google: $e');
    }
  }

  /// Desconecta o usuário do aplicativo.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  /// Converte os códigos de erro do FirebaseAuth em mensagens amigáveis.
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'A senha é muito fraca.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'user-not-found':
        return 'Usuário não encontrado com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta. Tente novamente.';
      case 'invalid-email':
        return 'O formato do e-mail é inválido.';
      default:
        return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }
}

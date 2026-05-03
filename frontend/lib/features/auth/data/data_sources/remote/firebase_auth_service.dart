import 'package:firebase_auth/firebase_auth.dart';

/// Abstract data source for Firebase Authentication operations.
///
/// Only this file (and its impl) imports `firebase_auth` (AV 1.2.3).
/// Throws [AuthException] on failure — never leaks [FirebaseAuthException].
abstract class FirebaseAuthService {
  /// Signs the user in anonymously.
  Future<User> signInAnonymously();

  /// Signs in with email and password.
  Future<User> signInWithEmail(String email, String password);

  /// Creates a new account with email and password.
  Future<User> signUpWithEmail(String email, String password);

  /// Signs in with an OAuth credential (e.g. Google).
  Future<User> signInWithCredential(AuthCredential credential);

  /// Signs out the current user.
  Future<void> signOut();

  /// Sends a password-reset email.
  Future<void> sendPasswordResetEmail(String email);

  /// Returns the currently signed-in [User] or null.
  User? get currentUser;

  /// Continuous stream of auth state changes.
  Stream<User?> authStateChanges();
}

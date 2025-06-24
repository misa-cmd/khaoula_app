import 'package:flutter/material.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/services/firebase_service.dart';

class AuthController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage; // Store error message for UI feedback

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Sign-up method
  Future<bool> signUp(String nom, String email, String password) async {
    _isLoading = true;
    _errorMessage = null; // Reset error message
    notifyListeners();

    try {
      // Check if email already exists
      bool emailExists = await _firebaseService.emailExists(email);
      if (emailExists) {
        _isLoading = false;
        _errorMessage = 'Cette adresse email est déjà utilisée';
        notifyListeners();
        return false;
      }

      // Proceed with sign-up
      _currentUser = await _firebaseService.signUp(nom, email, password);

      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _parseSignUpError(e); // Parse specific error
      notifyListeners();
      return false;
    }
  }

  // Sign-in method
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null; // Reset error message
    notifyListeners();

    try {
      _currentUser = await _firebaseService.signIn(email, password);

      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _parseSignInError(e); // Parse specific error
      notifyListeners();
      return false;
    }
  }

  // Sign-out method
  Future<void> signOut() async {
    await _firebaseService.signOut();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Parse sign-up errors
  String _parseSignUpError(dynamic error) {
    if (error.toString().contains('email-already-in-use')) {
      return 'Cette adresse email est déjà utilisée';
    } else if (error.toString().contains('invalid-email')) {
      return 'L\'adresse email est invalide';
    } else if (error.toString().contains('weak-password')) {
      return 'Le mot de passe est trop faible';
    } else {
      return 'Une erreur est survenue lors de l\'inscription';
    }
  }

  // Parse sign-in errors
  String _parseSignInError(dynamic error) {
    if (error.toString().contains('user-not-found') ||
        error.toString().contains('wrong-password')) {
      return 'Email ou mot de passe incorrect';
    } else if (error.toString().contains('invalid-email')) {
      return 'L\'adresse email est invalide';
    } else {
      return 'Une erreur est survenue lors de la connexion';
    }
  }
}

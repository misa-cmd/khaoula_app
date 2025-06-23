import 'package:flutter/material.dart'; // Import des outils Flutter, y compris pour ChangeNotifier.
import 'package:myapp/models/user_model.dart'; // Import du modèle utilisateur.
import 'package:myapp/services/firebase_service.dart'; // Import du service Firebase contenant les méthodes d'authentification.

// Contrôleur pour gérer l'authentification des utilisateurs (inscription, connexion, déconnexion).
class AuthController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService(); // Instance du service Firebase pour accéder aux méthodes d'authentification.
  UserModel? _currentUser; // Utilisateur actuellement connecté (null si aucun).
  bool _isLoading = false; // Indique si une opération est en cours (utile pour afficher un loader).

  // Getter pour accéder à l'utilisateur actuel depuis l'extérieur.
  UserModel? get currentUser => _currentUser;

  // Getter pour savoir si une opération (connexion/inscription) est en cours.
  bool get isLoading => _isLoading;

  // Méthode pour inscrire un nouvel utilisateur avec son nom, email et mot de passe.
  Future<bool> signUp(String nom, String email, String password) async {
    _isLoading = true; // Active le chargement.
    notifyListeners(); // Notifie les widgets écoutant ce contrôleur.

    try {
      // Appelle le service Firebase pour s'inscrire et récupère l'utilisateur si succès.
      _currentUser = await _firebaseService.signUp(nom, email, password);

      _isLoading = false; // Désactive le chargement.
      notifyListeners(); // Notifie les widgets du changement.

      // Retourne true si l'inscription a réussi (utilisateur non nul), sinon false.
      return _currentUser != null;
    } catch (e) {
      // En cas d'erreur (ex. : compte déjà existant), désactive le chargement et retourne false.
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Méthode pour connecter un utilisateur avec email et mot de passe.
  Future<bool> signIn(String email, String password) async {
    _isLoading = true; // Active l’indicateur de chargement.
    notifyListeners(); // Met à jour l’interface (ex. : affichage d’un spinner).

    try {
      // Appelle le service Firebase pour se connecter et stocke l'utilisateur si succès.
      _currentUser = await _firebaseService.signIn(email, password);

      _isLoading = false; // Désactive le chargement.
      notifyListeners(); // Rafraîchit l'interface.

      // Retourne true si connexion réussie (utilisateur récupéré), sinon false.
      return _currentUser != null;
    } catch (e) {
      // En cas d'erreur (email/mot de passe invalide, etc.).
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Méthode pour déconnecter l'utilisateur actuellement connecté.
  Future<void> signOut() async {
    await _firebaseService.signOut(); // Déconnecte l'utilisateur via Firebase.
    _currentUser = null; // Supprime l’utilisateur courant du contrôleur.
    notifyListeners(); // Met à jour les interfaces pour refléter la déconnexion.
  }
}

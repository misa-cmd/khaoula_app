import 'package:flutter/material.dart';
import 'package:myapp/controllers/auth_controller.dart';
import 'package:myapp/services/firebase_service.dart'; // Import FirebaseService

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final AuthController _authController = AuthController();
  final FirebaseService _firebaseService =
      FirebaseService(); // Initialize FirebaseService
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3F5044),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_add,
                    size: 80,
                    color: Color(0xFF3F5044),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Inscription',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F5044),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _nomController,
                    decoration: InputDecoration(
                      labelText: 'Nom complet (Nom Prénom)',
                      prefixIcon: const Icon(Icons.person, color: Color(0xFF3F5044)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF3F5044)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Adresse email',
                      prefixIcon: const Icon(Icons.email, color: Color(0xFF3F5044)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF3F5044)),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF3F5044)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF3F5044)),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  AnimatedBuilder(
                    animation: _authController,
                    builder: (context, child) {
                      return ElevatedButton(
                        onPressed: _authController.isLoading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F5044),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _authController.isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  'S\'inscrire',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    // Validate all fields
    if (_nomController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Veuillez remplir tous les champs');
      return;
    }

    // Validate "Nom Prénom" format (must contain a space)
    final name = _nomController.text.trim();
    if (!name.contains(' ') ||
        name.split(' ').length != 2 ||
        name.split(' ').any((part) => part.isEmpty)) {
      _showError(
        'Le nom complet doit être au format "Nom Prénom" avec un espace entre les deux',
      );
      return;
    }

    // Validate email format
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showError('Veuillez entrer une adresse email valide');
      return;
    }

    // Validate password length
    if (_passwordController.text.length < 6) {
      _showError('Le mot de passe doit contenir au moins 6 caractères');
      return;
    }

    // Check if email already exists
    final emailExists = await _firebaseService.emailExists(email);
    if (emailExists) {
      _showError('Cette adresse email est déjà utilisée');
      return;
    }

    // Proceed with sign-up
    bool success = await _authController.signUp(
      name,
      email,
      _passwordController.text,
    );

    if (success) {
      _showSuccess('Compte créé avec succès !');
      Navigator.pop(context);
    } else {
      _showError('Erreur lors de la création du compte');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}

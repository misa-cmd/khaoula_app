import 'package:flutter/material.dart';
import 'package:myapp/controllers/auth_controller.dart';
import 'package:myapp/views/employee_dashboard_view.dart';
import 'package:myapp/views/admin_dashboard_view.dart';
import 'package:myapp/views/register_view.dart';
import 'package:intl/intl.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  _AuthViewState createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final AuthController _authController = AuthController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3F5044),
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
                  const Icon(Icons.login, size: 80, color: Color(0xFF3F5044)),
                  const SizedBox(height: 24),
                  const Text(
                    'Connexion',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F5044),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Adresse email',
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Color(0xFF3F5044),
                      ),
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
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Color(0xFF3F5044),
                      ),
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
                        onPressed: _authController.isLoading ? null : _signIn,
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
                                  'Connexion',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterView(),
                        ),
                      );
                    },
                    child: const Text(
                      'Pas de compte ? Inscrivez-vous',
                      style: TextStyle(color: Color(0xFF3F5044), fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Veuillez remplir tous les champs');
      return;
    }

    try {
      bool success = await _authController.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && _authController.currentUser != null) {
        // Show success pop-up
        await showDialog(
          context: context,
          barrierDismissible: false, // Prevent dismissing by tapping outside
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Bonjour ${_authController.currentUser!.nom}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F5044),
                  ),
                ),

                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      // Navigate to appropriate dashboard
                      if (_authController.currentUser!.isAdmin) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminDashboardView(),
                          ),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmployeeDashboardView(),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Continuer',
                      style: TextStyle(color: Color(0xFF3F5044), fontSize: 16),
                    ),
                  ),
                ],
              ),
        );
      } else {
        _showError('Email ou mot de passe incorrect');
      }
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      _showError('Une erreur est survenue lors de la connexion');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

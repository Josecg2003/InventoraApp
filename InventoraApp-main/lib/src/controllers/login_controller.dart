import 'package:flutter/material.dart';
import '../models/login_model.dart';
import '../views/home.dart';

class AuthController {
  final BuildContext context;

  AuthController(this.context);

  // Método principal para manejar el login
  Future<bool> login(String email, String password) async {
    final user = User(email: email, password: password);

    // Validaciones básicas
    if (!user.areFieldsComplete()) {
      _showSnackBar('Por favor completa todos los campos', Colors.red);
      return false;
    }

    if (!user.isValidEmail()) {
      _showSnackBar('Por favor ingresa un email válido', Colors.red);
      return false;
    }

    if (!user.isValidPassword()) {
      _showSnackBar('La contraseña debe tener al menos 6 caracteres', Colors.red);
      return false;
    }

    try {
      // Autenticación real
      final bool isAuthenticated = await user.authenticate();
      
      if (isAuthenticated) {
        _showSnackBar('Login exitoso', Colors.green);
        _navigateToHome();
        return true;
      } else {
        _showSnackBar('Credenciales incorrectas', Colors.red);
        return false;
      }
    } catch (e) {
      _showSnackBar('Error en el login: $e', Colors.red);
      return false;
    }
  }

  // Método para recuperación de contraseña
  Future<void> recoverPassword(String email) async {
    final user = User(email: email, password: "");

    if (email.isEmpty) {
      _showSnackBar('Por favor ingresa tu email', Colors.red);
      return;
    }

    if (!user.isValidEmail()) {
      _showSnackBar('Por favor ingresa un email válido', Colors.red);
      return;
    }

    try {
      // Simular envío de email de recuperación
      await _performPasswordRecovery(email);
    } catch (e) {
      _showSnackBar('Error al enviar las instrucciones: $e', Colors.red);
    }
  }

  // Método privado para realizar la recuperación
  Future<void> _performPasswordRecovery(String email) async {
    _showSnackBar('Enviando instrucciones...', Colors.blue);
    
    // Simular delay de red
    await Future.delayed(const Duration(seconds: 2));

    _showSnackBar(
      'Se han enviado las instrucciones de recuperación a $email',
      Colors.green
    );
  }

  // Método para mostrar mensajes al usuario
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Método para navegar al home
  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
}
// lib/src/controllers/login_controller.dart
import 'package:flutter/material.dart';
import 'package:inventora_app/services/auth_service.dart';
import 'package:inventora_app/src/models/login_model.dart'; // Ajusta la ruta

class LoginController extends ChangeNotifier {
  
  // Dependencia del servicio
  final AuthService _authService = AuthService();

  // ----- ESTADO -----
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser; // Para guardar el usuario logueado

  // ----- GETTERS (Para que la Vista lea el estado) -----
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;

  // ----- LÓGICA DE NEGOCIO -----
  
  Future<bool> login(String email, String password) async {
    // 1. Poner estado de "cargando"
    _isLoading = true;
    _errorMessage = null; // Limpiar errores previos
    notifyListeners(); // Notifica a la Vista que hubo un cambio

    // 2. Llamar al servicio
    final result = await _authService.loginUser(email, password);

    bool loginSuccess = false;

    // 3. Actualizar el estado basado en el resultado
    if (result['success']) {
      _currentUser = result['user'];
      _errorMessage = null;
      loginSuccess = true;
    } else {
      _currentUser = null;
      _errorMessage = result['message'];
      loginSuccess = false;
    }

    // 4. Quitar estado de "cargando"
    _isLoading = false;
    notifyListeners(); // Notifica a la Vista que terminó

    return loginSuccess;
  }
}
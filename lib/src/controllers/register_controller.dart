// lib/src/controllers/register_controller.dart
import 'package:flutter/material.dart';
import 'package:inventora_app/services/auth_service.dart'; // Ajusta la ruta

class RegisterController extends ChangeNotifier {
  
  final AuthService _authService = AuthService();

  // ----- ESTADO -----
  bool _isLoading = false;
  String? _errorMessage;

  // ----- GETTERS -----
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ----- LÓGICA DE REGISTRO -----
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.registerUser(name, email, password);

    bool registerSuccess = false;

    if (result['success']) {
      _errorMessage = null;
      registerSuccess = true;
    } else {
      _errorMessage = result['message'];
      registerSuccess = false;
    }

    _isLoading = false;
    notifyListeners();

    return registerSuccess;
  }
}
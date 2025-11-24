// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventora_app/src/models/login_model.dart'; // Ajusta la ruta si es necesario

class AuthService {

  // IP para Emulador Android. Cambia a 'localhost' para iOS.
  final String _baseUrl = 'http://localhost:3000/api'; 
  // final String _baseUrl = 'http://192.168.18.39:3000/api';
  
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    
    final url = Uri.parse('$_baseUrl/login');
    
    try {
      final response = await http.post(
        url,
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Éxito. Decodificamos el usuario
        final user = User.fromJson(responseData['user']);
        return {'success': true, 'user': user};
      } else {
        // Error (ej: 401 Credenciales incorrectas)
        return {'success': false, 'message': responseData['message'] ?? 'Credenciales incorrectas'};
      }
      
    } catch (e) {
      // Error de conexión
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
  Future<Map<String, dynamic>> registerUser(String name, String email, String password) async {
    
    // Apunta al nuevo endpoint
    final url = Uri.parse('$_baseUrl/register'); 
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'name': name,       // Coincide con el req.body.name
          'email': email,     // Coincide con el req.body.email
          'password': password  // Coincide con el req.body.password
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      // El backend devuelve 201 (Created) en éxito
      if (response.statusCode == 201) {
        return {'success': true, 'message': responseData['message']};
      } else {
        // Error del servidor (ej: 400 email ya existe)
        return {'success': false, 'message': responseData['message'] ?? 'Error desconocido'};
      }
      
    } catch (e) {
      // Error de conexión
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
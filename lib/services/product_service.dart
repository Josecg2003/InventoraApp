// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventora_app/src/models/stats_model.dart';
import 'package:inventora_app/src/models/product_model.dart'; // Ajusta la ruta

class ProductService {
  // Misma URL base que tu auth_service
  //final String _baseUrl = 'http://localhost:3000/api';
  final String _baseUrl = 'http://192.168.18.39:3000/api'; 

  // ----- FUNCIÓN PARA OBTENER PRODUCTOS -----
  Future<List<Product>> getProducts() async {
    
    final url = Uri.parse('$_baseUrl/products');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Éxito. Decodificamos la lista de productos
        final List<Product> products = productFromJson(response.body);
        return products;
      } else {
        // Error del servidor
        throw Exception('Error al cargar productos');
      }
      
    } catch (e) {
      // Error de conexión
      print(e.toString()); // Es bueno ver el error en consola
      throw Exception('Error de conexión: $e');
    }
  }
  Future<List<CategoryDistribution>> getCategoriesDistribution() async {
    final url = Uri.parse('$_baseUrl/stats/categories-distribution');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return categoryDistributionFromJson(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // ----- FUNCIÓN PARA CREAR PRODUCTO -----
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> productData) async {
    final url = Uri.parse('$_baseUrl/products');
    try {
      final response = await http.post(
        url,
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: json.encode(productData), // Enviamos el mapa de datos
      );
      
      if (response.statusCode == 201) {
        return { 'success': true };
      } else {
        final errorData = json.decode(response.body);
        return { 'success': false, 'message': errorData['error'] ?? 'Error desconocido' };
      }
    } catch (e) {
      return { 'success': false, 'message': e.toString() };
    }
  }
  // ... (después de tus otros métodos)

  // ----- FUNCIÓN PARA REGISTRAR UNA VENTA -----
  Future<Map<String, dynamic>> registerSale(int productId, int quantity) async {
    final url = Uri.parse('$_baseUrl/salidas');
    try {
      final response = await http.post(
        url,
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: json.encode({
          'id_producto': productId,
          'cantidad': quantity,
        }),
      );
      
      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return { 'success': true, 'message': data['message'] };
      } else {
        return { 'success': false, 'message': data['error'] ?? 'Error desconocido' };
      }
    } catch (e) {
      return { 'success': false, 'message': e.toString() };
    }
  }
  Future<double> getSales(String period) async {
    // Apuntamos a la nueva ruta y pasamos el período como query param
    final url = Uri.parse('$_baseUrl/stats/sales?periodo=$period');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Leemos la nueva variable 'totalVentas'
        final String totalVentasString = data['totalVentas'].toString();
        return double.tryParse(totalVentasString) ?? 0.0;
      } else {
        return 0.0;
      }
    } catch (e) {
      return 0.0;
    }
  }

  // ----- FUNCIÓN PARA ACTUALIZAR PRODUCTO -----
  Future<Map<String, dynamic>> updateProduct(int id, Map<String, dynamic> productData) async {
    final url = Uri.parse('$_baseUrl/products/$id'); // Apuntamos al ID
    try {
      final response = await http.put(
        url,
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: json.encode(productData), // Enviamos los datos
      );
      
      if (response.statusCode == 200) {
        return { 'success': true };
      } else {
        final errorData = json.decode(response.body);
        return { 'success': false, 'message': errorData['error'] ?? 'Error desconocido' };
      }
    } catch (e) {
      return { 'success': false, 'message': e.toString() };
    }
  }

  // ----- FUNCIÓN PARA ELIMINAR PRODUCTO -----
  Future<Map<String, dynamic>> deleteProduct(int id) async {
    final url = Uri.parse('$_baseUrl/products/$id'); // Apuntamos al ID
    try {
      final response = await http.delete(url);
      
      if (response.statusCode == 200) {
        return { 'success': true };
      } else {
        final errorData = json.decode(response.body);
        return { 'success': false, 'message': errorData['error'] ?? 'Error desconocido' };
      }
    } catch (e) {
      return { 'success': false, 'message': e.toString() };
    }
  }
  Future<List<String>> getCategories() async {
    final url = Uri.parse('$_baseUrl/categories');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Decodificamos la respuesta JSON (una lista de strings)
        List<dynamic> data = json.decode(response.body);
        return List<String>.from(data);
      } else {
        return []; // Devuelve lista vacía en error
      }
    } catch (e) {
      return []; // Devuelve lista vacía en error
    }
  }
  Future<double> getWeeklyRotation() async {
    final url = Uri.parse('$_baseUrl/stats/rotation');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Leemos 'rotationPercentage' que devuelve el backend
        return (data['rotationPercentage'] as num).toDouble();
      } else {
        return 0.0;
      }
    } catch (e) {
      return 0.0;
    }
  }

  // ----- FUNCIÓN PARA OBTENER PROVEEDORES -----
  Future<List<String>> getProviders() async {
    final url = Uri.parse('$_baseUrl/providers');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Decodificamos la respuesta JSON (una lista de strings)
        List<dynamic> data = json.decode(response.body);
        return List<String>.from(data);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
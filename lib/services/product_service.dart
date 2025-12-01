// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventora_app/src/models/stats_model.dart';
import 'package:inventora_app/src/models/product_model.dart'; // Ajusta la ruta

class ProductService {
  // Misma URL base que tu auth_service
  // final String _baseUrl = 'http://localhost:3000/api';
  //final String _baseUrl = 'https://inventoraapp.onrender.com/api';
  //final String _baseUrl = 'http://192.168.18.42:3000/api';
  final String _baseUrl = 'https://inventoraapp.onrender.com/api';

  final String _pythonUrl = "https://inventoraapp-1.onrender.com";
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
  Future<Map<String, dynamic>> createProduct(
    Map<String, dynamic> productData,
  ) async {
    final url = Uri.parse('$_baseUrl/products');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(productData), // Enviamos el mapa de datos
      );

      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['error'] ?? 'Error desconocido',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
  // ... (después de tus otros métodos)

  // ----- FUNCIÓN PARA REGISTRAR UNA VENTA -----
  Future<Map<String, dynamic>> registerSale(int productId, int quantity) async {
    final url = Uri.parse('$_baseUrl/salidas');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'id_producto': productId, 'cantidad': quantity}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Error desconocido',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
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
  Future<Map<String, dynamic>> updateProduct(
    int id,
    Map<String, dynamic> productData,
  ) async {
    final url = Uri.parse('$_baseUrl/products/$id'); // Apuntamos al ID
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(productData), // Enviamos los datos
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['error'] ?? 'Error desconocido',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ----- OBTENER HISTORIAL DE VENTAS -----
  Future<List<Map<String, dynamic>>> getSalesHistory() async {
    final url = Uri.parse('$_baseUrl/stats/history');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // ----- FUNCIÓN PARA ELIMINAR PRODUCTO -----
  Future<Map<String, dynamic>> deleteProduct(int id) async {
    final url = Uri.parse('$_baseUrl/products/$id'); // Apuntamos al ID
    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['error'] ?? 'Error desconocido',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
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
  // ... dentro de ProductService ...

  // ✅ NUEVO: Obtener listas para el formulario (Productos, Categorías, Temporadas)
  Future<Map<String, dynamic>> getPredictionSingle(
    Map<String, dynamic> inputData,
  ) async {
    final url = Uri.parse('$_pythonUrl/predict'); // Endpoint simple
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(inputData),
      );

      if (response.statusCode == 200) {
        return json.decode(
          response.body,
        ); // Devuelve { "Prediccion_Demanda": 150, ... }
      } else {
        print('Error Python Single: ${response.body}');
        return {};
      }
    } catch (e) {
      print('Error conexión Python Single: $e');
      return {};
    }
  }

  // 1. ✅ Obtener Serie de Predicción (Gráfico)
  Future<List<Map<String, dynamic>>> getPredictionSerie(
    Map<String, dynamic> inputData,
  ) async {
    final url = Uri.parse('$_pythonUrl/predict/serie');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(inputData),
      );

      if (response.statusCode == 200) {
        // Python devuelve una lista: [{"fecha": "...", "prediccion": 123}, ...]
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('Error Python Serie: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error conexión Python Serie: $e');
      return [];
    }
  }

  // 2. ✅ Obtener Predicción Única + Compra (Tarjetas de datos)

  Future<Map<String, List<String>>> getPredictionOptions() async {
    final url = Uri.parse('$_pythonUrl/productos'); // Usa la URL de Python
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          "productos": List<String>.from(data["productos"] ?? []),
          "categorias": List<String>.from(data["categorias"] ?? []),
          "temporadas": List<String>.from(data["temporadas"] ?? []),
        };
      }
      return {};
    } catch (e) {
      print("Error obteniendo opciones: $e");
      return {};
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

import 'dart:convert';
import 'package:http/http.dart' as http;

class ModeloIAService {
  // ======================================================
  // 🔗 URL DE TU API (Flask)
  // Para Windows / Web: SIEMPRE usar 127.0.0.1
  // ======================================================
  final String baseUrl = "http://127.0.0.1:5000";

  // ======================================================
  // 🔮 FUNCIÓN 1: LLAMAR AL ENDPOINT DE PREDICCIÓN
  // ======================================================
  Future<Map<String, dynamic>> predecirDemanda({
    required String producto,
    required String categoria,
    required double precioSoles,
    required int oferta,
    required String temporada,
    required int mes,
    required int stockActual,
  }) async {
    final url = Uri.parse('$baseUrl/predict');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "Producto": producto,
        "Categoría": categoria,
        "Precio_Soles": precioSoles,
        "Oferta": oferta,
        "Temporada": temporada,
        "Mes": mes,
        "Stock_Actual": stockActual,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error en predicción: ${response.body}');
    }
  }

  // ======================================================
  // 🔄 FUNCIÓN 2: OBTENER LISTAS DINÁMICAS DEL MODELO
  // (Productos / Categorías / Temporadas)
  // ======================================================
  Future<Map<String, dynamic>> obtenerListasParametros() async {
  final url = Uri.parse('$baseUrl/productos');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    return {
      "productos": List<String>.from(data["productos"] ?? []),
      "categorias": List<String>.from(data["categorias"] ?? []),
      "temporadas": List<String>.from(data["temporadas"] ?? []),
    };
  } else {
    throw Exception("Error al obtener parámetros: ${response.body}");
  }
}

}
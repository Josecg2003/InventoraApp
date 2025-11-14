import 'dart:convert';
import 'package:http/http.dart' as http;

class ModeloIAService {
  // ⚠️ Cambia la IP si usas emulador o dispositivo físico
  final String baseUrl = "http://127.0.0.1:5000";
  // Si estás en web/Windows usa "http://127.0.0.1:5000"
  // Si es dispositivo físico, usa la IP de tu PC (ej: "http://192.168.1.8:5000")

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
      throw Exception('Error al predecir: ${response.body}');
    }
  }
}

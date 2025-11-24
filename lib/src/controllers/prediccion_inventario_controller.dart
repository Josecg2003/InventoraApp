import 'package:flutter/material.dart';
import '..//AI/modelo_ia_service.dart';

class PrediccionInventarioController {
  final _service = ModeloIAService();

  // ⭐ Variable para guardar la predicción y usarla luego en el gráfico
  double? ultimaPrediccion;

  Future<void> predecir(
    BuildContext context, {
    required String producto,
    required String categoria,
    required double precioSoles,
    required int oferta,
    required String temporada,
    required int mes,
    required int stockActual,
  }) async {
    try {
      // 🔹 Llamada al servicio IA
      final resultado = await _service.predecirDemanda(
        producto: producto,
        categoria: categoria,
        precioSoles: precioSoles,
        oferta: oferta,
        temporada: temporada,
        mes: mes,
        stockActual: stockActual,
      );

      // ------------------------------
      // 🟩 NORMALIZAMOS DATOS RECIBIDOS
      // ------------------------------

      // Predicción
      final dynamic predRaw = resultado["Prediccion_Demanda"];
      double predDouble;

      if (predRaw is int) {
        predDouble = predRaw.toDouble();
      } else if (predRaw is double) {
        predDouble = predRaw;
      } else {
        predDouble = double.tryParse(predRaw.toString()) ?? 0;
      }

      // Guardamos para el gráfico (muy importante)
      ultimaPrediccion = predDouble;

      // Compra recomendada
      final dynamic compraRaw = resultado["Compra_Recomendada"];
      double compraDouble;

      if (compraRaw is int) {
        compraDouble = compraRaw.toDouble();
      } else if (compraRaw is double) {
        compraDouble = compraRaw;
      } else {
        compraDouble = double.tryParse(compraRaw.toString()) ?? 0;
      }

      // Convirtiendo a texto para mostrar
      final pred = predDouble.round().toString();
      final compra = compraDouble.toStringAsFixed(2);

      // -------------------------------------
      // 🟦 MOSTRAR DIÁLOGO (Tu versión mejorada)
      // -------------------------------------

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('📊 Resultado de Predicción'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Producto: $producto'),
              Text('Stock Actual: $stockActual'),
              const SizedBox(height: 12),
              Text('📈 Demanda Predicha: **$pred unidades**',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('🛒 Compra Recomendada: $compra unidades'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );

    } catch (e) {
      // -------------------------------------
      // 🟥 MANEJO DE ERROR
      // -------------------------------------
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en la predicción: $e')),
      );
    }
  }
}

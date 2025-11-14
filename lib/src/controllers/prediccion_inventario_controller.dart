import 'package:flutter/material.dart';
import '..//AI/modelo_ia_service.dart';

// lib/src/controllers/prediccion_inventario_controller.dart - Actualización

// ... (resto del código)

class PrediccionInventarioController {
  final _service = ModeloIAService();

  // 🔹 El método debe aceptar los nuevos parámetros con valores por defecto opcionales
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
    // ⚠️ Ahora solo pasamos las variables al servicio
    try {
      final resultado = await _service.predecirDemanda(
        producto: producto,
        categoria: categoria,
        precioSoles: precioSoles,
        oferta: oferta,
        temporada: temporada,
        mes: mes,
        stockActual: stockActual,
      );

      final dynamic predRaw = resultado["Prediccion_Demanda"];
      final dynamic compraRaw = resultado["Compra_Recomendada"];
      final String pred = (predRaw is double) 
    ? predRaw.round().toString() 
    : predRaw.toString();
    
    final String compra = (compraRaw is double) 
    ? compraRaw.toStringAsFixed(2)
    : compraRaw.toString();
    // --- Lógica para mostrar la predicción ---
showDialog(
    context: context,
    builder: (context) => AlertDialog(
        title: const Text('Resultado de Predicción'),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text('Demanda Predicha: **$pred unidades**', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Recomendación de Compra: $compra unidades'), // Ajusta el texto aquí
            ],
        ),
        actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
            ),
        ],
    ),
);

      // ... (El resto de tu lógica de showDialog)
      
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('📈 Predicción de Demanda'),
          content: Text(
            // Muestra los datos que se usaron para la predicción
            'Producto: $producto\nStock Actual: ${stockActual.toInt()}\n\n' 
            'Demanda estimada: $pred unidades\n'
            'Compra recomendada: $compra unidades',
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
      // ... (Manejo de errores)
    }
  }
}

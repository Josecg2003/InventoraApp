import 'package:flutter/material.dart';
import 'modelo_ia_service.dart';

class PrediccionInventarioController {
  final _service = ModeloIAService();

  Future<void> predecir(BuildContext context) async {
    try {
      final resultado = await _service.predecirDemanda(
        producto: "Arroz",
        categoria: "Abarrote",
        precioSoles: 4.50,
        oferta: 1,
        temporada: "Verano",
        mes: 3,
        stockActual: 120,
      );

      final pred = resultado['Prediccion_Demanda'];
      final compra = resultado['Compra_Recomendada'];

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('📈 Predicción de Demanda'),
          content: Text(
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

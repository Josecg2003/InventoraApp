import 'package:flutter/material.dart';
import '../controllers/prediccion_inventario_controller.dart';
import '..//AI/modelo_ia_service.dart';

// 📌 IMPORTA EL GRÁFICO
import '../views/proyeccion_chart.dart';

class PrediccionPage extends StatefulWidget {
  const PrediccionPage({Key? key}) : super(key: key);

  @override
  State<PrediccionPage> createState() => _PrediccionPageState();
}

class _PrediccionPageState extends State<PrediccionPage> {
  // Controladores
  final _formKey = GlobalKey<FormState>();
  final _precioController = TextEditingController(text: '4.50');
  final _stockController = TextEditingController(text: '120');

  // ⭐ GUARDA LA PREDICCIÓN PARA EL GRÁFICO
  double? _prediccion;

  // Listas dinámicas
  List<String> _productos = [];
  List<String> _categorias = [];
  List<String> _temporadas = [];
  bool _isLoading = true;

  // Selecciones actuales
  String? _selectedProducto;
  String? _selectedCategoria;
  String? _selectedTemporada;

  int _selectedOferta = 0;  
  final int _selectedMes = DateTime.now().month;

  final PrediccionInventarioController _controller =
      PrediccionInventarioController();

  final ModeloIAService _iaService = ModeloIAService();

  @override
  void initState() {
    super.initState();
    _cargarParametros();
  }

  Future<void> _cargarParametros() async {
    try {
      final listas = await _iaService.obtenerListasParametros();

      setState(() {
        _productos = listas["productos"] ?? [];
        _categorias = listas["categorias"] ?? [];
        _temporadas = listas["temporadas"] ?? [];

        _selectedProducto = _productos.isNotEmpty ? _productos.first : null;
        _selectedCategoria = _categorias.isNotEmpty ? _categorias.first : null;
        _selectedTemporada = _temporadas.isNotEmpty ? _temporadas.first : null;

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando parámetros: $e')),
      );
    }
  }

  void _submitPrediction() {
    if (_formKey.currentState!.validate() &&
        _selectedProducto != null &&
        _selectedCategoria != null &&
        _selectedTemporada != null) {

      double? precio = double.tryParse(_precioController.text);
      int? stock = int.tryParse(_stockController.text);

      if (precio != null && stock != null) {
        _controller.predecir(
          context,
          producto: _selectedProducto!,
          categoria: _selectedCategoria!,
          precioSoles: precio,
          oferta: _selectedOferta,
          temporada: _selectedTemporada!,
          mes: _selectedMes,
          stockActual: stock,
        );

        // 📌 Guardamos la predicción recién calculada
        setState(() {
          _prediccion = _controller.ultimaPrediccion;
        });
      }
    }
  }

  @override
  void dispose() {
    _precioController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Predicción de Demanda'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Mes actual: $_selectedMes',
                  style: TextStyle(color: Colors.grey)),

              const SizedBox(height: 16),

              _buildDropdownField(
                label: 'Producto',
                value: _selectedProducto,
                items: _productos,
                onChanged: (v) => setState(() => _selectedProducto = v),
              ),

              _buildDropdownField(
                label: 'Categoría',
                value: _selectedCategoria,
                items: _categorias,
                onChanged: (v) => setState(() => _selectedCategoria = v),
              ),

              _buildDropdownField(
                label: 'Temporada',
                value: _selectedTemporada,
                items: _temporadas,
                onChanged: (v) => setState(() => _selectedTemporada = v),
              ),

              _buildTextField(
                controller: _precioController,
                label: 'Precio (S/)',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),

              _buildTextField(
                controller: _stockController,
                label: 'Stock Actual',
                icon: Icons.inventory_2,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              const Text('¿Producto en oferta?',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  _buildOfferRadio(label: 'Sí', value: 1),
                  _buildOfferRadio(label: 'No', value: 0),
                ],
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _submitPrediction,
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('Predecir Demanda'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 25),

              // 📌 MOSTRAR GRÁFICO SI HAY PREDICCIÓN
              if (_prediccion != null)
                ProyeccionFuturaChart(prediccion: _prediccion!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Obligatorio';
          if (double.tryParse(value) == null) return 'Número inválido';
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  Widget _buildOfferRadio({required String label, required int value}) {
    return Expanded(
      child: ListTile(
        title: Text(label),
        leading: Radio<int>(
          value: value,
          groupValue: _selectedOferta,
          onChanged: (v) => setState(() => _selectedOferta = v!),
        ),
      ),
    );
  }
}

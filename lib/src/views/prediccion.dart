import 'package:flutter/material.dart';
// ⚠️ Asegúrate de que esta importación sea correcta.
// Basado en tu estructura, debería ser:
import '../controllers/prediccion_inventario_controller.dart'; 

class PrediccionPage extends StatefulWidget {
  const PrediccionPage({Key? key}) : super(key: key);

  @override
  State<PrediccionPage> createState() => _PrediccionPageState();
}

class _PrediccionPageState extends State<PrediccionPage> {
  final predController = PrediccionInventarioController();
  final _formKey = GlobalKey<FormState>();

  // 🔹 Controllers para campos de texto
  final TextEditingController _productoController = TextEditingController(text: 'Arroz'); // Valor inicial de ejemplo
  final TextEditingController _precioController = TextEditingController(text: '4.50');
  final TextEditingController _stockController = TextEditingController(text: '120');

  // 🔹 Variables para Dropdown (Selección)
  String? _selectedCategoria = 'Abarrote';
  String? _selectedTemporada = 'Verano';
  int? _selectedOferta = 1; // 1 = Con Oferta, 0 = Sin Oferta
  
  // Opciones de ejemplo (deben coincidir con tus LabelEncoders de Python)
  final List<String> _categorias = ['Abarrote', 'Lácteo', 'Electrónico', 'Hogar'];
  final List<String> _temporadas = ['Verano', 'Otoño', 'Invierno', 'Primavera'];
  
  // El mes se puede calcular dinámicamente, pero para la prueba usaremos un valor
  final int _mes = DateTime.now().month; 
  
  @override
  void dispose() {
    _productoController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // 🔹 Función para manejar el envío de la predicción
  void _submitPrediction() {
    if (_formKey.currentState!.validate()) {
      // 1. Recoger todos los datos y convertirlos a sus tipos correctos
      final String producto = _productoController.text.trim();
      final String categoria = _selectedCategoria!;
      final double precioSoles = double.tryParse(_precioController.text.trim()) ?? 0.0;
      final int oferta = _selectedOferta!;
      final String temporada = _selectedTemporada!;
      final int stockActual = int.tryParse(_stockController.text.trim()) ?? 0;
      
      // 2. Llamar al controlador con los datos DINÁMICOS
      predController.predecir(
        context,
        producto: producto,
        categoria: categoria,
        precioSoles: precioSoles,
        oferta: oferta,
        temporada: temporada,
        mes: _mes,
        stockActual: stockActual,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predicción de Demanda'),
        backgroundColor: const Color(0xFF1C1C2D), 
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // 1. Campo Producto
              _buildTextField(_productoController, 'Producto', Icons.inventory, (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese el nombre del producto';
                }
                return null;
              }),
              
              // 2. Campo Precio
              _buildTextField(_precioController, 'Precio (Soles)', Icons.attach_money, (value) {
                if (double.tryParse(value ?? '') == null) {
                  return 'Ingrese un precio válido (ej: 4.50)';
                }
                return null;
              }, keyboardType: TextInputType.number),

              // 3. Campo Stock
              _buildTextField(_stockController, 'Stock Actual', Icons.storage, (value) {
                if (int.tryParse(value ?? '') == null) {
                  return 'Ingrese una cantidad entera de stock';
                }
                return null;
              }, keyboardType: TextInputType.number),
              
              const SizedBox(height: 20),
              
              // 4. Dropdown Categoría
              _buildDropdownField(
                'Categoría',
                _selectedCategoria,
                _categorias,
                Icons.category,
                (String? newValue) {
                  setState(() {
                    _selectedCategoria = newValue;
                  });
                },
              ),

              // 5. Dropdown Temporada
              _buildDropdownField(
                'Temporada',
                _selectedTemporada,
                _temporadas,
                Icons.wb_sunny,
                (String? newValue) {
                  setState(() {
                    _selectedTemporada = newValue;
                  });
                },
              ),
              
              // 6. Selección de Oferta
              _buildOfferSelector(),
              
              const SizedBox(height: 30),
              
              // 7. Botón de Predicción
              ElevatedButton.icon(
                onPressed: _submitPrediction,
                icon: const Icon(Icons.analytics_outlined, color: Colors.white),
                label: const Text(
                  'Predecir Demanda',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Mostrar Mes Actual (informativo)
              Center(child: Text('Mes actual (para IA): $_mes', style: const TextStyle(color: Colors.grey))),
            ],
          ),
        ),
      ),
    );
  }
  
  // --- Widgets de Ayuda ---
  
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    String? Function(String?) validator, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String? currentValue,
    List<String> items,
    IconData icon,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        value: currentValue,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Seleccione una opción' : null,
      ),
    );
  }
  
  Widget _buildOfferSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.discount, color: Colors.grey),
          const SizedBox(width: 15),
          const Text('¿Producto en oferta?', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildOfferChip(1, 'Sí'),
                const SizedBox(width: 10),
                _buildOfferChip(0, 'No'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOfferChip(int value, String label) {
    final isSelected = _selectedOferta == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.blueAccent,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        setState(() {
          _selectedOferta = selected ? value : null;
        });
      },
    );
  }
}
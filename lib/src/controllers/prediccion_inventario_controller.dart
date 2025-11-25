import 'package:flutter/material.dart';
import 'package:inventora_app/services/product_service.dart';
import 'package:inventora_app/src/models/prediccion_model.dart';

class PredictionController extends ChangeNotifier {
  final ProductService _productService = ProductService();

  // --- ESTADO DEL GRÁFICO ---
  bool _isLoading = false;
  List<PredictionPoint> _historicalData = [];
  List<PredictionPoint> _predictedData = [];
  
  // --- DATOS DE RESULTADO ---
  int _predictedDemand = 0;
  double _recommendedPurchase = 0.0;

  // --- ESTADO DEL FORMULARIO (Listas desplegables) ---
  List<String> listProductos = [];
  List<String> listCategorias = [];
  List<String> listTemporadas = [];
  bool _isLoadingOptions = true;

  // --- VALORES SELECCIONADOS POR EL USUARIO ---
  String? selectedProducto;
  String? selectedCategoria;
  String? selectedTemporada;
  int selectedOferta = 0; // 0: No, 1: Sí
  
  // Controladores de texto para mantener el valor
  final TextEditingController precioController = TextEditingController(text: '4.50');
  final TextEditingController stockController = TextEditingController(text: '120');

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingOptions => _isLoadingOptions;
  List<PredictionPoint> get historicalData => _historicalData;
  List<PredictionPoint> get predictedData => _predictedData;
  int get predictedDemand => _predictedDemand;
  double get recommendedPurchase => _recommendedPurchase;

  // Constructor
  PredictionController() {
    loadOptions(); // Carga las listas al iniciar
  }

  // 1. Cargar las listas desde Python
  Future<void> loadOptions() async {
    _isLoadingOptions = true;
    notifyListeners();

    final options = await _productService.getPredictionOptions();
    
    if (options.isNotEmpty) {
      listProductos = options["productos"] ?? [];
      listCategorias = options["categorias"] ?? [];
      listTemporadas = options["temporadas"] ?? [];
      
      // Valores por defecto
      if (listProductos.isNotEmpty) selectedProducto = listProductos.first;
      if (listCategorias.isNotEmpty) selectedCategoria = listCategorias.first;
      if (listTemporadas.isNotEmpty) selectedTemporada = listTemporadas.first;
    }

    _isLoadingOptions = false;
    notifyListeners();
  }

  // 2. Realizar la predicción (Al pulsar el botón)
  Future<void> makePrediction() async {
    if (selectedProducto == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Preparamos los datos del formulario
      final inputForAI = {
        "Producto": selectedProducto,
        "Categoría": selectedCategoria,
        "Precio_Soles": double.tryParse(precioController.text) ?? 0.0,
        "Oferta": selectedOferta,
        "Temporada": selectedTemporada,
        "Mes": DateTime.now().month, // Mes actual automático
        "Stock_Actual": int.tryParse(stockController.text) ?? 0,
      };

      // Llamamos a las DOS APIs en paralelo (Gráfico y Dato Único)
      final results = await Future.wait([
        _productService.getPredictionSerie(inputForAI), // Index 0
        _productService.getPredictionSingle(inputForAI) // Index 1
      ]);

      // --- PROCESAR GRÁFICO ---
      final serieResult = results[0] as List<Map<String, dynamic>>;
      if (serieResult.isNotEmpty) {
        _predictedData = [];
        for (int i = 0; i < serieResult.length; i++) {
          final double yVal = (serieResult[i]['prediccion'] as num).toDouble();
          _predictedData.add(PredictionPoint((i + 1).toDouble(), yVal));
        }
        // Generamos histórico visual falso para unir líneas
        if (_predictedData.isNotEmpty) {
          double startY = _predictedData.first.y;
          _historicalData = [
            PredictionPoint(-4, startY * 0.9),
            PredictionPoint(-2, startY * 0.95),
            PredictionPoint(0, startY),
          ];
        }
      }

      // --- PROCESAR DATO ÚNICO ---
      final singleResult = results[1] as Map<String, dynamic>;
      if (singleResult.isNotEmpty) {
        final dynamic predRaw = singleResult["Prediccion_Demanda"];
        if (predRaw is int) _predictedDemand = predRaw;
        else if (predRaw is double) _predictedDemand = predRaw.round();
        else _predictedDemand = int.tryParse(predRaw.toString()) ?? 0;

        final dynamic compraRaw = singleResult["Compra_Recomendada"];
        if (compraRaw is int) _recommendedPurchase = compraRaw.toDouble();
        else if (compraRaw is double) _recommendedPurchase = compraRaw;
        else _recommendedPurchase = double.tryParse(compraRaw.toString()) ?? 0.0;
      }

    } catch (e) {
      print("Error predicción: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Actualizadores de estado para los Dropdowns
  void setProducto(String? v) { selectedProducto = v; notifyListeners(); }
  void setCategoria(String? v) { selectedCategoria = v; notifyListeners(); }
  void setTemporada(String? v) { selectedTemporada = v; notifyListeners(); }
  void setOferta(int v) { selectedOferta = v; notifyListeners(); }
}
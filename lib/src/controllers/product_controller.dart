// lib/src/controllers/product_controller.dart
import 'package:flutter/material.dart';
import 'package:inventora_app/services/product_service.dart';
import 'package:inventora_app/src/models/product_model.dart';
import 'package:inventora_app/src/models/stats_model.dart';

class ProductController extends ChangeNotifier {

  final ProductService _productService = ProductService();

  // ----- ESTADO -----
  List<Product> _products = [];
  List<String> _categories = [];
  List<String> _providers = [];
  List<CategoryDistribution> _categoriesDistribution = [];
  double _salesData = 0.0;
  double _weeklyRotation = 0.0;
  String _selectedPeriod = 'Día'; // Tu período por defecto
  bool _isLoading = false;
  String? _errorMessage;

  // ----- GETTERS -----
  List<Product> get products => _products;
  List<String> get categories => _categories;
  List<String> get providers => _providers;
  List<CategoryDistribution> get categoriesDistribution => _categoriesDistribution;
  double get salesData => _salesData;
  double get weeklyRotation => _weeklyRotation;
  String get selectedPeriod => _selectedPeriod;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ----- LÓGICA DE NEGOCIO -----
  
  // ✅ 1. CONSTRUCTOR (MODIFICADO)
  ProductController() {
    // Solo llama a fetchProducts(). Esta función se encargará de todo.
    fetchProducts();
  }

  // ✅ 2. fetchProducts (MODIFICADO)
  // Ahora carga TODO, incluyendo las ventas del período por defecto.
  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Hacemos TODAS las peticiones iniciales juntas
      final results = await Future.wait([
        _productService.getProducts(),
        _productService.getCategories(),
        _productService.getProviders(),
        _productService.getCategoriesDistribution(),
        _productService.getSales(_selectedPeriod.toLowerCase()), 
        _productService.getWeeklyRotation(),
      ]);

      // Asignamos todos los resultados
      _products = results[0] as List<Product>;
      _categories = results[1] as List<String>;
      _providers = results[2] as List<String>;
      _categoriesDistribution = results[3] as List<CategoryDistribution>;
      _salesData = results[4] as double; // Asigna las ventas
      _weeklyRotation = results[5] as double;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _products = [];
      _categories = [];
      _providers = [];
      _categoriesDistribution = [];
      _salesData = 0.0;
      _weeklyRotation = 0.0;
    }

    _isLoading = false;
    notifyListeners(); // Notificamos UNA SOLA VEZ, con todos los datos listos.
  }

  // ✅ 3. refreshProducts (MODIFICADO)
  // Ahora es más simple, solo llama a fetchProducts.
  Future<void> refreshProducts() async {
    await fetchProducts(); 
  }

  // ✅ 4. changePeriod (MODIFICADO)
  // Esta función ahora solo se usa para los botones.
  Future<void> changePeriod(String newPeriod) async {
    // Si el usuario toca el mismo botón, no hagas nada
    if (newPeriod == _selectedPeriod) return; 

    _selectedPeriod = newPeriod;
    _isLoading = true; // Mostramos loading
    notifyListeners();

    try {
      // Solo pedimos los datos de ventas
      _salesData = await _productService.getSales(_selectedPeriod.toLowerCase());
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _salesData = 0.0;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // --- (Tus funciones de add, update, delete y registerSale) ---
  // --- (No necesitan cambios) ---

  Future<String?> addProduct(Map<String, dynamic> productData) async {
    _isLoading = true;
    notifyListeners();
    final result = await _productService.createProduct(productData);
    if (result['success']) {
      await refreshProducts(); 
      return null;
    } else {
      _isLoading = false;
      notifyListeners();
      return result['message'];
    }
  }

  Future<String?> updateProduct(int id, Map<String, dynamic> productData) async {
    _isLoading = true;
    notifyListeners();
    final result = await _productService.updateProduct(id, productData);
    if (result['success']) {
      await refreshProducts(); 
      return null;
    } else {
      _isLoading = false;
      notifyListeners();
      return result['message'];
    }
  }
  
  Future<String?> deleteProduct(int id) async {
    _isLoading = true;
    notifyListeners();
    final result = await _productService.deleteProduct(id);
    if (result['success']) {
      await refreshProducts(); 
      return null;
    } else {
      _isLoading = false;
      notifyListeners();
      return result['message'];
    }
  }
  
  Future<String?> registerSale(int productId, int quantity) async {
    final result = await _productService.registerSale(productId, quantity);
    if (result['success']) {
      await refreshProducts(); 
      return null; 
    } else {
      return result['message'];
    }
  }
}
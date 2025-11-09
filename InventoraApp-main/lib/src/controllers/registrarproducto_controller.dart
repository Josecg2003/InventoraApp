// controllers/product_controller.dart
import 'package:inventora_app/src/models/registrarproducto_model.dart';
import 'package:flutter/material.dart';

class ProductController {
  List<Product> products = [
    // Productos de ejemplo
    Product(
      name: 'Smartphone XY-200',
      category: 'Electrónicos',
      price: '\$299.99',
      stock: 15,
      location: 'A1-B2',
      provider: 'TechCorp',
      date: '2024-01-15',
      status: 'Óptimo',
      statusColor: Colors.green,
    ),  
    Product(
      name: 'Auriculares Pro',
      category: 'Electrónicos',
      price: '\$89.99',
      stock: 5,
      location: 'A2-C1',
      provider: 'AudioTech',
      date: '2024-01-14',
      status: 'Bajo',
      statusColor: const Color(0xFFEF4444),
    ),
    // Más productos aquí...
  ];

  List<Product> getProducts() {
    return products;
  }

  void addProduct(Product product) {
    products.add(product);
  }

  void editProduct(int index, Product product) {
    products[index] = product;
  }

  void deleteProduct(int index) {
    products.removeAt(index);
  }

  List<Product> filterProducts(String query, String category, String status) {
    return products.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.category.toLowerCase().contains(query.toLowerCase());

      final matchesCategory = category == 'Todas las categorías' || product.category == category;
      final matchesStatus = status == 'Todos los estados' || product.status == status;

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }
}

import 'package:flutter/material.dart';

class Product {
  final String name;
  final String category;
  final String price;
  final int stock;
  final String location;
  final String provider;
  final String date;
  final String status;
  final Color statusColor;

  Product({
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.location,
    required this.provider,
    required this.date,
    required this.status,
    required this.statusColor,
  });

  // ✅ NUEVO: método estático para calcular el estado del stock
  static StockStatus getStockStatus(int stock) {
    if (stock <= 5) {
      return const StockStatus('Bajo', Colors.red);
    } else if (stock <= 10) {
      return const StockStatus('Medio', Colors.orange);
    } else {
      return const StockStatus('Óptimo', Colors.green);
    }
  }

  // Método para convertir un producto a Map (útil para la base de datos o almacenamiento)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'location': location,
      'provider': provider,
      'date': date,
      'status': status,
      'statusColor': statusColor.value,
    };
  }

  // Método para crear un producto desde un Map (útil para la base de datos o almacenamiento)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      name: map['name'],
      category: map['category'],
      price: map['price'],
      stock: map['stock'],
      location: map['location'],
      provider: map['provider'],
      date: map['date'],
      status: map['status'],
      statusColor: Color(map['statusColor']),
    );
  }
}

// ✅ NUEVA CLASE AUXILIAR para representar el estado y color
class StockStatus {
  final String text;
  final Color color;
  const StockStatus(this.text, this.color);
}

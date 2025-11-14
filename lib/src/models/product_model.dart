// lib/src/models/product_model.dart
import 'dart:convert';

// Función para decodificar una lista de productos
List<Product> productFromJson(String str) => List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

class Product {
    final int id;
    final String name;
    final String? category; // Puede ser nulo si el LEFT JOIN no encuentra
    final double price;
    final int stock;
    final int? stockMinimo;
    final String? provider; // Puede ser nulo
    final double? precioCompra;
    final String status;

    Product({
        required this.id,
        required this.name,
        this.category,
        required this.price,
        required this.stock,
        this.stockMinimo,
        this.provider,
        this.precioCompra,
        required this.status,
    });

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        name: json["name"],
        category: json["category"],
        
        // ✅ CORRECTO: 
        // 1. Convierte el valor a String (ej: "50.00" o 50.0 -> "50.0")
        // 2. tryParse lo convierte a double. Si falla, usa 0.0.
        price: double.tryParse(json["price"].toString()) ?? 0.0,
        
        stock: json["stock"],
        stockMinimo: json["stock_minimo"],
        provider: json["provider"],
        
        // ✅ CORRECTO: Hacemos lo mismo para precioCompra
        precioCompra: json["precio_compra"] == null
            ? null // Si es nulo, lo dejamos nulo
            : double.tryParse(json["precio_compra"].toString()), // Si no, lo parseamos
            
        status: json["status"],
    );
}
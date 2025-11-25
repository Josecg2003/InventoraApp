import 'dart:convert';
import 'package:http/http.dart' as http;

class AlertsService {
  // Cambia según tu configuración
  //static const String baseUrl = 'http://localhost:3000/api';
  static const  String baseUrl = 'https://inventoraapp.onrender.com/api';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ============ RESUMEN DE ALERTAS ============

  static Future<AlertsSummary> getSummary() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alerts/summary'),
        headers: _headers,
      );

      print('GET /alerts/summary - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AlertsSummary.fromJson(data);
      } else {
        throw Exception('Error al cargar resumen de alertas');
      }
    } catch (e) {
      print('❌ Error en getSummary: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // ============ PRODUCTOS CON STOCK BAJO ============

  static Future<List<LowStockProduct>> getLowStockProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alerts/low-stock'),
        headers: _headers,
      );

      print('GET /alerts/low-stock - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => LowStockProduct.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar productos con stock bajo');
      }
    } catch (e) {
      print('❌ Error en getLowStockProducts: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // ============ PRODUCTOS PRÓXIMOS A VENCER ============

  static Future<List<ExpiringProduct>> getExpiringProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alerts/expiring-soon'),
        headers: _headers,
      );

      print('GET /alerts/expiring-soon - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => ExpiringProduct.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar productos próximos a vencer');
      }
    } catch (e) {
      print('❌ Error en getExpiringProducts: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // ============ SUGERENCIAS DE PEDIDO ============

  static Future<List<OrderSuggestion>> getOrderSuggestions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alerts/order-suggestions'),
        headers: _headers,
      );

      print('GET /alerts/order-suggestions - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => OrderSuggestion.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar sugerencias de pedido');
      }
    } catch (e) {
      print('❌ Error en getOrderSuggestions: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // ============ MARCAR COMO LEÍDAS ============

  static Future<bool> markAllAsRead() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/alerts/mark-read'),
        headers: _headers,
      );

      print('POST /alerts/mark-read - Status: ${response.statusCode}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error en markAllAsRead: $e');
      return false;
    }
  }
}

// ============ MODELOS DE DATOS ============

class AlertsSummary {
  final int lowStock;
  final int criticalStock;
  final int expiringSoon;
  final int suggestions;
  final int performanceVariations;
  final int total;
  final int highPriority;

  AlertsSummary({
    required this.lowStock,
    required this.criticalStock,
    required this.expiringSoon,
    required this.suggestions,
    required this.performanceVariations,
    required this.total,
    required this.highPriority,
  });

  factory AlertsSummary.fromJson(Map<String, dynamic> json) {
    return AlertsSummary(
      lowStock: json['lowStock'] ?? 0,
      criticalStock: json['criticalStock'] ?? 0,
      expiringSoon: json['expiringSoon'] ?? 0,
      suggestions: json['suggestions'] ?? 0,
      performanceVariations: json['performanceVariations'] ?? 0,
      total: json['total'] ?? 0,
      highPriority: json['highPriority'] ?? 0,
    );
  }
}

class LowStockProduct {
  final int id;
  final String name;
  final int stock;
  final int minStock;
  final String category;
  final String provider;
  final String status;

  LowStockProduct({
    required this.id,
    required this.name,
    required this.stock,
    required this.minStock,
    required this.category,
    required this.provider,
    required this.status,
  });

  factory LowStockProduct.fromJson(Map<String, dynamic> json) {
    return LowStockProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      stock: json['stock'] ?? 0,
      minStock: json['minStock'] ?? 0,
      category: json['category'] ?? '',
      provider: json['provider'] ?? '',
      status: json['status'] ?? 'Normal',
    );
  }
/*
  Color get statusColor {
    switch (status) {
      case 'Crítico':
        return const Color(0xFFEF4444);
      case 'Bajo':
        return const Color(0xFFFBBF24);
      default:
        return const Color(0xFF4ADE80);
    }
  }
  */
}

class ExpiringProduct {
  final int id;
  final String name;
  final int daysUntilExpiration;
  final int stock;

  ExpiringProduct({
    required this.id,
    required this.name,
    required this.daysUntilExpiration,
    required this.stock,
  });

  factory ExpiringProduct.fromJson(Map<String, dynamic> json) {
    return ExpiringProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      daysUntilExpiration: json['daysUntilExpiration'] ?? 0,
      stock: json['stock'] ?? 0,
    );
  }
}

class OrderSuggestion {
  final int id;
  final String name;
  final int currentStock;
  final int minStock;
  final int suggestedOrder;
  final String provider;
  final double unitPrice;
  final double totalCost;

  OrderSuggestion({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.minStock,
    required this.suggestedOrder,
    required this.provider,
    required this.unitPrice,
    required this.totalCost,
  });

  factory OrderSuggestion.fromJson(Map<String, dynamic> json) {
    return OrderSuggestion(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      currentStock: json['currentStock'] ?? 0,
      minStock: json['minStock'] ?? 0,
      suggestedOrder: json['suggestedOrder'] ?? 0,
      provider: json['provider'] ?? '',
      unitPrice: _parseDouble(json['unitPrice']),
      totalCost: _parseDouble(json['totalCost']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }
}
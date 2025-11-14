// lib/src/models/stats_model.dart
import 'dart:convert';

// Modelo para el gráfico de categorías
class CategoryDistribution {
    final String name;
    final int count;

    CategoryDistribution({
        required this.name,
        required this.count,
    });

    factory CategoryDistribution.fromJson(Map<String, dynamic> json) => CategoryDistribution(
        name: json["name"],
        count: json["count"],
    );
}

// Función helper
List<CategoryDistribution> categoryDistributionFromJson(String str) => List<CategoryDistribution>.from(json.decode(str).map((x) => CategoryDistribution.fromJson(x)));
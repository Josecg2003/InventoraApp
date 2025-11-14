// lib/src/models/login_model.dart
// (Vamos a llamarlo user_model.dart para más claridad,
// pero puedes usar tu archivo login_model.dart)

import 'dart:convert';

// Función para decodificar JSON
User userFromJson(String str) => User.fromJson(json.decode(str));

class User {
    final int id;
    final String name;
    final String email;
    final String role;

    User({
        required this.id,
        required this.name,
        required this.email,
        required this.role,
    });

    // Factory para crear un Usuario desde un mapa (JSON)
    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        role: json["role"],
    );
}
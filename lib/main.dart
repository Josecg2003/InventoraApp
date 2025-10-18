import 'package:flutter/material.dart';
// Asegúrate de que esta ruta sea correcta según tu estructura de carpetas
import 'package:inventora_app/src/views/login.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventora App',
      debugShowCheckedModeBanner: false, // Oculta la cinta de "Debug"
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Aquí le decimos a la app que empiece con tu LoginScreen
      home: const LoginScreen(), 
    );
  }
}
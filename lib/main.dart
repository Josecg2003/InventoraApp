// lib/main.dart
import 'package:flutter/material.dart';
import 'package:inventora_app/src/controllers/login_controller.dart';
import 'package:inventora_app/src/controllers/register_controller.dart';
import 'package:inventora_app/src/controllers/product_controller.dart';
import 'package:inventora_app/src/controllers/prediccion_inventario_controller.dart';
import 'package:inventora_app/src/views/login.dart'; // Tu vista de login
import 'package:provider/provider.dart';

void main() {
  runApp(const AppState()); // Ejecuta el widget que proveerá el estado
}

class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider( 
      providers: [
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => RegisterController()),
        ChangeNotifierProvider(create: (_) => ProductController()),
        ChangeNotifierProvider(create: (_) => PredictionController()),
        
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventora App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // O la ruta que prefieras
      routes: {
        '/login': (context) => const LoginScreen(), // Tu vista de login
        // '/register': (context) => RegisterView(),
        // '/home': (context) => HomeView(),
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:inventora_app/src/views/registro.dart';
import 'package:inventora_app/src/views/home.dart';
import '../controllers/login_controller.dart'; // ✅ NUEVA IMPORTACIÓN

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // ✅ PARA VALIDACIONES
  bool _obscurePassword = true;
  bool _isLoading = false; // ✅ ESTADO DE CARGA

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ✅ MÉTODO MEJORADO PARA MANEJAR LOGIN
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authController = AuthController(context);
      await authController.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ VALIDADOR DE EMAIL
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor ingresa un email válido';
    }
    return null;
  }

  // ✅ VALIDADOR DE CONTRASEÑA
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  // ✅ MÉTODO PARA RECUPERAR CONTRASEÑA
  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar Contraseña'),
        content: TextField(
          controller: TextEditingController(text: _emailController.text),
          decoration: const InputDecoration(
            labelText: 'Ingresa tu email',
            hintText: 'usuario@ejemplo.com',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final authController = AuthController(context);
              authController.recoverPassword(_emailController.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form( // ✅ FORM PARA VALIDACIONES
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  
                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/img/inventora_logo.jpeg',
                      height: 200,
                      width: 200,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Título
                  const Text(
                    'Inicio de Sesión',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C5F5D),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Campo de correo electrónico
                  const Text(
                    'Correo electrónico',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField( // ✅ CAMBIO: TextField a TextFormField
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFE0E0E0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      errorStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Campo de contraseña
                  const Text(
                    'Contraseña',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField( // ✅ CAMBIO: TextField a TextFormField
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFE0E0E0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      errorStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Olvidaste tu contraseña
                  GestureDetector(
                    onTap: _isLoading ? null : _handleForgotPassword,
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        fontSize: 13,
                        color: _isLoading ? Colors.grey[400] : Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Botón de iniciar sesión
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Registro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿Aún no tienes cuenta? ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                );
                              },
                        child: Text(
                          'Regístrate',
                          style: TextStyle(
                            fontSize: 13,
                            color: _isLoading ? Colors.grey[400] : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
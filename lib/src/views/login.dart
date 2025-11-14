import 'package:flutter/material.dart';
import 'package:inventora_app/src/views/registro.dart';
import 'package:inventora_app/src/views/home.dart';
import '../controllers/login_controller.dart'; // ✅ Importación del Controller
import 'package:provider/provider.dart';      // ✅ Importación de Provider

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  // bool _isLoading = false; // ⛔ ELIMINADO: Ahora lo maneja el LoginController

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ✅ MÉTODO MEJORADO PARA MANEJAR LOGIN CON PROVIDER
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      
      // 1. Obtenemos el controller (con 'read' porque estamos en una función)
      final loginController = context.read<LoginController>();

      // 2. Llamamos a la función del controller
      final bool didLogin = await loginController.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // 3. Reaccionamos al resultado
      if (didLogin && mounted) {
        // Éxito: Navegamos a la pantalla de Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
      // Si 'didLogin' es falso, no hacemos nada aquí.
      // El Consumer se encargará de mostrar el 'errorMessage' del controller.
    }
  }

  // ... Tus métodos de validación (¡están perfectos!) ...
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  // ✅ MÉTODO PARA RECUPERAR CONTRASEÑA (Lógica pendiente en el controller)
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
              // --- TAREA PENDIENTE ---
              // 1. Añadir `recoverPassword(email)` a LoginController
              // 2. Añadir `recoverPassword(email)` a AuthService
              // 3. Implementar la lógica en el backend
              //
              // final authController = context.read<LoginController>();
              // authController.recoverPassword(_emailController.text.trim());
              // Navigator.pop(context);
              
              // Por ahora, solo cerramos el diálogo
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función de recuperar no implementada')),
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 4. Envolvemos el Scaffold en un CONSUMER
    // Esto hace que la UI reaccione a los cambios del LoginController
    return Consumer<LoginController>(
      builder: (context, controller, child) {
        
        // 'controller' es la instancia de tu LoginController
        
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      
                      Center(
                        child: Image.asset(
                          'assets/img/inventora_logo.jpeg',
                          height: 200,
                          width: 200,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
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
                      
                      // ... (Texto 'Correo electrónico') ...
                      const Text(
                        'Correo electrónico',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        // ✅ Desactivamos los campos si está cargando
                        enabled: !controller.isLoading, 
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
                      
                      // ... (Texto 'Contraseña') ...
                       const Text(
                        'Contraseña',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: _validatePassword,
                        // ✅ Desactivamos los campos si está cargando
                        enabled: !controller.isLoading,
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
                      
                      GestureDetector(
                        // ✅ Usamos el 'isLoading' del controller
                        onTap: controller.isLoading ? null : _handleForgotPassword,
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            fontSize: 13,
                            color: controller.isLoading ? Colors.grey[400] : Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      
                      // ✅ WIDGET PARA MOSTRAR ERROR (NUEVO)
                      if (controller.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            controller.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      
                      const SizedBox(height: 32),
                      
                      ElevatedButton(
                        // ✅ Usamos el 'isLoading' del controller
                        onPressed: controller.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        // ✅ Usamos el 'isLoading' del controller
                        child: controller.isLoading
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
                            // ✅ Usamos el 'isLoading' del controller
                            onTap: controller.isLoading
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
                                color: controller.isLoading ? Colors.grey[400] : Colors.black,
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
      }, // <-- Cierre del Consumer builder
    );
  }
}
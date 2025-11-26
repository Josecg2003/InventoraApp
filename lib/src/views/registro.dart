import 'package:flutter/material.dart';
import 'package:inventora_app/src/controllers/register_controller.dart'; // ✅ Importación
import 'package:provider/provider.dart'; // ✅ Importación

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryCodeController = TextEditingController(text: '+51');
  final _phoneController = TextEditingController(); // Lo guardamos pero no lo enviamos
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  // ⛔ _isLoading se elimina, ahora lo maneja el controller

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _countryCodeController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ✅ MÉTODO DE REGISTRO ACTUALIZADO CON EL CONTROLLER
  void _handleRegister() async {
    // 1. Validar el formulario (campos vacíos, email, etc)
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Validar los términos y condiciones
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 3. Si todo es válido, llamar al controller
    final registerController = context.read<RegisterController>();

    final bool didRegister = await registerController.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      // Nota: El teléfono no se envía, tal como pediste
    );

    // 4. Reaccionar al resultado
    if (didRegister && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ ¡Registro exitoso! Por favor, inicia sesión.')),
      );
      Navigator.pop(context); // Regresar a la pantalla de Login
    }
    // Si 'didRegister' es falso, el Consumer de abajo mostrará el error.
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Envolvemos la UI en un Consumer para que reaccione a los cambios
    return Consumer<RegisterController>(
      builder: (context, controller, child) {
        
        return Scaffold(
          backgroundColor: Colors.white,
          // ✅ Añadimos un AppBar para poder volver
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              // Desactivar el botón si está cargando
              onPressed: controller.isLoading ? null : () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // const SizedBox(height: 30), // Ya no es necesario por el AppBar
                      
                      // Logo
                      Center(
                        child: Image.asset(
                          'assets/img/inventora_logo.jpeg',
                          height: 180,
                          width: 180,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Título
                      const Text(
                        'Registrarse',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C5F5D),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // ... (Texto 'Nombres y apellidos')
                      const Text(
                        'Nombres y apellidos',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        enabled: !controller.isLoading, // ✅ Desactivar si carga
                        decoration: _buildInputDecoration(), // Helper de decoración
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu nombre';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // ... (Texto 'Correo electrónico')
                      const Text(
                        'Correo electrónico',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        enabled: !controller.isLoading, // ✅ Desactivar si carga
                        keyboardType: TextInputType.emailAddress,
                        decoration: _buildInputDecoration(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu correo';
                          }
                          if (!value.contains('@')) {
                            return 'Ingresa un correo válido';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // ... (Texto 'Número de celular')
                      const Text(
                        'Número de celular',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Código de país
                          SizedBox(
                            width: 70,
                            child: TextFormField(
                              controller: _countryCodeController,
                              enabled: !controller.isLoading, // ✅ Desactivar si carga
                              keyboardType: TextInputType.phone,
                              textAlign: TextAlign.center,
                              decoration: _buildInputDecoration(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Número de teléfono
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              enabled: !controller.isLoading, // ✅ Desactivar si carga
                              keyboardType: TextInputType.phone,
                              decoration: _buildInputDecoration(),
                              // Lo hacemos opcional, quitamos el validador
                              // validator: (value) { ... } 
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      
                      const Text(
                        'Contraseña',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        enabled: !controller.isLoading, 
                        obscureText: _obscurePassword,
                        decoration: _buildInputDecoration().copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() { _obscurePassword = !_obscurePassword; });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa una contraseña';
                          }
                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // ... (Texto 'Confirmar contraseña')
                      const Text(
                        'Confirmar contraseña',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        enabled: !controller.isLoading, 
                        obscureText: _obscureConfirmPassword,
                        decoration: _buildInputDecoration().copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() { _obscureConfirmPassword = !_obscureConfirmPassword; });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor confirma tu contraseña';
                          }
                          if (value != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Checkbox de términos y condiciones
                      Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _acceptTerms,
                              // ✅ Desactivar si carga
                              onChanged: controller.isLoading ? null : (value) {
                                setState(() {
                                  _acceptTerms = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF2C5F5D),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                // Mostrar términos y condiciones
                              },
                              child: const Text(
                                'Aceptar términos y condiciones',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
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
                      
                      const SizedBox(height: 30),
                      
                      // Botón de crear cuenta
                      ElevatedButton(
                        // ✅ Usamos el 'isLoading' del controller
                        onPressed: controller.isLoading ? null : _handleRegister,
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
                                'Crear cuenta',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ✅ Helper para no repetir el estilo de los InputDecoration
  InputDecoration _buildInputDecoration() {
    return InputDecoration(
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
    );
  }
}
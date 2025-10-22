class User {
  final String email;
  final String password;

  User({
    required this.email,
    required this.password,
  });

  // Validar si el email tiene formato válido
  bool isValidEmail() {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Validar si la contraseña cumple con requisitos mínimos
  bool isValidPassword() {
    return password.length >= 6;
  }

  // Validar que ambos campos estén completos
  bool areFieldsComplete() {
    return email.isNotEmpty && password.isNotEmpty;
  }

  // Simular autenticación (reemplaza con tu lógica real)
  Future<bool> authenticate() async {
    await Future.delayed(const Duration(seconds: 1)); // Simular delay de red
    
    // Credenciales de ejemplo - reemplaza con tu lógica real
    return email == "admin@inventora.com" && password == "password123";
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
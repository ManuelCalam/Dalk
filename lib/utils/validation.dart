// lib/utils/validators.dart

class Validators {
  static String? requiredField(String? value, {String fieldName = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Correo obligatorio';
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!regex.hasMatch(value)) return 'Correo inválido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Contraseña obligatoria';
    if (value.length < 15) return 'Mínimo 15 caracteres';
    return null;
  }

  static String? postalCode(String? value) {
    if (value == null || value.isEmpty) return 'obligatorio';
    final regex = RegExp(r'^\d{5}$');
    if (!regex.hasMatch(value)) return 'inválido';
    return null;
  }

  static String? date(DateTime? date) {
    if (date == null) return 'Fecha obligatoria';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Teléfono obligatorio';
    final regex = RegExp(r'^\d{10}$');
    if (!regex.hasMatch(value)) return 'Teléfono inválido';
    return null;
  }
}

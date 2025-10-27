// lib/utils/validators.dart

class Validators {
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value != null && value.length > max) {
      return '$fieldName no puede tener más de $max caracteres';
    }
    return null;
  }

  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value != null && value.length < min) {
      return '$fieldName debe tener al menos $min caracteres';
    }
    return null;
  }

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
    if (value.length < 8) return 'Mínimo 8 caracteres';
    return null;
  }

  static String? postalCode(String? value) {
    if (value == null || value.isEmpty) return 'Código postal obligatorio';
    final regex = RegExp(r'^\d{5}$');
    if (!regex.hasMatch(value)) return 'Código postal a 5 digitos';
    return null;
  }

  static String? date(DateTime? date) {
    if (date == null) return 'Fecha obligatoria';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Teléfono obligatorio';
    final regex = RegExp(r'^\d{10}$');
    if (!regex.hasMatch(value)) return 'Teléfono a 10 dígitos';
    return null;
  }


  static String formatDisplayName(String userName) {
    if (userName.isEmpty) {
      return 'Usuario';
    }

    final cleanName = userName.trim();

    // Dividir la cadena por uno o más espacios y filtrar elementos vacíos
    final nameParts = cleanName
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();

    if (nameParts.isEmpty) {
      return 'Usuario';
    }
    
    if (nameParts.length == 1) {
      return nameParts[0];
    }
    
    try {
      final primerNombre = nameParts[0];
      final inicialApellido = nameParts[1][0]; 

      return '$primerNombre $inicialApellido.';

    } catch (e) {
      return nameParts[0]; 
    }
  }
}

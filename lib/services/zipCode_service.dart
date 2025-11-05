import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PostalCodeInfo {
  final String city;
  final List<String> neighborhoods;
  final bool isValid;

  PostalCodeInfo({
    required this.city,
    required this.neighborhoods,
    required this.isValid,
  });
}

class ZipCodeService {
  final String apiKey = dotenv.env['MAPS_API_KEY']!;

  /// Obtiene información completa del código postal (ciudad y colonias)
  Future<PostalCodeInfo> getPostalCodeInfo(String postalCode) async {
    try {
      // Validación básica de formato
      if (postalCode.length != 5) {
        print('❌ CP inválido: debe tener 5 dígitos');
        return PostalCodeInfo(city: '', neighborhoods: [], isValid: false);
      }

      print('🔍 Consultando CP: $postalCode');
      print('🔑 API Key: ${apiKey.substring(0, 10)}...');

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=$postalCode&components=country:MX&key=$apiKey',
      );

      print('🌐 URL completa (sin key): https://maps.googleapis.com/maps/api/geocode/json?address=$postalCode&components=country:MX&key=...');

      final response = await http.get(url);

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode != 200) {
        return PostalCodeInfo(city: '', neighborhoods: [], isValid: false);
      }

      final data = json.decode(response.body);

      // Imprimir el status de Google
      print('📍 Google Status: ${data['status']}');
      if (data['error_message'] != null) {
        print('❌ Error Message: ${data['error_message']}');
      }

      // Verificar el status de la API
      if (data['status'] != 'OK') {
        return PostalCodeInfo(city: '', neighborhoods: [], isValid: false);
      }

      final results = data['results'] as List;
      print('📋 Cantidad de resultados: ${results.length}');

      // Verificar que sea de Jalisco
      bool isJalisco = false;
      String cityName = '';
      Set<String> neighborhoods = {};

      for (var result in results) {
        final addressComponents = result['address_components'] as List;

        // Verificar código postal
        final hasPostalCode = addressComponents.any((comp) =>
            comp['types'].contains('postal_code') &&
            comp['long_name'] == postalCode);

        if (!hasPostalCode) continue;

        // Verificar estado
        final stateComponent = addressComponents.firstWhere(
          (comp) => comp['types'].contains('administrative_area_level_1'),
          orElse: () => {},
        );

        if (stateComponent.isNotEmpty) {
          final stateName = stateComponent['long_name'] as String?;
          final stateShortName = stateComponent['short_name'] as String?;
          isJalisco = stateName == 'Jalisco' || stateShortName == 'Jal.';
          print('🏛️ Estado encontrado: $stateName ($stateShortName)');
        }

        // Obtener ciudad
        final cityComponent = addressComponents.firstWhere(
          (comp) => comp['types'].contains('locality'),
          orElse: () => {},
        );

        if (cityComponent.isNotEmpty && cityName.isEmpty) {
          cityName = cityComponent['long_name'] as String;
          print('🏙️ Ciudad encontrada: $cityName');
        }

        // Obtener colonia/sublocality
        final neighborhoodComponent = addressComponents.firstWhere(
          (comp) =>
              comp['types'].contains('sublocality') ||
              comp['types'].contains('sublocality_level_1') ||
              comp['types'].contains('neighborhood'),
          orElse: () => {},
        );

        if (neighborhoodComponent.isNotEmpty) {
          neighborhoods.add(neighborhoodComponent['long_name'] as String);
        }
      }

      print('✅ Es de Jalisco: $isJalisco');
      print('🏘️ Colonias encontradas: ${neighborhoods.length}');
      print('📝 Lista de colonias: $neighborhoods');

      if (!isJalisco) {
        print('❌ Rechazado: no es de Jalisco');
        return PostalCodeInfo(city: '', neighborhoods: [], isValid: false);
      }

      // Si no hay colonias, agregar una opción genérica
      if (neighborhoods.isEmpty) {
        print('⚠️ No se encontraron colonias, agregando "Centro"');
        neighborhoods.add('Centro');
      }

      print('✅ CP VÁLIDO: $cityName con ${neighborhoods.length} colonias');

      return PostalCodeInfo(
        city: cityName,
        neighborhoods: neighborhoods.toList()..sort(),
        isValid: true,
      );
    } catch (e) {
      print('💥 Error obteniendo info del CP: $e');
      print('📍 Stack trace: ${StackTrace.current}');
      return PostalCodeInfo(city: '', neighborhoods: [], isValid: false);
    }
  }

  /// Valida si el código postal existe y pertenece a Jalisco, México
  Future<bool> validatePostalCode(String postalCode) async {
    final info = await getPostalCodeInfo(postalCode);
    return info.isValid;
  }
}
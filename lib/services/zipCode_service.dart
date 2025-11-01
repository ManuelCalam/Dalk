import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ZipCodeService {
  final String apiKey = dotenv.env['MAPS_API_KEY']!;

  /// Valida si el código postal existe y pertenece a Jalisco, México
  Future<bool> validatePostalCode(String postalCode) async {
    try {
      // Validación básica de formato
      if (postalCode.length != 5) {
        return false;
      }

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=$postalCode&components=country:MX&key=$apiKey',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) {
        return false;
      }

      final data = json.decode(response.body);

      // Verificar el status de la API
      if (data['status'] != 'OK') {
        return false;
      }

      final result = data['results'][0];
      final addressComponents = result['address_components'] as List;

      // Verificar que sea un código postal válido
      final isPostalCode = addressComponents.any((comp) =>
          comp['types'].contains('postal_code') &&
          comp['long_name'] == postalCode);

      if (!isPostalCode) {
        return false;
      }

      // Verificar que pertenezca a Jalisco
      final stateComponent = addressComponents.firstWhere(
        (comp) => comp['types'].contains('administrative_area_level_1'),
        orElse: () => {},
      );

      if (stateComponent.isEmpty) {
        return false;
      }

      final stateName = stateComponent['long_name'] as String?;
      final stateShortName = stateComponent['short_name'] as String?;

      final isJalisco = stateName == 'Jalisco' || stateShortName == 'Jal.';

      return isJalisco;
    } catch (e) {
      print('Error validando CP: $e');
      return false;
    }
  }
}
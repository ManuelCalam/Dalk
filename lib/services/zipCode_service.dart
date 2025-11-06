import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

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
  static List<List<dynamic>>? _cachedData;
  static Map<String, PostalCodeInfo>? _postalCodeCache;

  Future<void> _loadCSVData() async {
    if (_cachedData != null) return;

    try {
      print('📂 Cargando datos de códigos postales...');
      final rawData = await rootBundle.loadString('assets/data/jalisco_postalcodes.csv');
      
      _cachedData = const CsvToListConverter().convert(
        rawData,
        fieldDelimiter: ',',
        eol: '\n',
      );

      print('Datos cargados: ${_cachedData!.length} registros');
      
      _postalCodeCache = {};
      
      for (var i = 1; i < _cachedData!.length; i++) {
        final row = _cachedData![i];
        
        if (row.length < 4) continue;
        
        final postalCode = row[0].toString().trim();
        final neighborhood = row[1].toString().trim();
        final city = row[3].toString().trim();

        if (postalCode.isEmpty || neighborhood.isEmpty || city.isEmpty) continue;

        if (_postalCodeCache!.containsKey(postalCode)) {
          if (!_postalCodeCache![postalCode]!.neighborhoods.contains(neighborhood)) {
            _postalCodeCache![postalCode]!.neighborhoods.add(neighborhood);
          }
        } else {
          _postalCodeCache![postalCode] = PostalCodeInfo(
            city: city,
            neighborhoods: [neighborhood],
            isValid: true,
          );
        }
      }

      print('Cache creado: ${_postalCodeCache!.length} códigos postales únicos');
      
    } catch (e, stackTrace) {
      print('Error cargando CSV: $e');
      print('Stack trace: $stackTrace');
      _cachedData = [];
      _postalCodeCache = {};
    }
  }

  Future<PostalCodeInfo> getPostalCodeInfo(String postalCode) async {
    try {
      if (postalCode.length != 5 || !RegExp(r'^\d+$').hasMatch(postalCode)) {
        print('Formato de CP inválido: $postalCode');
        return PostalCodeInfo(city: '', neighborhoods: [], isValid: false);
      }

      await _loadCSVData();

      if (_postalCodeCache!.containsKey(postalCode)) {
        final info = _postalCodeCache![postalCode]!;
        final sortedNeighborhoods = List<String>.from(info.neighborhoods)..sort();
        
        print('CP encontrado: $postalCode');
        print('Municipio: ${info.city}'); 
        print('Colonias: ${sortedNeighborhoods.length}');
        
        return PostalCodeInfo(
          city: info.city,
          neighborhoods: sortedNeighborhoods,
          isValid: true,
        );
      } else {
        print('CP no encontrado en Jalisco: $postalCode');
        return PostalCodeInfo(city: '', neighborhoods: [], isValid: false);
      }
      
    } catch (e, stackTrace) {
      print('Error obteniendo info del CP: $e');
      print('Stack trace: $stackTrace');
      return PostalCodeInfo(city: '', neighborhoods: [], isValid: false);
    }
  }

  Future<bool> validatePostalCode(String postalCode) async {
    final info = await getPostalCodeInfo(postalCode);
    return info.isValid;
  }

  static void clearCache() {
    _cachedData = null;
    _postalCodeCache = null;
    print('🗑️ Cache limpiado');
  }
}
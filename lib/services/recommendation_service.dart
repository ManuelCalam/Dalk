import 'dart:convert';
import '/backend/supabase/supabase.dart';
import 'package:http/http.dart' as http;

class RecommendationService {
  // CORREGIR: Usar la URL correcta de Cloud Run
  static const String _baseUrl = 'https://recomendar-rtwziiuflq-uc.a.run.app';
  
  // Obtener recomendación para un paseador específico
  static Future<Map<String, dynamic>> getRecommendation({
    required int ownerNumPets,
    required double ownerAvgPetAge,
    required int ownerCountLargePets,
    required int ownerLastWalkDays,
    required double ownerAvgRating,
    required int ownerTotalWalks,
    required double walkerFee,
    required double walkerRate,
    required int walkerWorkingDaysCount,
    required double walkerAvgRating,
    required int walkerNumReviews,
    required int walkerWalks30d,
    required int walkerWalks7d,
    required int walkerWalks90d,
    required double walkerCancelRate,
    required double walkerAcceptanceRate,
    required int walkerAvailableNext7,
    required int workingHoursRange,
  }) async {
    try {
      print('Enviando solicitud a la API de recomendacion');
      
      // CONVERTIR todos los valores a los tipos correctos
      final requestBody = {
        'owner_num_pets': ownerNumPets,
        'owner_avg_pet_age': ownerAvgPetAge.toDouble(),
        'owner_count_large_pets': ownerCountLargePets,
        'owner_last_walk_days': ownerLastWalkDays,
        'owner_avg_rating': ownerAvgRating.toDouble(),
        'owner_total_walks': ownerTotalWalks,
        'walker_fee': walkerFee.toDouble(),
        'walker_rate': walkerRate.toDouble(),
        'walker_working_days_count': walkerWorkingDaysCount,
        'walker_avg_rating': walkerAvgRating.toDouble(),
        'walker_num_reviews': walkerNumReviews,
        'walker_walks_30d': walkerWalks30d,
        'walker_walks_7d': walkerWalks7d,
        'walker_walks_90d': walkerWalks90d,
        'walker_cancel_rate': walkerCancelRate.toDouble(),
        'walker_acceptance_rate': walkerAcceptanceRate.toDouble(),
        'walker_available_next7': walkerAvailableNext7,
        'working_hours_range': workingHoursRange,
      };

      print('Datos enviados: $requestBody');
      
      final response = await http.post(
        Uri.parse('https://recomendar-rtwziiuflq-uc.a.run.app'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Respuesta recibida - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Recomendacion exitosa: $result');
        return result;
      } else {
        print('Error en la API: ${response.statusCode} - ${response.body}');
        throw Exception('Error en la API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexion: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getActiveWalkersWithFeatures() async {
    try {
      print('Obteniendo paseadores activos desde features_per_walker');
      final response = await Supabase.instance.client
          .from('features_per_walker')
          .select();

      final walkers = List<Map<String, dynamic>>.from(response);
      print('Paseadores obtenidos: ${walkers.length}');
      return walkers;
    } catch (e) {
      print('Error obteniendo paseadores: $e');
      throw Exception('Error obteniendo paseadores: $e');
    }
  }

  static Future<Map<String, dynamic>> getOwnerFeatures(String ownerId) async {
    try {
      print('Obteniendo features del dueño: $ownerId');
      final response = await Supabase.instance.client
          .from('features_per_owner')
          .select()
          .eq('owner_id', ownerId)
          .single();

      final ownerFeatures = Map<String, dynamic>.from(response);
      print('Features del dueño obtenidas: $ownerFeatures');
      return ownerFeatures;
    } catch (e) {
      print('Error obteniendo features del dueño: $e');
      throw Exception('Error obteniendo features del dueño: $e');
    }
  }

  static Future<List<String>> getTop3RecommendedWalkers(String ownerId) async {
    print('INICIANDO getTop3RecommendedWalkers para owner: $ownerId');
    
    try {
      // 1. Obtener features del dueño
      print('Obteniendo features del dueño...');
      final ownerFeatures = await getOwnerFeatures(ownerId);

      // 2. Obtener todos los paseadores activos
      print('Obteniendo paseadores activos...');
      final walkers = await getActiveWalkersWithFeatures();

      if (walkers.isEmpty) {
        print('No se encontraron paseadores activos');
        return [];
      }

      // 3. Lista para almacenar resultados
      final List<Map<String, dynamic>> recommendations = [];

      // 4. Probar solo con los primeros 5 paseadores (para no saturar)
      final walkersToProcess = walkers.take(5).toList();
      print('Procesando ${walkersToProcess.length} paseadores...');

      for (final walker in walkersToProcess) {
        try {
          print('Analizando paseador: ${walker['name']}');
          
          final recommendation = await getRecommendation(
            ownerNumPets: ownerFeatures['owner_num_pets'] != null ? int.tryParse(ownerFeatures['owner_num_pets'].toString()) ?? 1 : 1,
            ownerAvgPetAge: ownerFeatures['owner_avg_pet_age'] != null ? double.tryParse(ownerFeatures['owner_avg_pet_age'].toString()) ?? 2.0 : 2.0,
            ownerCountLargePets: ownerFeatures['owner_count_large_pets'] != null ? int.tryParse(ownerFeatures['owner_count_large_pets'].toString()) ?? 0 : 0,
            ownerLastWalkDays: ownerFeatures['owner_last_walk_days'] != null ? int.tryParse(ownerFeatures['owner_last_walk_days'].toString()) ?? 30 : 30,
            ownerAvgRating: ownerFeatures['owner_avg_rating'] != null ? double.tryParse(ownerFeatures['owner_avg_rating'].toString()) ?? 4.0 : 4.0,
            ownerTotalWalks: ownerFeatures['owner_total_walks'] != null ? int.tryParse(ownerFeatures['owner_total_walks'].toString()) ?? 0 : 0,
            walkerFee: double.tryParse(walker['walker_fee']?.toString() ?? '0') ?? 0.0,
            walkerRate: double.tryParse(walker['walker_rate']?.toString() ?? '0') ?? 0.0,
            walkerWorkingDaysCount: walker['walker_working_days_count'] != null ? int.tryParse(walker['walker_working_days_count'].toString()) ?? 0 : 0,
            walkerAvgRating: double.tryParse(walker['walker_avg_rating']?.toString() ?? '0') ?? 0.0,
            walkerNumReviews: walker['walker_num_reviews'] != null ? int.tryParse(walker['walker_num_reviews'].toString()) ?? 0 : 0,
            walkerWalks30d: walker['walker_walks_30d'] != null ? int.tryParse(walker['walker_walks_30d'].toString()) ?? 0 : 0,
            walkerWalks7d: walker['walker_walks_7d'] != null ? int.tryParse(walker['walker_walks_7d'].toString()) ?? 0 : 0,
            walkerWalks90d: walker['walker_walks_90d'] != null ? int.tryParse(walker['walker_walks_90d'].toString()) ?? 0 : 0,
            walkerCancelRate: double.tryParse(walker['walker_cancel_rate']?.toString() ?? '0') ?? 0.0,
            walkerAcceptanceRate: double.tryParse(walker['walker_acceptance_rate']?.toString() ?? '0') ?? 0.0,
            walkerAvailableNext7: walker['walker_available_next7'] != null ? int.tryParse(walker['walker_available_next7'].toString()) ?? 0 : 0,
            workingHoursRange: walker['working_hours_range'] != null ? int.tryParse(walker['working_hours_range'].toString()) ?? 0 : 0,
          );

          // Solo nos interesan los recomendados (predicted_rating == 1)
          if (recommendation['predicted_rating'] == 1) {
            recommendations.add({
              'walker_id': walker['walker_id'],
              'confidence_score': recommendation['confidence_score'],
              'walker_data': walker,
            });
            print('Paseador recomendado: ${walker['name']} - Score: ${recommendation['confidence_score']}');
          } else {
            print('Paseador NO recomendado: ${walker['name']} - Rating: ${recommendation['predicted_rating']}');
          }

          // Pequeña pausa para no saturar la API
          await Future.delayed(const Duration(milliseconds: 200));
          
        } catch (e) {
          print('Error procesando paseador ${walker['name']}: $e');
        }
      }

      // 5. Ordenar por confidence score (mayor a menor) y tomar top 3
      recommendations.sort((a, b) => (b['confidence_score'] as double).compareTo(a['confidence_score'] as double));
      
      final top3 = recommendations.take(3).toList();
      
      // 6. Devolver solo los UUIDs de los 3 mejores
      final top3UUIDs = top3.map((rec) => rec['walker_id'].toString()).toList();
      
      print('Top 3 paseadores recomendados: $top3UUIDs');
      print('Total de recomendaciones encontradas: ${recommendations.length}');
      print('Top 3 seleccionados: $top3UUIDs');
      
      return top3UUIDs;

    } catch (e) {
      print('ERROR en getTop3RecommendedWalkers: $e');
      return []; // Si hay error, devolver lista vacía
    }
  }
}
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';

// Definir el entry point de la ejecución del servicio de fondo
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
 print('[BG SERVICE] onStart ejecutado.');

   try {
      await Firebase.initializeApp(); 
  } catch (e) {
      service.stopSelf();
      return;
  }
 
 String? walkId;
 Timer? locationTimer;

  if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
          title: "Dalk: Rastreo",
          content: "Servicio de rastreo en 2do plano activo.",
      );
  }


 // 1. ESCUCHAR DATOS INICIALES (walkId)
 service.on('setData').listen((event) {
  print('[BG SERVICE] Evento setData recibido: $event');
  final newWalkId = event?['walkId'] as String?;
  
  if (newWalkId != null && newWalkId != walkId) {
   walkId = newWalkId;
   print('[BG SERVICE] walkId ACTUAIZADO a: $walkId. Preparando Timer.');
   
   // Cancelar cualquier timer anterior antes de iniciar uno nuevo
   locationTimer?.cancel();
   
   // 2. INICIAR EL TIMER SOLO CUANDO TENEMOS EL walkId
   locationTimer = Timer.periodic(const Duration(seconds: 6), (timer) async {
    
    if (walkId == null) {
      timer.cancel();
      return;
    }

    // 3. Obtener Ubicación y Permisos (Solo checkear, no solicitar)
    if (!(await Geolocator.isLocationServiceEnabled())) {
     return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
     return;
    }

    try {
     final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
     );

     // 4. Actualizar Firebase
     final ref = FirebaseDatabase.instance.ref('walk_locations/$walkId');
     await ref.update({
      'lat': position.latitude,
      'lng': position.longitude,
     });

    } catch (e) {
     print('[BG SERVICE] ERROR: Fallo al obtener/enviar ubicación: $e');
    }
   });
  } else if (newWalkId != null && newWalkId == walkId) {
       print('[BG SERVICE] walkId REPETIDO. Saltando reinicio de Timer.');
    }
 });

 // 5. ESCUCHAR EVENTO DE DETENCIÓN
 service.on('stopService').listen((event) {
  print('[BG SERVICE] Evento stopService recibido.');
  locationTimer?.cancel();
  service.stopSelf();
  print('[BG SERVICE] Servicio de fondo detenido exitosamente.');
 });
}
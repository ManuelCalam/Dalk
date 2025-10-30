import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';

// Definir el entry point de la ejecución del servicio de fondo
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {

  try {
      await Firebase.initializeApp(); 
  } catch (e) {
      service.stopSelf();
      return;
  }

  Set<String> activeWalkIds = {}; 
  Timer? locationTimer;
  
  bool isTimerRunning = false;

  // Configuración de la Notificación de Aviso.
  if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
          title: "Dalk",
          content: "Servicio de rastreo en segundo plano activo.",
      );
  }

  // ESCUCHAR DATOS (Lista de walkIds)
  // El evento 'setTrackingIds' ahora recibe la lista completa de paseos a rastrear.
  service.on('setTrackingIds').listen((event) {
    final newWalkIds = event?['walkIds'] as List<dynamic>?;
    
    activeWalkIds = (newWalkIds?.cast<String>() ?? []).toSet(); 
    print('Background Service: IDs de rastreo actualizados: $activeWalkIds');

    // Si tenemos IDs y el Timer no está corriendo, lo iniciamos.
    if (activeWalkIds.isNotEmpty && !isTimerRunning) {
      isTimerRunning = true;
      
      // 2. INICIAR EL TIMER
      locationTimer = Timer.periodic(const Duration(seconds: 6), (timer) async {
          
          if (activeWalkIds.isEmpty) {
              timer.cancel();
              isTimerRunning = false;
              service.invoke('stopService'); 
              return;
          }

          // Obtener Ubicación y Permisos
          if (!(await Geolocator.isLocationServiceEnabled())) {
           print('Background Service: Servicio de ubicación desactivado.');
           return;
          }

          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
           print('Background Service: Permiso de ubicación denegado.');
           return;
          }

          try {
           final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
           );

           // Iterar sobre TODOS los walkIds activos
           for (final walkId in activeWalkIds) {
                // 4. Actualizar Firebase para CADA paseo
               final ref = FirebaseDatabase.instance.ref('walk_locations/$walkId');
               await ref.update({
                'lat': position.latitude,
                'lng': position.longitude,
               });
               print('Background Service: Ubicación enviada para walkId: $walkId');
           }

          } catch (e) {
           print('Background Service Error: Fallo al obtener/enviar ubicación: $e');
          }
      });
    } else if (activeWalkIds.isEmpty && locationTimer?.isActive == true) {
        // Si no hay IDs, cancelamos el timer y lo detenemos
        locationTimer?.cancel();
        isTimerRunning = false;
        service.invoke('stopService');
    }
  });

  // Escuchar el evento de detención
  service.on('stopService').listen((event) {
    locationTimer?.cancel();
    isTimerRunning = false;
    service.stopSelf();
  });
}

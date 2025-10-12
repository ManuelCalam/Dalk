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

  // ⭐ CAMBIO CLAVE: Usamos un Set para almacenar múltiples IDs de paseos a rastrear.
  Set<String> activeWalkIds = {}; 
  Timer? locationTimer;
  
  // Flag para saber si el timer ya está corriendo
  bool isTimerRunning = false;

  // ⭐ PASO CRÍTICO: Configuración de la Notificación Mínima.
  if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
          title: "Dalk Tracking Service",
          content: "Servicio de rastreo activo.",
      );
  }

  // 1. ESCUCHAR DATOS (Lista de walkIds)
  // El evento 'setTrackingIds' ahora recibe la lista completa de paseos a rastrear.
  service.on('setTrackingIds').listen((event) {
    final newWalkIds = event?['walkIds'] as List<dynamic>?;
    
    // Convertir a Set<String> para manejo eficiente
    activeWalkIds = (newWalkIds?.cast<String>() ?? []).toSet(); 
    print('Background Service: IDs de rastreo actualizados: $activeWalkIds');

    // Si tenemos IDs y el Timer no está corriendo, lo iniciamos.
    if (activeWalkIds.isNotEmpty && !isTimerRunning) {
      isTimerRunning = true;
      
      // 2. INICIAR EL TIMER
      locationTimer = Timer.periodic(const Duration(seconds: 6), (timer) async {
          
          if (activeWalkIds.isEmpty) {
              // Si la lista se vacía, cancelamos el timer y detenemos el servicio
              timer.cancel();
              isTimerRunning = false;
              service.invoke('stopService'); 
              return;
          }

          // 3. Obtener Ubicación y Permisos (Solo checkear, no solicitar)
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

           // ⭐ CAMBIO CLAVE: Iterar sobre TODOS los walkIds activos
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

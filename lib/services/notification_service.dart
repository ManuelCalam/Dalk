import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/nav/nav.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Plugin para notificaciones locales
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();

    // GlobalKeys
  GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  // Inicialización del servicio
  void initialize({
    required GlobalKey<ScaffoldMessengerState> scaffoldKey,
    required GlobalKey<NavigatorState> navKey,
  }) {
    scaffoldMessengerKey = scaffoldKey;
    // No necesitamos almacenar navKey porque usamos appNavigatorKey directamente
    print('🔧 NotificationService inicializado con las claves globales');
  }

  // Handler para notificaciones en background
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("📱 Notificación en background: ${message.notification?.title}");
  }

  // Inicializar notificaciones locales
  Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsiOS = 
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsiOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('🔔 NOTIFICACIÓN TOCADA! Payload: ${response.payload}');
        print('🔔 Action ID: ${response.actionId}');
        print('🔔 Input: ${response.input}');
        print('🔔 Timestamp: ${DateTime.now()}');
        handleNotificationTap(response.payload);
      },
    );
    
    print('✅ Notificaciones locales inicializadas');
  }

  // Función para mostrar notificación local
  Future<void> showLocalNotification({
    required String title, 
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = 
        AndroidNotificationDetails(
          'dalk_notifications',
          'Dalk Notifications',
          channelDescription: 'Notificaciones de paseos en Dalk',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          enableLights: true,
        );
    
    const DarwinNotificationDetails iOSPlatformChannelSpecifics = 
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
    
    print('🔔 Notificación local mostrada: $title');
  }

  // Función para obtener el tipo de usuario actual de la base de datos
  Future<String> _getCurrentUserType() async {
    try {
      print('🔔 Obteniendo tipo de usuario actual...');
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('❌ Usuario no autenticado');
        return 'guest';
      }
      
      print('🔔 Usuario ID: ${user.id}');
      
      final response = await Supabase.instance.client
          .from('users')
          .select('usertype')
          .eq('uuid', user.id)
          .maybeSingle();
      
      print('🔔 Respuesta de BD: $response');
      
      final userType = response?['usertype'] ?? 'guest';
      print('🔔 Tipo de usuario obtenido: $userType');
      
      return userType;
    } catch (e) {
      print('❌ Error obteniendo tipo de usuario: $e');
      return 'guest';
    }
  }

  // Función para obtener el tipo de usuario actual (versión síncrona)
  String getCurrentUserType() {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return 'guest';
      
      // Lógica temporal basada en el currentUserUid
      if (currentUserUid.isNotEmpty) {
        return 'owner'; // Default temporal
      }
      
      return 'guest';
    } catch (e) {
      print('❌ Error obteniendo tipo de usuario: $e');
      return 'guest';
    }
  }

  // Manejar el tap en notificaciones
  Future<void> handleNotificationTap(String? payload) async {
    print('🔔 INICIANDO handleNotificationTap...');
    print('🔔 Payload recibido: $payload');
    
    if (payload == null) {
      print('❌ Payload es null, abortando');
      return;
    }
    
    try {
      print('🔔 Intentando parsear JSON del payload...');
      final data = Map<String, dynamic>.from(json.decode(payload));
      print('🔔 JSON parseado exitosamente: $data');
      
      final String eventType = data['event_type'] ?? '';
      final String walkId = data['walk_id'] ?? '';
      final String userType = data['user_type'] ?? '';
      
      print('🔔 Event Type: $eventType');
      print('🔔 Walk ID: $walkId');
      print('🔔 User Type: $userType');
      
      // Si no tenemos userType en el payload, obtenerlo del usuario actual
      String currentUserType = userType;
      if (currentUserType.isEmpty) {
        print('🔔 User type vacío, obteniendo del usuario actual...');
        currentUserType = await _getCurrentUserType();
        print('🔔 User type obtenido: $currentUserType');
      }
      
      print('🔔 Procesando navegación para usuario: $currentUserType, evento: $eventType');
      
      // Navegar según el tipo de usuario y evento
      if (currentUserType.toLowerCase().contains('dueño') || currentUserType.toLowerCase().contains('owner')) {
        print('🔔 Navegando a pantalla de dueño...');
        await _navigateToOwnerWalks(eventType);
      } else if (currentUserType.toLowerCase().contains('paseador') || currentUserType.toLowerCase().contains('walker')) {
        print('🔔 Navegando a pantalla de paseador...');
        await _navigateToWalkerWalks(eventType);
      } else {
        print('❌ Tipo de usuario no reconocido: $currentUserType');
      }
      
    } catch (e, stackTrace) {
      print('❌ Error procesando notificación: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }

  // Navegar a la pantalla de paseos del dueño
  Future<void> _navigateToOwnerWalks(String eventType) async {
    print('🚀 INICIANDO navegación a paseos del dueño...');
    print('🚀 Event type: $eventType');
    
    try {
      final context = appNavigatorKey.currentContext;
      print('🔍 NavigatorKey: $appNavigatorKey');
      print('🔍 Context: $context');
      
      if (context == null) {
        print('❌ No se pudo obtener contexto válido');
        // Intentar obtener el contexto de otra manera
        await _tryAlternativeNavigation('/walksDogOwner', eventType);
        return;
      }
      
      print('🚀 Context obtenido, iniciando navegación...');
      
      // Usar GoRouter para navegar
      context.go('/walksDogOwner');
      print('✅ Navegación completada');
      
    } catch (e, stackTrace) {
      print('❌ Error durante navegación: $e');
      print('❌ Stack trace: $stackTrace');
      await _tryAlternativeNavigation('/walksDogOwner', eventType);
    }
  }

  // Navegar a la pantalla de paseos del paseador
  Future<void> _navigateToWalkerWalks(String eventType) async {
    print('🚀 INICIANDO navegación a paseos del paseador...');
    print('🚀 Event type: $eventType');
    
    try {
      final context = appNavigatorKey.currentContext;
      print('🔍 NavigatorKey: $appNavigatorKey');
      print('🔍 Context: $context');
      
      if (context == null) {
        print('❌ No se pudo obtener contexto válido');
        // Intentar obtener el contexto de otra manera
        await _tryAlternativeNavigation('/walksDogWalker', eventType);
        return;
      }
      
      print('🚀 Context obtenido, iniciando navegación...');
      
      // Usar GoRouter para navegar
      context.go('/walksDogWalker');
      print('✅ Navegación completada');
      
    } catch (e, stackTrace) {
      print('❌ Error durante navegación: $e');
      print('❌ Stack trace: $stackTrace');
      await _tryAlternativeNavigation('/walksDogWalker', eventType);
    }
  }

  // Método alternativo para navegación cuando el contexto no está disponible
  Future<void> _tryAlternativeNavigation(String route, String eventType) async {
    print('🔄 Intentando navegación alternativa...');
    
    // Esperar un poco y reintentar
    await Future.delayed(Duration(milliseconds: 500));
    
    final context = navigatorKey?.currentContext;
    if (context != null) {
      print('🚀 Context obtenido en segundo intento, navegando...');
      try {
        context.go(route);
        print('✅ Navegación alternativa completada');
        return;
      } catch (e) {
        print('❌ Error en navegación alternativa: $e');
      }
    }
    
    // Si aún no funciona, mostrar mensaje de fallback
    _showFallbackMessage('Navegar a $route (evento: $eventType)');
  }

  // Mostrar mensaje de fallback
  void _showFallbackMessage(String message) {
    print('🔄 Intentando fallback con scaffold messenger...');
    try {
      scaffoldMessengerKey?.currentState?.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (fallbackError) {
      print('❌ Fallback también falló: $fallbackError');
    }
  }

  // Actualizar token FCM
  Future<void> updateFcmToken(String userId) async {
    try {
      print('🔧 Solicitando token FCM para usuario: $userId');
      
      // En web, manejar errores del Service Worker
      String? token;
      try {
        token = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        print('⚠️ Error obteniendo token FCM (probablemente web sin HTTPS): $e');
        // En web sin HTTPS, no podemos obtener token FCM
        if (e.toString().contains('service worker') || e.toString().contains('MIME type')) {
          print('💡 Ejecutándose en web sin HTTPS - FCM no disponible');
          return;
        }
        rethrow;
      }
      
      print('🎯 Token FCM obtenido: ${token?.substring(0, 20)}...');
      print('🔍 Token FCM completo para pruebas: $token');
      
      if (token != null) {
        // Verificar si el usuario existe en la tabla users
        final userExists = await Supabase.instance.client
          .from('users')
          .select('uuid')
          .eq('uuid', userId)
          .maybeSingle();
        
        if (userExists != null) {
          // Usuario existe, actualizar token
          await Supabase.instance.client
            .from('users')
            .update({'fcm_token': token})
            .eq('uuid', userId);
          print('✅ Token FCM actualizado en base de datos para usuario: $userId');
        } else {
          print('⚠️ Usuario $userId no encontrado en tabla users, no se puede guardar token FCM');
          // Opcional: crear el usuario en la tabla users si no existe
        }
      } else {
        print('❌ No se pudo obtener token FCM');
      }
    } catch (e) {
      print('❌ Error actualizando token FCM: $e');
    }
  }

  // Solicitar permisos de notificación
  Future<void> requestNotificationPermission() async {
    print('📱 Solicitando permisos de notificación...');
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    print('📱 Estado del permiso: ${settings.authorizationStatus}');
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Permisos de notificación otorgados');
      
      // Verificar configuración adicional
      print('🔍 Alert habilitado: ${settings.alert}');
      print('🔍 Badge habilitado: ${settings.badge}');
      print('🔍 Sound habilitado: ${settings.sound}');
      
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('⚠️ Permisos de notificación provisionales');
    } else {
      print('❌ Permisos de notificación denegados');
    }
  }

  // Configurar Firebase Messaging
  void setupFirebaseMessaging() {
    // Handler para notificaciones cuando la app está en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Notificación recibida en foreground: ${message.notification?.title}');
      
      // Crear payload con información del usuario
      final payload = json.encode({
        'event_type': message.data['event_type'] ?? '',
        'walk_id': message.data['walk_id'] ?? '',
        'user_type': getCurrentUserType(), // Determinar el tipo de usuario actual
      });
      
      // Mostrar notificación push real del sistema cuando la app está en foreground
      if (message.notification != null) {
        showLocalNotification(
          title: message.notification!.title ?? 'Dalk',
          body: message.notification!.body ?? '',
          payload: payload,
        );
      }
    });

    // Handler para cuando el usuario toca una notificación y abre la app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 Usuario abrió la app desde notificación: ${message.notification?.title}');
      
      // Crear payload y manejar navegación
      final payload = json.encode({
        'event_type': message.data['event_type'] ?? '',
        'walk_id': message.data['walk_id'] ?? '',
        'user_type': getCurrentUserType(),
      });
      
      handleNotificationTap(payload);
    });

    // Verificar si la app se abrió desde una notificación
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('📱 App abierta desde notificación: ${message.notification?.title}');
        
        // Crear payload y manejar navegación
        final payload = json.encode({
          'event_type': message.data['event_type'] ?? '',
          'walk_id': message.data['walk_id'] ?? '',
          'user_type': getCurrentUserType(),
        });
        
        // Retrasar un poco la navegación para que la app se inicialice completamente
        Future.delayed(Duration(seconds: 1), () {
          handleNotificationTap(payload);
        });
      }
    });

    // Renovar token cuando sea necesario
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      print('🔄 Token FCM renovado: ${token.substring(0, 20)}...');
      final uid = currentUserUid;
      if (uid.isNotEmpty) {
        updateFcmToken(uid);
      }
    });
  }
}

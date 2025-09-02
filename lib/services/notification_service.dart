import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/nav/nav.dart';

@pragma('vm:entry-point')
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  void initialize({
    required GlobalKey<ScaffoldMessengerState> scaffoldKey,
    required GlobalKey<NavigatorState> navKey,
  }) {
    scaffoldMessengerKey = scaffoldKey;
    print('🔧 NotificationService inicializado');
    
    // ✅ CONFIGURAR TODO AQUÍ EN EL SERVICIO
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('📱 Configurando NotificationService...');
      
      try {
        await requestNotificationPermission();
        await initializeLocalNotifications();
        setupFirebaseMessaging(); // ✅ CONFIGURAR HANDLERS AQUÍ
        
        final uid = currentUserUid;
        if (uid.isNotEmpty) {
          await updateFcmToken(uid);
        }
        
        print('✅ NotificationService completamente configurado');
      } catch (e) {
        print('❌ Error configurando NotificationService: $e');
      }
    });
  }

  Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@drawable/ic_notification');
    
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
        print('🔔 ===== NOTIFICACIÓN LOCAL TOCADA =====');
        print('🔔 Payload: ${response.payload}');
        handleNotificationTap(response.payload);
      },
    );
    
    print('✅ Notificaciones locales inicializadas');
  }

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
          icon: '@drawable/ic_notification',
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

  // ✅ CONFIGURAR TODOS LOS HANDLERS DE FIREBASE AQUÍ
  void setupFirebaseMessaging() {
    print('🔧 Configurando Firebase Messaging handlers...');
    
    // Handler para notificaciones en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 ===== NOTIFICACIÓN EN FOREGROUND =====');
      print('📱 Title: ${message.notification?.title}');
      print('📱 Data: ${message.data}');
      
      // ✅ GUARDAR NOTIFICACIÓN EN BD DESDE EL CLIENTE TAMBIÉN (como respaldo)
      final uid = currentUserUid;
      if (uid.isNotEmpty && message.notification != null) {
        _saveNotificationToDatabase(
          recipientId: uid,
          title: message.notification!.title ?? '',
          body: message.notification!.body ?? '',
          eventType: message.data['event_type'] ?? 'notification',
          walkId: message.data['walk_id'] != null ? int.tryParse(message.data['walk_id']) : null,
        );
      }
      
      final payload = json.encode({
        'event_type': message.data['event_type'] ?? '',
        'walk_id': message.data['walk_id'] ?? '',
        'target_user_type': message.data['target_user_type'] ?? '',
        'target_user_id': message.data['target_user_id'] ?? '',
        'timestamp': message.data['timestamp'] ?? '',
      });
      
      if (message.notification != null) {
        showLocalNotification(
          title: message.notification!.title ?? 'Dalk',
          body: message.notification!.body ?? '',
          payload: payload,
        );
      }
    });

    // ✅ HANDLER PARA TAP EN NOTIFICACIÓN (PRINCIPAL) - CORREGIDO
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 ===== 🎉 NOTIFICACIÓN TOCADA - APP ABIERTA 🎉 =====');
      print('📱 Este log significa que el handler SÍ se está ejecutando');
      print('📱 Title: ${message.notification?.title}');
      print('📱 Body: ${message.notification?.body}');
      print('📱 Data completa: ${message.data}');
      print('📱 messageId: ${message.messageId}');
      print('📱 ========================================');
      
      // Procesar inmediatamente SIN PostFrameCallback
      handleFirebaseNotificationTap(message);
    });

    // ✅ VERIFICAR SI APP SE ABRIÓ DESDE NOTIFICACIÓN
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('📱 ===== 🚀 APP INICIADA DESDE NOTIFICACIÓN 🚀 =====');
        print('📱 Este log significa que la app se abrió desde una notificación');
        print('📱 Title: ${message.notification?.title}');
        print('📱 Data: ${message.data}');
        print('📱 messageId: ${message.messageId}');
        print('📱 ================================================');
        
        // Procesar con delay para inicialización
        Future.delayed(Duration(seconds: 2), () {
          print('📱 Procesando notificación inicial después de delay...');
          handleFirebaseNotificationTap(message);
        });
      } else {
        print('📱 No hay notificación inicial (app no se abrió desde notificación)');
      }
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      print('🔄 Token FCM renovado: ${token.substring(0, 20)}...');
      final uid = currentUserUid;
      if (uid.isNotEmpty) {
        updateFcmToken(uid);
      }
    });
    
    print('✅ Firebase handlers configurados completamente');
  }

  // ✅ NUEVA FUNCIÓN PARA GUARDAR NOTIFICACIONES EN BD DESDE EL CLIENTE - CORREGIDA
  Future<void> _saveNotificationToDatabase({
    required String recipientId,
    required String title,
    required String body,
    required String eventType,
    int? walkId,
  }) async {
    try {
      print('💾 Guardando notificación en BD para usuario: $recipientId');
      
      // ✅ CORREGIDO: Usar nombres de columnas correctos según el esquema
      await Supabase.instance.client
          .from('notifications')
          .insert([
            {
              'recipient_id': recipientId,
              'title': title,
              'body': body,
              'event_type': eventType,
              'walk_id': walkId,
              'is_read': false,
              'created_at': DateTime.now().toIso8601String(),
            },
          ]);

      print('✅ Notificación guardada en BD exitosamente');
    } catch (e) {
      print('❌ Excepción guardando notificación: $e');
    }
  }

  // ✅ MANEJAR TAP DE NOTIFICACIÓN FIREBASE - CORREGIDO
  void handleFirebaseNotificationTap(RemoteMessage message) {
    print('🎯 ===== PROCESANDO TAP DE FIREBASE =====');
    print('🎯 Iniciando procesamiento del tap...');
    
    final String eventType = message.data['event_type'] ?? '';
    final String walkId = message.data['walk_id'] ?? '';
    final String targetUserType = message.data['target_user_type'] ?? '';
    final String targetUserId = message.data['target_user_id'] ?? '';
    
    print('🎯 Event: $eventType');
    print('🎯 Walk: $walkId');
    print('🎯 UserType: $targetUserType');
    print('🎯 UserId: $targetUserId');
    
    if (targetUserType.isNotEmpty) {
      print('🎯 Tipo de usuario válido, iniciando navegación...');
      navigateBasedOnUserType(targetUserType, eventType);
    } else {
      print('❌ Target user type vacío');
      print('❌ Data disponible: ${message.data}');
      showFallbackMessage('Tipo de usuario no encontrado en notificación');
    }
  }

  // ✅ MANEJAR TAP DE NOTIFICACIÓN LOCAL
  Future<void> handleNotificationTap(String? payload) async {
    print('🔔 ===== PROCESANDO TAP DE NOTIFICACIÓN LOCAL =====');
    print('🔔 Payload recibido: $payload');
    
    if (payload == null || payload.isEmpty) {
      print('❌ Payload vacío o null');
      return;
    }
    
    try {
      final data = Map<String, dynamic>.from(json.decode(payload));
      print('🔔 JSON parseado: $data');
      
      final String eventType = data['event_type'] ?? '';
      final String walkId = data['walk_id'] ?? '';
      final String targetUserType = data['target_user_type'] ?? '';
      final String targetUserId = data['target_user_id'] ?? '';
      
      print('🔔 Datos extraídos:');
      print('🔔 - Event Type: $eventType');
      print('🔔 - Walk ID: $walkId');
      print('🔔 - Target User Type: $targetUserType');
      print('🔔 - Target User ID: $targetUserId');
      
      if (targetUserType.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigateBasedOnUserType(targetUserType, eventType);
        });
      } else {
        print('⚠️ Target user type vacío, usando fallback');
        showFallbackMessage('Tipo de usuario no encontrado');
      }
    } catch (e, stackTrace) {
      print('❌ Error procesando tap de notificación local: $e');
      print('❌ Stack trace: $stackTrace');
      showFallbackMessage('Error procesando notificación');
    }
  }

  // ✅ FUNCIÓN PRINCIPAL DE NAVEGACIÓN - CORREGIDA
  void navigateBasedOnUserType(String userType, String eventType) async {
    print('🚀 ===== INICIANDO NAVEGACIÓN =====');
    print('🚀 UserType: $userType');
    print('🚀 Event: $eventType');
    print('🚀 Timestamp: ${DateTime.now()}');
    print('🚀 appNavigatorKey disponible: ${appNavigatorKey != null}');
    
    String route = '';
    
    if (userType.toLowerCase() == 'owner') {
      route = '/walksDogOwner';
      print('🏠 Ruta determinada para dueño: $route');
    } else if (userType.toLowerCase() == 'walker') {
      route = '/walksDogWalker';
      print('🚶 Ruta determinada para paseador: $route');
    } else {
      print('❌ Tipo de usuario no reconocido: "$userType"');
      showFallbackMessage('Tipo de usuario desconocido: $userType');
      return;
    }
    
    print('🚀 Ruta final: $route');
    
    // ✅ INTENTAR NAVEGACIÓN INMEDIATA PRIMERO
    try {
      final context = appNavigatorKey.currentContext;
      print('🚀 Context inmediato: $context');
      print('🚀 Context mounted: ${context?.mounted}');
      
      if (context != null && context.mounted) {
        print('✅ Context disponible inmediatamente, navegando...');
        context.go(route);
        print('✅ ¡NAVEGACIÓN EXITOSA INMEDIATA!');
        return;
      } else {
        print('❌ Context no disponible inmediatamente, intentando con delays...');
      }
    } catch (e) {
      print('❌ Error en navegación inmediata: $e');
    }
    
    // ✅ INTENTAR CON REINTENTOS SI FALLA
    for (int i = 0; i < 3; i++) {
      final delay = Duration(milliseconds: 1000 * (i + 1));
      print('🔄 Esperando ${delay.inMilliseconds}ms antes del intento ${i + 1}...');
      await Future.delayed(delay);
      
      try {
        final context = appNavigatorKey.currentContext;
        print('🚀 Intento ${i + 1} - Context: $context');
        print('🚀 Intento ${i + 1} - Mounted: ${context?.mounted}');
        
        if (context != null && context.mounted) {
          context.go(route);
          print('✅ ¡NAVEGACIÓN EXITOSA EN INTENTO ${i + 1}!');
          showFallbackMessage('✅ Navegación exitosa a $userType (intento ${i + 1})');
          return;
        } else {
          print('❌ Context aún no disponible en intento ${i + 1}');
        }
      } catch (e) {
        print('❌ Error en intento ${i + 1}: $e');
      }
    }
    
    print('❌ TODOS LOS INTENTOS DE NAVEGACIÓN FALLARON');
    showFallbackMessage('❌ Error: No se pudo navegar automáticamente a $userType');
  }

  // ✅ MOSTRAR MENSAJE DE FALLBACK
  void showFallbackMessage(String message) {
    print('💬 ===== MOSTRANDO MENSAJE DE FALLBACK =====');
    print('💬 Mensaje: $message');
    
    try {
      final scaffoldState = scaffoldMessengerKey?.currentState;
      print('💬 ScaffoldMessengerState: $scaffoldState');
      
      if (scaffoldState != null) {
        scaffoldState.showSnackBar(
          SnackBar(
            content: Text('📱 $message'),
            duration: Duration(seconds: 6),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
        print('✅ SnackBar mostrado exitosamente');
      } else {
        print('❌ ScaffoldMessengerState no disponible');
      }
    } catch (e) {
      print('❌ Error mostrando SnackBar: $e');
    }
  }

  Future<void> updateFcmToken(String userId) async {
    try {
      print('🔧 Solicitando token FCM para usuario: $userId');
      
      String? token;
      try {
        token = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        print('⚠️ Error obteniendo token FCM: $e');
        if (e.toString().contains('service worker') || e.toString().contains('MIME type')) {
          print('💡 Ejecutándose en web sin HTTPS - FCM no disponible');
          return;
        }
        rethrow;
      }
      
      print('🎯 Token FCM obtenido: ${token?.substring(0, 20)}...');
      
      if (token != null) {
        final userExists = await Supabase.instance.client
          .from('users')
          .select('uuid')
          .eq('uuid', userId)
          .maybeSingle();
        
        if (userExists != null) {
          await Supabase.instance.client
            .from('users')
            .update({'fcm_token': token})
            .eq('uuid', userId);
          print('✅ Token FCM actualizado en base de datos para usuario: $userId');
        } else {
          print('⚠️ Usuario $userId no encontrado en tabla users');
        }
      } else {
        print('❌ No se pudo obtener token FCM');
      }
    } catch (e) {
      print('❌ Error actualizando token FCM: $e');
    }
  }

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
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('⚠️ Permisos de notificación provisionales');
    } else {
      print('❌ Permisos de notificación denegados');
    }
  }
}
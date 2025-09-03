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
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await requestNotificationPermission();
        await initializeLocalNotifications();
        setupFirebaseMessaging();
        
        final uid = currentUserUid;
        if (uid.isNotEmpty) {
          await updateFcmToken(uid);
        }
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
        handleNotificationTap(response.payload);
      },
    );
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
  }

  void setupFirebaseMessaging() {
    // Handler para notificaciones en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // ✅ REMOVIDO: Guardar desde cliente (ya se guarda desde servidor)
      // Solo mostrar notificación local
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

    // Handler para tap en notificación (app abierta)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleFirebaseNotificationTap(message);
    });

    // Verificar si app se abrió desde notificación
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        // ✅ OPTIMIZADO: Reducir delay de 2s a 500ms
        Future.delayed(Duration(milliseconds: 500), () {
          handleFirebaseNotificationTap(message);
        });
      }
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      final uid = currentUserUid;
      if (uid.isNotEmpty) {
        updateFcmToken(uid);
      }
    });
  }

  // ✅ REMOVIDA: _saveNotificationToDatabase (ya se guarda desde servidor)

  void handleFirebaseNotificationTap(RemoteMessage message) {
    final String targetUserType = message.data['target_user_type'] ?? '';
    final String eventType = message.data['event_type'] ?? '';
    
    if (targetUserType.isNotEmpty) {
      navigateBasedOnUserType(targetUserType, eventType);
    }
  }

  Future<void> handleNotificationTap(String? payload) async {
    if (payload == null || payload.isEmpty) return;
    
    try {
      final data = Map<String, dynamic>.from(json.decode(payload));
      final String targetUserType = data['target_user_type'] ?? '';
      final String eventType = data['event_type'] ?? '';
      
      if (targetUserType.isNotEmpty) {
        // ✅ OPTIMIZADO: Sin PostFrameCallback innecesario
        navigateBasedOnUserType(targetUserType, eventType);
      }
    } catch (e) {
      // Solo log en caso de error real
      print('❌ Error procesando notificación: $e');
    }
  }

  // ✅ OPTIMIZADO: Navegación simplificada sin reintentos innecesarios
  void navigateBasedOnUserType(String userType, String eventType) {
    String route = '';
    
    if (userType.toLowerCase() == 'owner') {
      route = '/walksDogOwner';
    } else if (userType.toLowerCase() == 'walker') {
      route = '/walksDogWalker';
    } else {
      return; // Sin route válido, terminar silenciosamente
    }
    
    // ✅ OPTIMIZADO: Intentar navegación directa, si falla usar un solo reintento
    final context = appNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      try {
        context.go(route);
        return; // Éxito inmediato
      } catch (e) {
        // Si falla, un solo reintento con delay mínimo
        Future.delayed(Duration(milliseconds: 100), () {
          final retryContext = appNavigatorKey.currentContext;
          if (retryContext != null && retryContext.mounted) {
            try {
              retryContext.go(route);
            } catch (e) {
              // Falló definitivamente, no hacer nada más
            }
          }
        });
      }
    }
  }

  // ✅ REMOVIDA: showFallbackMessage (innecesaria para UX)

  Future<void> updateFcmToken(String userId) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      
      if (token != null) {
        await Supabase.instance.client
          .from('users')
          .update({'fcm_token': token})
          .eq('uuid', userId);
      }
    } catch (e) {
      // Solo log en caso de error crítico
      if (!e.toString().contains('service worker') && !e.toString().contains('MIME type')) {
        print('❌ Error actualizando token FCM: $e');
      }
    }
  }

  Future<void> requestNotificationPermission() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      print('❌ Error solicitando permisos: $e');
    }
  }
}
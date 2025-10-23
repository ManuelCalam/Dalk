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
        // Error silencioso
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
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final payload = json.encode({
        'event_type': message.data['event_type'] ?? '',
        'walk_id': message.data['walk_id'] ?? '',
        'target_user_type': message.data['target_user_type'] ?? '',
        'target_user_id': message.data['target_user_id'] ?? '',
        'owner_id': message.data['owner_id'] ?? '',
        'walker_id': message.data['walker_id'] ?? '',
        'sender_id': message.data['sender_id'] ?? '',
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

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleFirebaseNotificationTap(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
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

  void handleFirebaseNotificationTap(RemoteMessage message) {
    final String targetUserType = message.data['target_user_type'] ?? '';
    final String eventType = message.data['event_type'] ?? '';
    
    // Redirigir a WalkPaymentWindow si es "Terminado"
    if (eventType == 'Terminado') {
      final String walkIdStr = message.data['walk_id'] ?? '';
      if (walkIdStr.isNotEmpty) {
        final int? walkId = int.tryParse(walkIdStr);
        if (walkId != null) {
          navigateToPaymentWindow(walkId, targetUserType);
          return;
        }
      }
    }
    
    if (eventType == 'chat_message') {
      // Navegación específica para chat con parámetros
      final String ownerId = message.data['owner_id'] ?? '';
      final String walkerId = message.data['walker_id'] ?? '';
      final String senderId = message.data['sender_id'] ?? '';
      
      if (ownerId.isNotEmpty && walkerId.isNotEmpty) {
        navigateToChatWidget(ownerId, walkerId, senderId);
        return;
      }
    }
    
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
      
      // Redirigir a WalkPaymentWindow si es "Terminado"
      if (eventType == 'Terminado') {
        final String walkIdStr = data['walk_id'] ?? '';
        if (walkIdStr.isNotEmpty) {
          final int? walkId = int.tryParse(walkIdStr);
          if (walkId != null) {
            navigateToPaymentWindow(walkId, targetUserType);
            return;
          }
        }
      }
      
      if (eventType == 'chat_message') {
        // Navegación específica para chat con parámetros
        final String ownerId = data['owner_id'] ?? '';
        final String walkerId = data['walker_id'] ?? '';
        final String senderId = data['sender_id'] ?? '';
        
        if (ownerId.isNotEmpty && walkerId.isNotEmpty) {
          navigateToChatWidget(ownerId, walkerId, senderId);
          return;
        }
      }
      
      if (targetUserType.isNotEmpty) {
        navigateBasedOnUserType(targetUserType, eventType);
      }
    } catch (e) {
      // Error silencioso
    }
  }

  // Navegar a WalkPaymentWindow usando GoRouter
  void navigateToPaymentWindow(int walkId, String userType) {
    final context = appNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      try {
        context.go('/walkPaymentWindow?walkId=$walkId&userType=$userType');
      } catch (e) {
        print('Error navegando a Payment: $e');
      }
    }
  }

  void navigateToChatWidget(String ownerId, String walkerId, String senderId) {
    final context = appNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      try {
        // Navegar al chat con query parameters
        final route = '/chat?ownerId=$ownerId&walkerId=$walkerId&senderId=$senderId';
        context.go(route);
        return;
      } catch (e) {
        // Si falla con parámetros, intentar sin senderId
        Future.delayed(Duration(milliseconds: 100), () {
          final retryContext = appNavigatorKey.currentContext;
          if (retryContext != null && retryContext.mounted) {
            try {
              final route = '/chat?ownerId=$ownerId&walkerId=$walkerId';
              retryContext.go(route);
            } catch (e) {
              // Falló definitivamente
            }
          }
        });
      }
    }
  }

  void navigateBasedOnUserType(String userType, String eventType) {
    String route = '';
    
    if (userType.toLowerCase() == 'owner') {
      route = '/walksDogOwner';
    } else if (userType.toLowerCase() == 'walker') {
      route = '/walksDogWalker';
    } else {
      return;
    }
    
    final context = appNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      try {
        context.go(route);
        return;
      } catch (e) {
        Future.delayed(Duration(milliseconds: 100), () {
          final retryContext = appNavigatorKey.currentContext;
          if (retryContext != null && retryContext.mounted) {
            try {
              retryContext.go(route);
            } catch (e) {
              // Falló definitivamente
            }
          }
        });
      }
    }
  }

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
      if (!e.toString().contains('service worker') && !e.toString().contains('MIME type')) {
        // Error crítico
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
      // Error silencioso
    }
  }
}
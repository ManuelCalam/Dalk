import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'auth/supabase_auth/supabase_user_provider.dart';
import 'auth/supabase_auth/auth_util.dart';


import '/backend/supabase/supabase.dart';
import 'backend/firebase/firebase_config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// GlobalKey para el ScaffoldMessenger
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// Plugin para notificaciones locales
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


// Handler para notificaciones en background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
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
  
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print('📱 Usuario tocó notificación local: ${response.payload}');
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
  
  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch.remainder(100000),
    title,
    body,
    platformChannelSpecifics,
    payload: payload,
  );
  
  print('🔔 Notificación local mostrada: $title');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await initFirebase();

  await SupaFlow.initialize();

  await FlutterFlowTheme.initialize();

  await dotenv.load(fileName: ".env"); 

  // Inicializar notificaciones locales
  await initializeLocalNotifications();

  // Configurar handler para notificaciones en background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();

  late Stream<BaseAuthUser> userStream;

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
    setupFirebaseMessaging(); // Agregar configuración de Firebase Messaging

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = dalkSupabaseUserStream()
  ..listen((user) {
    _appStateNotifier.update(user);
    // ACTUALIZA EL TOKEN FCM SIEMPRE QUE HAYA USUARIO LOGUEADO
    if (user.uid != null) {
      updateFcmToken(user.uid!);
    }
  });
    jwtTokenStream.listen((_) {});
    
    // Forzar actualización del token FCM si ya hay un usuario logueado
    Future.delayed(Duration(seconds: 2), () async {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        print('🔄 Verificando y actualizando token FCM para usuario actual');
      }
    });
    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Dalk',
      scaffoldMessengerKey: scaffoldMessengerKey,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
  
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

  void setupFirebaseMessaging() {
    // Handler para notificaciones cuando la app está en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Notificación recibida en foreground: ${message.notification?.title}');
      
      // Mostrar notificación push real del sistema cuando la app está en foreground
      if (message.notification != null) {
        showLocalNotification(
          title: message.notification!.title ?? 'Dalk',
          body: message.notification!.body ?? '',
          payload: message.data.toString(),
        );
      }
    });

    // Handler para cuando el usuario toca una notificación y abre la app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 Usuario abrió la app desde notificación: ${message.notification?.title}');
      // Aquí puedes navegar a una pantalla específica según el contenido de la notificación
    });

    // Verificar si la app se abrió desde una notificación
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('📱 App abierta desde notificación: ${message.notification?.title}');
        // Navegar a pantalla específica si es necesario
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
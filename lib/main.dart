import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import '/flutter_flow/nav/nav.dart';
import '/services/notification_service.dart';
import 'package:app_links/app_links.dart';

import '/dog_walker/home_dog_walker/home_dog_walker_widget.dart';

// GlobalKey para el ScaffoldMessenger 
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// ✅ HANDLER TOP-LEVEL SIMPLE (REQUERIDO)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("📱 Background notification: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await initFirebase();
  await FlutterFlowTheme.initialize();
  await dotenv.load(fileName: ".env"); 

  await Supabase.initialize(
    url: "${dotenv.env['SUPABASE_URL']}",
    anonKey: "${dotenv.env['SUPABASE_ANON_KEY']}",
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: true,      
      authFlowType: AuthFlowType.pkce, 
    ),
    realtimeClientOptions: const RealtimeClientOptions(
      eventsPerSecond: 10,
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  
  // ✅ APP LINKS - DECLARAR COMO VARIABLES DE INSTANCIA
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  
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
    
    // ✅ INICIALIZAR NOTIFICATIONSERVICE
    final notificationService = NotificationService();
    notificationService.initialize(
      scaffoldKey: scaffoldMessengerKey,
      navKey: appNavigatorKey,
    );
    
    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = dalkSupabaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
        // Actualizar token FCM cuando hay usuario logueado
        if (user.uid != null) {
          notificationService.updateFcmToken(user.uid!);
        }
      });
    jwtTokenStream.listen((_) {});
    
    // ✅ SPLASH SCREEN
    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );

    // ✅ INICIALIZAR APP_LINKS
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  /// ✅ INICIALIZAR DEEP LINKS (MÉTODO DE LA CLASE)
  Future<void> _initDeepLinks() async {
    // ✅ MANEJAR LINK INICIAL (app cerrada)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('🔗 Initial link: $initialUri');
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('❌ Error obteniendo initial link: $e');
    }

    // ✅ ESCUCHAR LINKS ENTRANTES (app abierta/background)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('🔗 Deep link recibido: $uri');
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('❌ Error en deep link: $err');
      },
    );
  }


void _handleDeepLink(Uri uri) {
  debugPrint('🔍 ========================================');
  debugPrint('🔍 PROCESANDO DEEP LINK');
  debugPrint('🔍 URI completo: $uri');
  debugPrint('🔍 Scheme: ${uri.scheme}');
  debugPrint('🔍 Host: ${uri.host}');
  debugPrint('🔍 Path: ${uri.path}');
  debugPrint('🔍 Query: ${uri.queryParameters}');
  debugPrint('🔍 ========================================');

  // ✅ CASO 1: dalkpaseos://redirect_verificamex?session_id=xxx&user_id=yyy
  if (uri.scheme == 'dalkpaseos' && uri.host == 'redirect_verificamex') {
    
    final sessionId = uri.queryParameters['session_id'] ?? '';
    final userId = uri.queryParameters['user_id'] ?? '';

    debugPrint('✅ Deep link de verificación detectado');
    debugPrint('  Session ID: $sessionId');
    debugPrint('  User ID: $userId');

    if (sessionId.isNotEmpty && userId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('📱 Navegando a redirect_verificamex...');
        
        _router.go(
          '/redirect_verificamex?session_id=$sessionId&user_id=$userId'
        );
      });
    } else {
      debugPrint('❌ Faltan parámetros obligatorios');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Error: Faltan datos de verificación'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
    return;
  }

  // ✅ CASO 2: Otros deep links (auth, changePassword)
  if (uri.host == 'auth' || uri.host == 'changePassword') {
    debugPrint('🔐 Deep link de autenticación detectado');
  }

  debugPrint('⚠️ Deep link no manejado: $uri');
}


  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

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
}
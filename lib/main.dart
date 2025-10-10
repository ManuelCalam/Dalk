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
  debugPrint('🔍 Procesando deep link:');
  debugPrint('  Scheme: ${uri.scheme}');
  debugPrint('  Host: ${uri.host}');
  debugPrint('  Path: ${uri.path}');
  debugPrint('  Query: ${uri.queryParameters}');

  // ✅ CASO 1: dalkpaseos://redirect/verificamex?session_id=xxx&user_id=yyy
  if (uri.host == 'redirect' && uri.path.startsWith('/verificamex')) {
    final sessionId = uri.queryParameters['session_id'] ?? '';
    final userId = uri.queryParameters['user_id'] ?? '';

    if (sessionId.isNotEmpty && userId.isNotEmpty) {
      debugPrint('✅ Navegando a redirect_verificamex');
      debugPrint('  Session ID: $sessionId');
      debugPrint('  User ID: $userId');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        // ✅ OPCIÓN 1: Usar context.go (si estás en un BuildContext)
        // context.go('/redirect_verificamex?session_id=$sessionId&user_id=$userId');
        
        // ✅ OPCIÓN 2: Usar _router.go directamente
        _router.go('/redirect_verificamex?session_id=$sessionId&user_id=$userId');
        
        // ✅ OPCIÓN 3: Usar pushNamed (recomendado para deep links)
        // _router.pushNamed(
        //   'redirect_verificamex',
        //   queryParameters: {
        //     'session_id': sessionId,
        //     'user_id': userId,
        //   },
        // );
      });
    } else {
      debugPrint('❌ Faltan parámetros: session_id o user_id');
    }
    return;
  }

  // ✅ CASO 2: dalkpaseos://verificamex/success (webhook exitoso)
  if (uri.host == 'verificamex' && uri.path == '/success') {
    debugPrint('✅ Verificación exitosa - navegando a HomeDogWalker');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _router.go('/homeDogWalker');
    });
    return;
  }

  // ✅ CASO 3: dalkpaseos://verificamex/failed (webhook fallido)
  if (uri.host == 'verificamex' && uri.path == '/failed') {
    debugPrint('❌ Verificación fallida - navegando a Login');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _router.go('/singInDogWalker');
    });
    return;
  }

  // ✅ CASO 4: Otros deep links (auth, changePassword, etc)
  if (uri.host == 'auth' || uri.host == 'changePassword') {
    debugPrint('🔐 Deep link de autenticación');
  }
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
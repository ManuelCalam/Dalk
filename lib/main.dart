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
  // ✅ ESPERAR A QUE LA APP ESTÉ COMPLETAMENTE INICIALIZADA
  await Future.delayed(const Duration(milliseconds: 500));
  
  // ✅ MANEJAR LINK INICIAL (app cerrada)
  try {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      debugPrint('🔗 Initial link detectado: $initialUri');
      
      // 🔑 VALIDAR QUE SEA UN DEEP LINK VÁLIDO
      if (initialUri.scheme == 'dalkpaseos' && 
          initialUri.host == 'redirect_verificamex') {
        
        // Solo procesar si tiene los parámetros necesarios
        final hasRequiredParams = 
            initialUri.queryParameters['session_id']?.isNotEmpty == true &&
            initialUri.queryParameters['user_id']?.isNotEmpty == true;
        
        if (hasRequiredParams) {
          debugPrint('✅ Deep link válido - procesando...');
          _handleDeepLink(initialUri);
        } else {
          debugPrint('⚠️ Deep link incompleto - ignorando');
        }
      } else {
        debugPrint('⚠️ Deep link no reconocido - ignorando');
      }
    } else {
      debugPrint('ℹ️ No hay initial link');
    }
  } catch (e) {
    debugPrint('❌ Error obteniendo initial link: $e');
  }

  // ✅ ESCUCHAR LINKS ENTRANTES (app abierta/background)
  _linkSubscription = _appLinks.uriLinkStream.listen(
    (uri) {
      debugPrint('🔗 Deep link entrante: $uri');
      _handleDeepLink(uri);
    },
    onError: (err) {
      debugPrint('❌ Error en deep link stream: $err');
    },
  );
}


// ✅ VERSIÓN CORREGIDA DE _handleDeepLink

Future<void> _handleDeepLink(Uri uri) async {
  debugPrint('🔍 ========================================');
  debugPrint('🔍 PROCESANDO DEEP LINK');
  debugPrint('🔍 URI completo: $uri');
  debugPrint('🔍 Scheme: ${uri.scheme}');
  debugPrint('🔍 Host: ${uri.host}');
  debugPrint('🔍 Path: ${uri.path}');
  debugPrint('🔍 Query: ${uri.queryParameters}');
  debugPrint('🔍 ========================================');

  // ✅ CASO 1: dalkpaseos://redirect_verificamex
  if (uri.scheme == 'dalkpaseos' && uri.host == 'redirect_verificamex') {
    
    final sessionId = uri.queryParameters['session_id'] ?? '';
    final userId = uri.queryParameters['user_id'] ?? '';
    final accessToken = uri.queryParameters['access_token'] ?? '';

    debugPrint('✅ Deep link de verificación detectado');
    debugPrint('  Session ID: $sessionId');
    debugPrint('  User ID: $userId');
    debugPrint('  Access Token presente: ${accessToken.isNotEmpty}');

    // 🔑 VALIDACIÓN 1: Verificar que vengan los parámetros obligatorios
    if (sessionId.isEmpty || userId.isEmpty) {
      debugPrint('❌ Faltan parámetros obligatorios - IGNORANDO deep link');
      return;
    }

    // 🔑 VALIDACIÓN 2: Verificar que haya un access_token
    if (accessToken.isEmpty) {
      debugPrint('⚠️ WARNING: Deep link sin access_token');
      debugPrint('⚠️ Intentando usar currentJwtToken...');
      
      final fallbackToken = currentJwtToken;
      
      if (fallbackToken.isEmpty) {
        debugPrint('❌ No hay token disponible - CANCELANDO navegación');
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Error: No se pudo restaurar la sesión de autenticación'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        });
        return;
      }
      
      debugPrint('✅ Usando fallback token');
    }

    // 🔑 VALIDACIÓN 3: Verificar que no estemos ya en la pantalla de verificación
    final currentRoute = getRoute();
    if (currentRoute.contains('redirect_verificamex')) {
      debugPrint('⚠️ Ya estamos en redirect_verificamex - IGNORANDO deep link duplicado');
      return;
    }

    // 🔑 VALIDACIÓN 4: Verificar que el usuario no esté ya verificado
    try {
      final userStatus = await SupaFlow.client
          .from('users')
          .select('verification_status')
          .eq('uuid', userId)
          .maybeSingle();

      if (userStatus != null) {
        final status = userStatus['verification_status'];
        
        if (status == 'verified') {
          debugPrint('✅ Usuario ya verificado - redirigiendo a home');
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _router.go('/homeDogWalker');
          });
          return;
        }
        
        if (status == 'rejected' || status == 'failed') {
          debugPrint('❌ Usuario con verificación fallida - redirigiendo a login');
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _router.go('/signIn');
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('⚠️ No se pudo verificar el status del usuario: $e');
      // Continuar con la navegación de todas formas
    }

    // ✅ TODO OK - NAVEGAR A PANTALLA DE VERIFICACIÓN
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('📱 ========================================');
      debugPrint('📱 NAVEGANDO A redirect_verificamex');
      debugPrint('📱 ========================================');
      
      _router.go(
        '/redirect_verificamex?session_id=$sessionId&user_id=$userId&access_token=$accessToken'
      );
    });
    
    return;
  }

  // ✅ CASO 2: Otros deep links (auth, changePassword)
  if (uri.host == 'auth' || uri.host == 'changePassword') {
    debugPrint('🔐 Deep link de autenticación detectado');
    // Aquí puedes manejar otros deep links
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
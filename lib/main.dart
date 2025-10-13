import 'dart:async';
import 'package:dalk/SubscriptionProvider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'auth/supabase_auth/supabase_user_provider.dart';
import 'auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import 'backend/firebase/firebase_config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/nav/nav.dart';
import '/services/notification_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:app_links/app_links.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

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

  Stripe.publishableKey = "pk_test_51S48646aB9DzvCSx9BqLEjUIcmpXvTuIU1elVEauQmFwOT2Ww3Sj2idqp148wcPsNWnbmtibCwCzgMjMfx02w08h00mNNCCfbB";  

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

  final _supabaseAuthStream = Supabase.instance.client.auth.onAuthStateChange;
  late Stream<BaseAuthUser> userStream;
  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    
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
        if (user.uid != null) {
          notificationService.updateFcmToken(user.uid!);
        }
      });
    jwtTokenStream.listen((_) {});
    
    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );

    _initDeepLinks();
  }

  /// ✅ INICIALIZAR DEEP LINKS
  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Manejar link inicial (app cerrada)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('🔗 Initial deep link: $initialUri');
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('❌ Error obteniendo initial link: $e');
    }

    // Escuchar links entrantes (app abierta/background)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('🔗 Deep link recibido: $uri');
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('❌ Error en deep link stream: $err');
      },
    );
  }

  /// ✅ MANEJAR DEEP LINK
  void _handleDeepLink(Uri uri) {
    debugPrint('🔍 Procesando deep link:');
    debugPrint('  URI completo: $uri');
    debugPrint('  Scheme: ${uri.scheme}');
    debugPrint('  Host: ${uri.host}');
    debugPrint('  Path: ${uri.path}');
    debugPrint('  Path segments: ${uri.pathSegments}');
    debugPrint('  Query params: ${uri.queryParameters}');

    // ✅ OPCIÓN A: Path parameters (RECOMENDADO)
    // dalkpaseos://verificamex/USER_ID/SESSION_ID
    if (uri.scheme == 'dalkpaseos' && uri.host == 'verificamex') {
      String userId = '';
      String sessionId = '';

      if (uri.pathSegments.length >= 1) {
        userId = uri.pathSegments[0];
        // sessionId es opcional ahora
        sessionId = uri.pathSegments.length >= 2 ? uri.pathSegments[1] : '';
      }

      if (userId.isNotEmpty) {  // ✅ Solo validar userId
        // Esperar a que el router esté listo
        WidgetsBinding.instance.addPostFrameCallback((_) {
          debugPrint('🚀 Navegando a /redirect_verificamex');
          _router.go('/redirect_verificamex?user_id=$userId${sessionId.isNotEmpty ? '&session_id=$sessionId' : ''}');
        });
      } else {
        debugPrint('❌ Faltan parámetros requeridos');
        debugPrint('   userId isEmpty: ${userId.isEmpty}');
        debugPrint('   sessionId isEmpty: ${sessionId.isEmpty}');
      }
    } else {
      debugPrint('⚠️ Deep link no reconocido: ${uri.scheme}://${uri.host}');
    }
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  // ✅ MÉTODOS REQUERIDOS POR FLUTTER_FLOW_UTIL
  String? getRoute() {
    return _router.routerDelegate.currentConfiguration.uri.toString();
  }

  List<String> getRouteStack() {
    return _router.routerDelegate.currentConfiguration.matches
        .map((match) => match.matchedLocation)
        .toList();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange, 
      builder: (context, snapshot) {
        final isAuthenticated = snapshot.data?.session?.user != null;

        Widget appRouter = MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Dalk',
          scaffoldMessengerKey: scaffoldMessengerKey,
          localizationsDelegates: const [
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

        if (isAuthenticated) {
          return ChangeNotifierProvider(
            create: (context) => SubscriptionProvider(Supabase.instance.client),
            child: appRouter,
          );
        } else {
          return appRouter;
        }
      }
    );
  }
}
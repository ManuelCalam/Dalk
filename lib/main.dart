import 'dart:async';

import 'package:dalk/SubscriptionProvider.dart';
import 'package:app_links/app_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/supabase_auth/supabase_user_provider.dart';
import 'auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import 'backend/firebase/firebase_config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'user_provider.dart';
import '/services/notification_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

// GlobalKey para el ScaffoldMessenger 
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
late final AppLinks _appLinks;

// HANDLER TOP-LEVEL SIMPLE (REQUERIDO)
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

  // Inicializar AppLinks
  _appLinks = AppLinks(); 

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;
  late Stream<BaseAuthUser> userStream;
  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  bool _isCacheLoaded = false;
  late StreamSubscription _linkSub;

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

  @override
  void initState() {
    super.initState();
    
    // Inicializar NotificationService
    final notificationService = NotificationService();
    notificationService.initialize(
      scaffoldKey: scaffoldMessengerKey,
      navKey: appNavigatorKey,
    );
    
    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);

    // ✅ LISTENER UNIFICADO DE DEEP LINKS
    _linkSub = _appLinks.uriLinkStream.listen((uri) async {
      if (uri == null) return;
      print('🔗 Deep Link recibido: $uri');

      // 🔍 CASO 1: Verificamex Redirect
      if (uri.host == 'redirect_verificamex') {
        final sessionId = uri.queryParameters['session_id'];
        final userId = uri.queryParameters['user_id'];

        if (userId != null) {
          print('✅ Redirigiendo a RedirectVerificamex con userId: $userId');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.pushNamed(
              'RedirectVerificamex',
              queryParameters: {
                'userId': userId,
                'sessionId': sessionId ?? '',
              },
            );
          });
        } else {
          print('❌ Error: userId es null en redirect_verificamex');
        }
        return; // Importante: salir después de manejar este caso
      }

      // 🔍 CASO 2: Recuperación de Contraseña (fragment)
      if (uri.fragment.isNotEmpty) {
        final params = Uri.splitQueryString(uri.fragment);
        final type = params['type'];

        if (type == 'recovery') {
          print('🔐 Redirigiendo a cambio de contraseña');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _router.go('/changePassword');
          });
        }
        return;
      }

      print('⚠️ Deep link no manejado: $uri');
    });
    
    // Listener de Autenticación
    userStream = dalkSupabaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
        
        if (user.uid != null && !_isCacheLoaded) {
          context.read<UserProvider>().loadUser();
          _isCacheLoaded = true;
        } else if (user.uid == null) {
          context.read<UserProvider>().clearUser();
          _isCacheLoaded = false;
        }

        if (user.uid != null) {
          notificationService.updateFcmToken(user.uid!);
        }
      });
      
    jwtTokenStream.listen((_) {});
    
    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );

    _handleInitialUri();
  }
  
  // Manejador del link inicial
  Future<void> _handleInitialUri() async {
    final uri = await _appLinks.getInitialLink();
    if (uri == null) return;
    print("🔗 URI inicial: $uri");

    // 🔍 CASO 1: Verificamex Redirect (cuando la app está cerrada)
    if (uri.host == 'redirect_verificamex') {
      final sessionId = uri.queryParameters['session_id'];
      final userId = uri.queryParameters['user_id'];

      if (userId != null) {
        print('✅ URI Inicial: Redirigiendo a RedirectVerificamex');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.pushNamed(
            'RedirectVerificamex',
            queryParameters: {
              'userId': userId,
              'sessionId': sessionId ?? '',
            },
          );
        });
      }
      return;
    }

    // 🔍 CASO 2: Recuperación de Contraseña
    if (uri.fragment.isNotEmpty) {
      final params = Uri.splitQueryString(uri.fragment);
      final type = params['type'];

      if (type == 'recovery') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print("🔐 Redirigiendo a cambio de contraseña desde URI inicial");
          _router.go('/changePassword');
        });
      }
    }
  }
  
  @override
  void dispose() {
    _linkSub.cancel();
    super.dispose();
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange, 
      builder: (context, snapshot) {
        final authState = snapshot.data;
        final event = authState?.event;
        final session = authState?.session;

        if (event == AuthChangeEvent.passwordRecovery) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _router.go('/changePassword');
          });
        }
        
        final isAuthenticated = session?.user != null;

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
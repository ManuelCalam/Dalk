import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:dalk/SubscriptionProvider.dart';
import 'package:dalk/auth/supabase_auth/supabase_user_provider.dart';
import 'package:dalk/user_provider.dart';
import 'package:dalk/services/notification_service.dart';
import 'package:dalk/auth/supabase_auth/auth_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/backend/firebase/firebase_config.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
late final AppLinks _appLinks;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background notification: ${message.notification?.title}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await dotenv.load(fileName: ".env");
  await initFirebase();
  await FlutterFlowTheme.initialize();

  // 🔗 Inicializar Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    realtimeClientOptions: const RealtimeClientOptions(eventsPerSecond: 10),
  );

  Stripe.publishableKey =
      "pk_test_51S48646aB9DzvCSx9BqLEjUIcmpXvTuIU1elVEauQmFwOT2Ww3Sj2idqp148wcPsNWnbmtibCwCzgMjMfx02w08h00mNNCCfbB";

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
  static _MyAppState of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;
  late final NotificationService _notificationService;
  late final GoRouter _router;
  late final StreamSubscription _linkSub;

  bool _isCacheLoaded = false;

  @override
  void initState() {
    super.initState();

    _notificationService = NotificationService();
    _notificationService.initialize(
      scaffoldKey: scaffoldMessengerKey,
      navKey: appNavigatorKey,
    );

    _router = createRouter();

    dalkSupabaseUserStream().listen((user) async {
      final userProvider = context.read<UserProvider>();

      if (user.uid != null && !_isCacheLoaded) {
        await userProvider.loadUser();
        _isCacheLoaded = true;

        // Actualizar token de notificación
        _notificationService.updateFcmToken(user.uid!);
      } else if (user.uid == null) {
        userProvider.clearUser();
        _isCacheLoaded = false;
      }
    });

    _linkSub = _appLinks.uriLinkStream.listen((uri) {
      if (uri == null) return;
      print("Deep link recibido: $uri");

      if (uri.fragment.isNotEmpty) {
        final params = Uri.splitQueryString(uri.fragment);
        if (params['type'] == 'recovery') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _router.go('/changePassword');
          });
        }
      }
    });

    _handleInitialUri();
  }

  Future<void> _handleInitialUri() async {
    final uri = await _appLinks.getInitialLink();
    if (uri == null) return;
    print("URI inicial: $uri");

    if (uri.fragment.isNotEmpty) {
      final params = Uri.splitQueryString(uri.fragment);
      if (params['type'] == 'recovery') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
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
        final event = snapshot.data?.event;
        final session = snapshot.data?.session;

        if (event == AuthChangeEvent.passwordRecovery) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _router.go('/changePassword');
          });
        }

        final isAuthenticated = session?.user != null;

        final appRouter = MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Dalk',
          scaffoldMessengerKey: scaffoldMessengerKey,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', '')],
          theme: ThemeData(brightness: Brightness.light, useMaterial3: false),
          darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: false),
          themeMode: _themeMode,
          routerConfig: _router,
        );

        if (isAuthenticated) {
          return ChangeNotifierProvider(
            create: (_) => SubscriptionProvider(Supabase.instance.client),
            child: appRouter,
          );
        }
        return appRouter;
      },
    );
  }
}
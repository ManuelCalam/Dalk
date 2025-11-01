import 'dart:async';
import 'package:dalk/NavBar/nav_bar_dog_owner.dart';
import 'package:dalk/NavBar/nav_bar_dog_walker.dart';
import 'package:dalk/RootNavWidget.dart';
import 'package:dalk/common/current_walk_empty_window/current_walk_empty_window_widget.dart';
import 'package:dalk/common/password_recovery/password_recovery_widget.dart';
import 'package:dalk/common/payment_methods/payment_methods_widget.dart';
import 'package:dalk/common/walk_payment_window/walk_payment_window_widget.dart';
import 'package:dalk/common/walks_record/walks_record_widget.dart';
import 'package:dalk/components/not_scheduled_walk_container/not_scheduled_walk_container_widget.dart';
import 'package:dalk/components/scheduled_walk_container/scheduled_walk_container_widget.dart';
import 'package:dalk/dog_owner/buy_tracker/buy_tracker_widget.dart';
import 'package:dalk/dog_owner/pet_update_profile/pet_update_profile_widget.dart';
import 'package:dalk/dog_owner/tracker_details/tracker_details_widget.dart';
import 'package:dalk/dog_walker/walks_dog_walker/walks_dog_walker_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/auth/base_auth_user_provider.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}


GoRouter createRouter(AppStateNotifier appStateNotifier) {
  // Helper para crear redirect similar a FFRoute.toRoute
  String? authRedirect(BuildContext context, GoRouterState state, bool requireAuth) {
    if (appStateNotifier.shouldRedirect) {
      final redirectLocation = appStateNotifier.getRedirectLocation();
      appStateNotifier.clearRedirectLocation();
      return redirectLocation;
    }
    if (requireAuth && !appStateNotifier.loggedIn) {
      appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
      return '/login';
    }
    return null;
  }

  Page<dynamic> pageBuilderFor(GoRouterState state, Widget child) {
    final context = appNavigatorKey.currentContext;
    if (context != null && appStateNotifier.loading) {
      return MaterialPage(
        key: state.pageKey,
        child: Center(
          child: SizedBox(
            width: 50.0,
            height: 50.0,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary,
              ),
            ),
          ),
        ),
      );
    }
    return MaterialPage(key: state.pageKey, child: child);
  }

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: appStateNotifier,
    navigatorKey: appNavigatorKey,
    redirect: (context, state) {
      final loggedIn = appStateNotifier.loggedIn;

      if (loggedIn && state.matchedLocation == LoginWidget.routePath) {
        return '/';
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        name: '_initialize',
        path: '/',
        pageBuilder: (context, state) => pageBuilderFor(
          state,
          RootNavWidget(
            initialPage: state.queryParams['initialPage'],
          ),
        ),
        redirect: (context, state) {
          // Mantengo comportamientos de auth si hace falta
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }
          return null;
        },
      ),

      GoRoute(
        name: LoginWidget.routeName,
        path: LoginWidget.routePath,
        pageBuilder: (context, state) => pageBuilderFor(state, const LoginWidget()),
        redirect: (context, state) => authRedirect(context, state, false),
      ),
      GoRoute(
        name: ChangePasswordWidget.routeName,
        path: ChangePasswordWidget.routePath,
        pageBuilder: (context, state) => pageBuilderFor(state, const ChangePasswordWidget()),
        redirect: (context, state) => authRedirect(context, state, false),
      ),
      GoRoute(
        name: SingInDogOwnerWidget.routeName,
        path: SingInDogOwnerWidget.routePath,
        pageBuilder: (context, state) => pageBuilderFor(state, const SingInDogOwnerWidget()),
        redirect: (context, state) => authRedirect(context, state, false),
      ),

      GoRoute(
        name: SingInDogOwnerWidget.routeName,
        path: SingInDogOwnerWidget.routePath,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return pageBuilderFor(state, SingInDogWalkerWidget(
            registerMethod: args['registerMethod']
          ));

        },
        redirect: (context, state) => authRedirect(context, state, false),
      ),

      GoRoute(
        name: SingInDogOwnerWidget.routeName,
        path: SingInDogOwnerWidget.routePath,
        pageBuilder: (context, state) => pageBuilderFor(state, const SignInWithGoogleDogOwnerWidget()),
        redirect: (context, state) => authRedirect(context, state, false),
      ),

      GoRoute(
        name: SingInDogOwnerWidget.routeName,
        path: SingInDogOwnerWidget.routePath,
        pageBuilder: (context, state) => pageBuilderFor(state, const ChooseUserTypeWidget()),
        redirect: (context, state) => authRedirect(context, state, false),
      ),

      GoRoute(
        name: SingInDogOwnerWidget.routeName,
        path: SingInDogOwnerWidget.routePath,
        pageBuilder: (context, state) => pageBuilderFor(state, const PasswordRecoveryWidget()),
        redirect: (context, state) => authRedirect(context, state, false),
      ),
      

      // ---------------------------
      // ShellRoute para OWNER (NavBarOwnerPage)
      // ---------------------------
      ShellRoute(
        builder: (context, state, child) {
          return NavBarOwnerPage(
            page: child,
            disableResizeToAvoidBottomInset: false,
          );
        },
        routes: [
          // Rutas comunes
          GoRoute(
            name: 'owner_notifications',
            path: 'owner/notifications', 
            pageBuilder: (context, state) => pageBuilderFor(state, const NotificationsWidget()),
            redirect: (context, state) => authRedirect(context, state, true),
          ),
          GoRoute(
            name: 'owner_chat',
            path: 'owner/chat', 
            pageBuilder: (context, state)  {
              final args = state.extra as Map<String, dynamic>? ?? {};
              return pageBuilderFor(state, 
                ChatWidget(
                  ownerId: args['ownerId'] ?? '',
                  walkerId: args['walkerId'] ?? '',
                  senderId: args['senderId'],
                  userName: args['userName'],
                  status: args['status'],                
                )
              );
            },
            redirect: (context, state) => authRedirect(context, state, true),
          ),
          // Rutas de nav
          GoRoute(
            name: 'owner_home',
            path: '/owner/home',
            pageBuilder: (context, state) => pageBuilderFor(state, const HomeDogOwnerWidget()),
            redirect: (context, state) => authRedirect(context, state, true),
          ),
          GoRoute(
            name: 'owner_currentWalk',
            path: '/owner/currentWalk',
            pageBuilder: (context, state) => pageBuilderFor(state, const CurrentWalkEmptyWindowWidget()),
            redirect: (context, state) => authRedirect(context, state, true),
          ),
          GoRoute(
            name: 'owner_petList',
            path: 'owner/petList', 
            pageBuilder: (context, state) => pageBuilderFor(state, const PetListWidget()),
            redirect: (context, state) => authRedirect(context, state,  true),
          ),
          GoRoute(
            name: 'owner_profile',
            path: 'owner/profile', 
            pageBuilder: (context, state) => pageBuilderFor(state, const DogOwnerProfileWidget()),
            redirect: (context, state) => authRedirect(context, state, true),
          ),

          // Rutas de agendar paseo
          GoRoute(
            name: 'owner_requestWalk',
            path: '/owner/requestWalk',
            pageBuilder: (context, state) {
              final args = state.extra as Map<String, dynamic>? ?? {};
              return pageBuilderFor(state,
                SetWalkScheduleWidget(
                  selectedAddress: args['selectedAddress'],
                  selectedPet: args['selectedPet'],
                ),
              );
            },
            redirect: (context, state) => authRedirect(context, state, true),
          ),
          GoRoute(
            name: 'owner_addAddress',
            path: 'owner/addAddress', 
            pageBuilder: (context, state)  {
              final args = state.extra as Map<String, dynamic>? ?? {};
              return pageBuilderFor(state, 
                AddAddressWidget(
                  originWindow: args['originWindow'],
                )
              );
            },
            redirect: (context, state) => authRedirect(context, state, true),
          ),
          GoRoute(
            name: 'owner_addPet',
            path: 'owner/addPet', 
            pageBuilder: (context, state) => pageBuilderFor(state, const AddPetWidget()),
            redirect: (context, state) => authRedirect(context, state, true),
          ),
          GoRoute(
            name: 'owner_premiumInfo',
            path: 'owner/premiumInfo', 
            pageBuilder: (context, state) => pageBuilderFor(state, const PremiumPlanInfoWidget()),
            redirect: (context, state) => authRedirect(context, state, true),
          ),
          GoRoute(
            name: 'owner_addPet',
            path: 'owner/addPet', 
            pageBuilder: (context, state) => pageBuilderFor(state, const AddPetWidget()),
            redirect: (context, state) => authRedirect(context, state, true),
          ),
          GoRoute(
            name: 'owner_findDogWalker',
            path: 'owner/findDogWalker',
            pageBuilder: (context, state) {
              final args = state.extra as Map<String, dynamic>? ?? {};
              return pageBuilderFor(
                state,
                FindDogWalkerWidget(
                  date: args['date'] as DateTime?,
                  time: args['time'] as DateTime?,
                  addressId: args['addressId'] as int?,
                  petId: args['petId'] as int?,
                  walkDuration: (args['walkDuration'] as int?) ?? 30,
                  instructions: args['instructions'] as String? ?? '',
                  recommendedWalkerUUIDs:
                      (args['recommendedWalkerUUIDs'] as List<String>?) ?? [],
                ),
              );
            },
            redirect: (context, state) => authRedirect(context, state, true),
          ),

          // Rutas de ventana de paseos
          GoRoute(
            name: 'owner_walksDogOwner',
            path: 'owner/walksDogOwner', 
            pageBuilder: (context, state) => pageBuilderFor(state, const WalksDogOwnerWidget()),
            redirect: (context, state) => authRedirect(context, state, true),
          ),
          GoRoute(
            name: 'owner_walksRecord',
            path: 'owner/walksRecord', 
            pageBuilder: (context, state)  {
              final args = state.extra as Map<String, dynamic>? ?? {};
              return pageBuilderFor(state, 
                WalksRecordWidget(
                  userType: args['userType'],
                )
              );
            },
            redirect: (context, state) => authRedirect(context, state, true),
          ),

          // Rutas de currentWalk
          GoRoute(
            name: 'owner_scheduledWalk',
            path: 'owner/scheduledWalk', 
            pageBuilder: (context, state)  {
              final args = state.extra as Map<String, dynamic>? ?? {};
              return pageBuilderFor(state, 
                ScheduledWalkContainerWidget(
                  walkId: args['walkId'],
                  userType: args['userType'],
                )
              );
            },
            redirect: (context, state) => authRedirect(context, state, true),
          ),          
          GoRoute(
            name: 'owner_notScheduledWalk',
            path: 'owner/notScheduledWalk', 
            pageBuilder: (context, state)  {
              final args = state.extra as Map<String, dynamic>? ?? {};
              return pageBuilderFor(state, 
                NotScheduledWalkContainerWidget(
                  userType: args['userType'],
                )
              );
            },
            redirect: (context, state) => authRedirect(context, state, true),
          ),          

          // Rutas de petList 
          GoRoute(
            name: 'owner_updatePet',
            path: 'pet/updatePet', 
            pageBuilder: (context, state) {
              final args = state.extra as Map<String, dynamic>? ?? {};
              return pageBuilderFor(
                state,
                PetUpdateProfileWidget(
                  petData: args['petData'],
                ),
              );
            },
            redirect: (context, state) => authRedirect(context, state, true),
          ),

          // Rutas de perfil de dueño
          GoRoute(
            name: 'owner_updateProfile',
            path: 'owner/updateProfile', 
            pageBuilder: (context, state) => pageBuilderFor(state, const DogOwnerUpdateProfileWidget()),
            redirect: (context, state) => authRedirect(context, state, true),
          ),
          GoRoute(
            name: 'owner_paymentMethods',
            path: 'owner/paymentMethods', 
            pageBuilder: (context, state) => pageBuilderFor(state, const PaymentMethodsWidget()),
            redirect: (context, state) => authRedirect(context, state, true),
          ),
          GoRoute(
            name: 'owner_trackerDetails',
            path: 'owner/trackerDetails', 
            pageBuilder: (context, state) => pageBuilderFor(state, const TrackerDetailsWidget()),
            redirect: (context, state) => authRedirect(context, state, true),
          ),
          GoRoute(
            name: 'owner_buyTracker',
            path: 'owner/buyTracker', 
            pageBuilder: (context, state) => pageBuilderFor(state, const BuyTrackerWidget()),
            redirect: (context, state) => authRedirect(context, state, true),
          ),

          // Ruta para pago de paseo
          GoRoute(
            name: 'owner_walkPayment',
            path: 'owner/paymentWalk', 
            pageBuilder: (context, state)  {
              final args = state.extra as Map<String, dynamic>? ?? {};
              return pageBuilderFor(state, 
                WalkPaymentWindowWidget(
                  walkId: args['walkId'],
                  userType: args['userType'],
                )
              );
            },
            redirect: (context, state) => authRedirect(context, state, true),
          ),          


        ],
      ),

      // ---------------------------
      // ShellRoute para WALKER (NavBarWalkerPage)
      // ---------------------------
      ShellRoute(
        builder: (context, state, child) {
          return NavBarWalkerPage(
            page: child,
            disableResizeToAvoidBottomInset: false,
          );
        },
        routes: [
          GoRoute(
            name: 'walker_home',
            path: '/walker/home',
            pageBuilder: (context, state) => pageBuilderFor(state, HomeDogWalkerWidget()),
            redirect: (context, state) => authRedirect(context, state, /*requireAuth*/ true),
          ),
          GoRoute(
            name: 'walker_current',
            path: '/walker/current',
            pageBuilder: (context, state) => pageBuilderFor(state, CurrentWalkWidget()),
            redirect: (context, state) => authRedirect(context, state, /*requireAuth*/ true),
          ),
          GoRoute(
            name: WalksDogWalkerWidget.routeName,
            path: WalksDogWalkerWidget.routePath,
            pageBuilder: (context, state) => pageBuilderFor(state, WalksDogWalkerWidget()),
            redirect: (context, state) => authRedirect(context, state, /*requireAuth*/ true),
          ),
          GoRoute(
            name: DogWalkerProfileWidget.routeName,
            path: DogWalkerProfileWidget.routePath,
            pageBuilder: (context, state) => pageBuilderFor(state, DogWalkerProfileWidget()),
            redirect: (context, state) => authRedirect(context, state, /*requireAuth*/ true),
          ),
          // Añade más rutas hijas de Walker aquí...
        ],
      ),

      // ---------------------------
      // Resto de rutas que necesites (si tienes muchas rutas definidas con FFRoute,
      // puedes mantener la lista FFRoute -> toRoute para las que no están dentro de shells).
      // ---------------------------
    ],
  );
}


GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      redirect: (context, state) {
        final loggedIn = appStateNotifier.loggedIn;

        // Si está logeado y trata de entrar, mándalo a raíz con navBar
        if (loggedIn && state.matchedLocation == LoginWidget.routePath) {
          return '/';
        }

        return null; // sin redirección
      },
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, params) => RootNavWidget(
            initialPage: params.getParam('initialPage', ParamType.String),
          ),
          requireAuth: true
        ),
        FFRoute(
          name: HomeDogOwnerWidget.routeName,
          path: HomeDogOwnerWidget.routePath,
          builder: (context, params) => HomeDogOwnerWidget(),
          requireAuth: true
        ),
        FFRoute(
          name: SetWalkScheduleWidget.routeName,
          path: SetWalkScheduleWidget.routePath,
          builder: (context, params) => SetWalkScheduleWidget(
            selectedAddress: params.getParam('selectedAddress',ParamType.int,),
            selectedPet: params.getParam('selectedPet', ParamType.int),
          ),
          requireAuth: true
        ),
        FFRoute(
          name: AddAddressWidget.routeName,
          path: AddAddressWidget.routePath,
          builder: (context, params) => AddAddressWidget (

            originWindow: params.getParam('originWindow', ParamType.String),

          ),
          requireAuth: true,
        ),

        FFRoute(
          name: FindDogWalkerWidget.routeName,
          path: FindDogWalkerWidget.routePath,
          builder: (context, params) => FindDogWalkerWidget(
            date: DateTime.tryParse(params.getParam('date', ParamType.String) ?? ''),
            time: DateTime.tryParse(params.getParam('time', ParamType.String) ?? ''),
            addressId: int.tryParse(params.getParam('addressId', ParamType.String) ?? ''),
            petId: int.tryParse(params.getParam('petId', ParamType.String) ?? ''),
            walkDuration: int.tryParse(params.getParam('walkDuration', ParamType.String) ?? '') ?? 30, 
            instructions: params.getParam('instructions', ParamType.String) ?? '',
            recommendedWalkerUUIDs: ((params.getParam('recommendedWalkerUUIDs', ParamType.String) ?? '')
            .split(',')
            .map((e) => e.trim())
            .where((e) => (e is String) && e.isNotEmpty)
            .toList())
            .cast<String>(), // fuerza a List<String>
          ),
          requireAuth: true
        ),
        FFRoute(
          name: AddPetWidget.routeName,
          path: AddPetWidget.routePath,
          builder: (context, params) => AddPetWidget(),
          requireAuth: true
        ),
        FFRoute(
          name: CurrentWalkWidget.routeName,
          path: CurrentWalkWidget.routePath,
          builder: (context, params) => CurrentWalkWidget(),
          requireAuth: true
        ),
        FFRoute(
          name: WalksDogOwnerWidget.routeName,
          path: WalksDogOwnerWidget.routePath,
          builder: (context, params) => WalksDogOwnerWidget(),
          requireAuth: true
        ),
        FFRoute(
          name: LoginWidget.routeName,
          path: LoginWidget.routePath,
          builder: (context, params) => LoginWidget(),
          requireAuth: false
        ),
        FFRoute(
          name: NotificationsWidget.routeName,
          path: NotificationsWidget.routePath,
          builder: (context, params) => NotificationsWidget(),
          requireAuth: true
        ),
        FFRoute(
          name: PetListWidget.routeName,
          path: PetListWidget.routePath,
          builder: (context, params) => PetListWidget(),
          requireAuth: true
        ),
        FFRoute(
          name: SignInWithGoogleDogOwnerWidget.routeName,
          path: SignInWithGoogleDogOwnerWidget.routePath,
          builder: (context, params) => SignInWithGoogleDogOwnerWidget(),
          requireAuth: false
        ),
        FFRoute(
          name: ChooseUserTypeWidget.routeName,
          path: ChooseUserTypeWidget.routePath,
          builder: (context, params) => ChooseUserTypeWidget(),
          requireAuth: false
        ),
        FFRoute(
          name: DogOwnerProfileWidget.routeName,
          path: DogOwnerProfileWidget.routePath,
          builder: (context, params) => DogOwnerProfileWidget(),
          requireAuth: true
        ),
        FFRoute(
          name: PremiumPlanInfoWidget.routeName,
          path: PremiumPlanInfoWidget.routePath,
          builder: (context, params) => PremiumPlanInfoWidget(),
          requireAuth: true
        ),
        FFRoute(
          name: SingInDogOwnerWidget.routeName,
          path: SingInDogOwnerWidget.routePath,
          builder: (context, params) => SingInDogOwnerWidget(),
          requireAuth: false
        ),
        FFRoute(
          name: SingInDogWalkerWidget.routeName,
          path: SingInDogWalkerWidget.routePath,
          builder: (context, params) => SingInDogWalkerWidget(registerMethod: params.getParam('registerMethod', ParamType.String) ?? ''),
          requireAuth: false
        ),
        FFRoute(
          name: DogWalkerServiceWidget.routeName,
          path: DogWalkerServiceWidget.routePath,
          builder: (context, params) => DogWalkerServiceWidget(),
          requireAuth: false
        ),
        FFRoute(
          name: ExceptionDayWidget.routeName,
          path: ExceptionDayWidget.routePath,
          builder: (context, params) => ExceptionDayWidget(),
          requireAuth: false
        ),
        FFRoute(
          name: DogOwnerUpdateProfileWidget.routeName,
          path: DogOwnerUpdateProfileWidget.routePath,
          builder: (context, params) => DogOwnerUpdateProfileWidget(),
          requireAuth: true
        ),
        FFRoute(
          name: ChangePasswordWidget.routeName,
          path: ChangePasswordWidget.routePath,
          builder: (context, params) => ChangePasswordWidget(),
          requireAuth: false
        ),
        FFRoute(
          name: HomeDogWalkerWidget.routeName,
          path: HomeDogWalkerWidget.routePath,
          builder: (context, params) => HomeDogWalkerWidget(),
          requireAuth: true
        ),
        FFRoute(
          name: WalksDogWalkerWidget.routeName,
          path: WalksDogWalkerWidget.routePath,
          builder: (context, params) => WalksDogWalkerWidget(),
          requireAuth: true
        ),
        FFRoute(
          name: DogWalkerProfileWidget.routeName,
          path: DogWalkerProfileWidget.routePath,
          builder: (context, params) => DogWalkerProfileWidget(),
          requireAuth: true
        ),
        FFRoute(
          name: ChatWidget.routeName,
          path: ChatWidget.routePath,
          builder: (context, params) => ChatWidget(
            ownerId: params.getParam('ownerId', ParamType.String) ?? '',
            walkerId: params.getParam('walkerId', ParamType.String) ?? '',
            senderId: params.getParam('senderId', ParamType.String),
            userName: params.getParam('userName', ParamType.String),
            status: params.getParam('status', ParamType.String),
          ),
        ),
          
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/login';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? Center(
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                )
              : page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}

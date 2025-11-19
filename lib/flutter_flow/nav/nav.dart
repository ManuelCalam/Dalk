import 'package:dalk/NavBar/nav_bar_dog_owner.dart';
import 'package:dalk/NavBar/nav_bar_dog_walker.dart';
import 'package:dalk/common/article_web_view/article_web_view.dart';
import 'package:dalk/common/current_walk_empty_window/current_walk_empty_window_widget.dart';
import 'package:dalk/common/frequent_questions/frequent_questions_widget.dart';
import 'package:dalk/common/password_recovery/password_recovery_widget.dart';
import 'package:dalk/common/payment_methods/payment_methods_widget.dart';
import 'package:dalk/common/walk_payment_window/walk_payment_window_widget.dart';
import 'package:dalk/common/walks_record/walks_record_widget.dart';
import 'package:dalk/components/not_scheduled_walk_container/not_scheduled_walk_container_widget.dart';
import 'package:dalk/components/scheduled_walk_container/scheduled_walk_container_widget.dart';
import 'package:dalk/dog_owner/add_tracker_to_account/add_tracker_to_account_widget.dart';
import 'package:dalk/dog_owner/buy_tracker/buy_tracker_widget.dart';
import 'package:dalk/dog_owner/owner_debt/owner_debt_widget.dart';
import 'package:dalk/dog_owner/pet_update_profile/pet_update_profile_widget.dart';
import 'package:dalk/dog_owner/tracker_details/tracker_details_widget.dart';
import 'package:dalk/dog_walker/walker_stripe_account/walker_stripe_account_widget.dart';
import 'package:dalk/dog_walker/walker_stripe_webview/walker_stripe_webview.dart';
import 'package:dalk/landing_pages/splash_screen.dart';
import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:dalk/landing_pages/VerificationCallbackPage/VerificationCallbackPage_widget.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter() {
  // Constructor de páginas sin manejo de loading
  Page<dynamic> pageBuilderFor(GoRouterState state, Widget child) {
    return MaterialPage(key: state.pageKey, child: child);
  }

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    navigatorKey: appNavigatorKey,
    routes: <RouteBase>[
      GoRoute(
        name: '_initialize',
        path: '/',
        pageBuilder: (context, state) => pageBuilderFor(
          state,
          const SplashScreen(),
        ),
      ),


      GoRoute(
        name: LoginWidget.routeName,
        path: '/login',
        parentNavigatorKey: appNavigatorKey,
        pageBuilder: (context, state) => pageBuilderFor(state, const LoginWidget()),
      ),
      GoRoute(
        name: ChangePasswordWidget.routeName,
        path: '/changePassword',
        pageBuilder: (context, state) => pageBuilderFor(state, const ChangePasswordWidget()),
      ),
      GoRoute(
        name: SingInDogOwnerWidget.routeName,
        path: SingInDogOwnerWidget.routePath,
        pageBuilder: (context, state) => pageBuilderFor(state, const SingInDogOwnerWidget()),
      ),

      GoRoute(
        name: SingInDogWalkerWidget.routeName,
        path: SingInDogWalkerWidget.routePath,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return pageBuilderFor(state, SingInDogWalkerWidget(
            registerMethod: args['registerMethod']
          ));

        },
      ),

      GoRoute(
        name: SignInWithGoogleDogOwnerWidget.routeName,
        path: SignInWithGoogleDogOwnerWidget.routePath,
        pageBuilder: (context, state) => pageBuilderFor(state, const SignInWithGoogleDogOwnerWidget()),
      ),

      GoRoute(
        name: ChooseUserTypeWidget.routeName,
        path: '/chooseUserType',
        pageBuilder: (context, state) => pageBuilderFor(state, const ChooseUserTypeWidget()),
      ),

      GoRoute(
        name: PasswordRecoveryWidget.routeName,
        path: PasswordRecoveryWidget.routePath,
        pageBuilder: (context, state) => pageBuilderFor(state, const PasswordRecoveryWidget()),
      ),

      GoRoute(
        name: 'WebView',
        path: '/WebView', 
        parentNavigatorKey: appNavigatorKey,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return pageBuilderFor(
            state,
            ArticleWebViewWidget(
              url: args['url'],
              title: args['title'],
            ),
          );
        },
      ),

      GoRoute(
        name: 'StripeWebView',
        path: '/StripeWebView', 
        parentNavigatorKey: appNavigatorKey,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return pageBuilderFor(
            state,
            WalkerStripeWebview(
              onboardingUrl: args['onboardingUrl'],
              returnUrl: args['returnUrl'],
              refreshUrl: args['refreshUrl'],
            ),
          );
        },
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
            path: '/owner/notifications', 
            pageBuilder: (context, state) => pageBuilderFor(state, const NotificationsWidget()),
          ),
          GoRoute(
            name: 'owner_chat',
            path: '/owner/chat', 
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
          ),
          // Rutas de nav
          GoRoute(
            name: 'owner_home',
            path: '/owner/home',
            pageBuilder: (context, state) => pageBuilderFor(state, const HomeDogOwnerWidget()),
          ),
          GoRoute(
            name: 'owner_currentWalk',
            path: '/owner/currentWalk',
            pageBuilder: (context, state) => pageBuilderFor(state, const CurrentWalkEmptyWindowWidget()),
          ),
          GoRoute(
            name: 'owner_petList',
            path: '/owner/petList', 
            pageBuilder: (context, state) => pageBuilderFor(state, const PetListWidget()),
          ),
          GoRoute(
            name: 'owner_profile',
            path: '/owner/profile', 
            pageBuilder: (context, state) => pageBuilderFor(state, const DogOwnerProfileWidget()),
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
          ),
          GoRoute(
            name: 'owner_addAddress',
            path: '/owner/addAddress', 
            pageBuilder: (context, state) => pageBuilderFor(state, const AddAddressWidget()),
          ),
          GoRoute(
            name: 'owner_premiumInfo',
            path: '/owner/premiumInfo', 
            pageBuilder: (context, state) => pageBuilderFor(state, const PremiumPlanInfoWidget()),
          ),
          GoRoute(
            name: 'owner_addPet',
            path: '/owner/addPet', 
            pageBuilder: (context, state) => pageBuilderFor(state, const AddPetWidget()),
          ),

          GoRoute(
            name: 'owner_findDogWalker',
            path: '/owner/findDogWalker',
            pageBuilder: (context, state) {
              final args = state.extra as Map<String, dynamic>? ?? {};

              final dateString = args['date'] as String?;
              final timeString = args['time'] as String?;
              final addressIdString = args['addressId'] as String?;
              final petIdString = args['petId'] as String?;
              final walkDurationString = args['walkDuration'] as String?;
              final instructions = args['instructions'] as String? ?? '';
              final recommendedWalkerUUIDsString = args['recommendedWalkerUUIDs'] as String? ?? '';

              return pageBuilderFor(
                state,
                FindDogWalkerWidget(
                  date: DateTime.tryParse(dateString ?? ''),
                  time: DateTime.tryParse(timeString ?? ''),
                  addressId: int.tryParse(addressIdString ?? ''),
                  petId: int.tryParse(petIdString ?? ''),
                  walkDuration: int.tryParse(walkDurationString ?? '') ?? 30,
                  instructions: instructions,
                  recommendedWalkerUUIDs: recommendedWalkerUUIDsString
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList()
                      .cast<String>(),
                ),
              );
            },
          ),

          // Rutas de ventana de paseos
          GoRoute(
            name: 'owner_walksList',
            path: '/owner/walksList', 
            pageBuilder: (context, state) => pageBuilderFor(state, const WalksDogOwnerWidget()),
          ),
          GoRoute(
            name: 'owner_walksRecord',
            path: '/owner/walksRecord', 
            pageBuilder: (context, state)  {
              final args = state.extra as Map<String, dynamic>? ?? {};
              return pageBuilderFor(state, 
                WalksRecordWidget(
                  userType: args['userType'],
                )
              );
            },
          ),

          // Rutas de currentWalk
          GoRoute(
            name: 'owner_scheduledWalk',
            path: '/owner/scheduledWalk', 
            pageBuilder: (context, state)  {
              final args = state.extra as Map<String, dynamic>? ?? {};
              return pageBuilderFor(state, 
                ScheduledWalkContainerWidget(
                  walkId: args['walkId'],
                  userType: args['userType'],
                  status: args['status'] ?? '',
                )
              );
            },
          ),          
          GoRoute(
            name: 'owner_notScheduledWalk',
            path: '/owner/notScheduledWalk', 
            pageBuilder: (context, state)  {
              final args = state.extra as Map<String, dynamic>? ?? {};
              return pageBuilderFor(state, 
                NotScheduledWalkContainerWidget(
                  userType: args['userType'],
                )
              );
            },
          ),          

          // Rutas de petList 
          GoRoute(
            name: 'owner_updatePet',
            path: '/owner/updatePet', 
            pageBuilder: (context, state) {
              final args = state.extra as Map<String, dynamic>? ?? {};
              return pageBuilderFor(
                state,
                PetUpdateProfileWidget(
                  petData: args['petData'],
                ),
              );
            },
          ),

          // Rutas de perfil de dueño
          GoRoute(
            name: 'owner_updateProfile',
            path: '/owner/updateProfile', 
            pageBuilder: (context, state) => pageBuilderFor(state, const DogOwnerUpdateProfileWidget()),
          ),
          GoRoute(
            name: 'owner_paymentMethods',
            path: '/owner/paymentMethods', 
            pageBuilder: (context, state) => pageBuilderFor(state, const PaymentMethodsWidget()),
          ),
          GoRoute(
            name: 'owner_trackerDetails',
            path: '/owner/trackerDetails', 
            pageBuilder: (context, state) => pageBuilderFor(state, const TrackerDetailsWidget()),
          ),
          GoRoute(
            name: 'owner_buyTracker',
            path: '/owner/buyTracker', 
            pageBuilder: (context, state) => pageBuilderFor(state, const BuyTrackerWidget()),
          ),
          GoRoute(
            name: 'owner_addTracker',
            path: '/owner/addTracker', 
            pageBuilder: (context, state) => pageBuilderFor(state, const AddTrackerToAccountWidget()),
          ),

          // Ruta para pago de paseo
          GoRoute(
            name: 'owner_walkPayment',
            path: '/owner/walkPayment', 
            pageBuilder: (context, state)  {
              final args = state.extra as Map<String, dynamic>? ?? {};
              return pageBuilderFor(state, 
                WalkPaymentWindowWidget(
                  walkId: args['walkId'],
                  userType: args['userType'],
                )
              );
            },
          ),    

          GoRoute(
            name: 'owner_ownerDebt',
            path: '/owner/ownerDebt', 
            pageBuilder: (context, state) => pageBuilderFor(state, const OwnerDebtWidget()),
          ),      

          GoRoute(
            name: 'owner_frequentQuestions',
            path: '/owner/frequentQuestions', 
            pageBuilder: (context, state) => pageBuilderFor(state, const FrequentQuestionsWidget()),
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
            name: 'walker_notifications',
            path: '/walker/notifications', 
            pageBuilder: (context, state) => pageBuilderFor(state, const NotificationsWidget()),
          ),
          GoRoute(
            name: 'walker_chat',
            path: '/walker/chat', 
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
          ),

          // Rutas del nav
          GoRoute(
            name: '/walker_home',
            path: '/walker/home',
            pageBuilder: (context, state) => pageBuilderFor(state, const HomeDogWalkerWidget()),
          ),
          // GoRoute(
          //   name: 'walker_currentWalk',
          //   path: '/walker/currentWalk',
          //   pageBuilder: (context, state) => pageBuilderFor(state, const CurrentWalkEmptyWindowWidget()),
          // ),
          GoRoute(
            name: 'walker_currentWalk',
            path: '/walker/currentWalk',
            pageBuilder: (context, state) => pageBuilderFor(
              state,
              CurrentWalkEmptyWindowWidget(key: UniqueKey()),
            ),
          ),

          GoRoute(
            name: 'walker_service',
            path: '/walker/service',
            pageBuilder: (context, state) => pageBuilderFor(state, const DogWalkerServiceWidget()),
          ),
          GoRoute(
            name: 'walker_profile',
            path: '/walker/profile',
            pageBuilder: (context, state) => pageBuilderFor(state, const DogWalkerProfileWidget()),
          ),

          // Rutas de ventana de paseos
          GoRoute(
            name: 'walker_walksList',
            path: '/walker/walksList',
            pageBuilder: (context, state) => pageBuilderFor(state, const WalksDogWalkerWidget()),
          ),
          GoRoute(
            name: 'walker_walksRecord',
            path: '/walker/walksRecord', 
            pageBuilder: (context, state)  {
              final args = state.extra as Map<String, dynamic>? ?? {};
              return pageBuilderFor(state, 
                WalksRecordWidget(
                  userType: args['userType'],
                )
              );
            },
          ),

          // Día excepional
          GoRoute(
            name: 'walker_exceptionalDay',
            path: '/walker/exceptionalDay',
            pageBuilder: (context, state) => pageBuilderFor(state, const ExceptionDayWidget()),
          ),

          // Rutas de currentWalk
          GoRoute(
            name: 'walker_scheduledWalk',
            path: '/walker/scheduledWalk', 
            pageBuilder: (context, state)  {
              final args = state.extra as Map<String, dynamic>? ?? {};
              return pageBuilderFor(state, 
                ScheduledWalkContainerWidget(
                  walkId: args['walkId'],
                  userType: args['userType'],
                  status: args['status'] ?? '',
                )
              );
            },
          ),          
          GoRoute(
            name: 'walker_notScheduledWalk',
            path: '/walker/notScheduledWalk', 
            pageBuilder: (context, state)  {
              final args = state.extra as Map<String, dynamic>? ?? {};
              return pageBuilderFor(state, 
                NotScheduledWalkContainerWidget(
                  userType: args['userType'],
                )
              );
            },
          ),  

          // Rutas de perfil de paseador
          GoRoute(
            name: 'walker_updateProfile',
            path: '/walker/updateProfile', 
            pageBuilder: (context, state) => pageBuilderFor(state, const DogOwnerUpdateProfileWidget()), //La ruta si es correcta
          ),
          GoRoute(
            name: 'walker_paymentMethods',
            path: '/walker/paymentMethods', 
            pageBuilder: (context, state) => pageBuilderFor(state, const PaymentMethodsWidget()),
          ),
          GoRoute(
            name: 'walker_getPaid',
            path: '/walker/getPaid', 
            pageBuilder: (context, state) => pageBuilderFor(state, const WalkerStripeAccountWidget()),
          ),
          GoRoute(
            name: 'walker_frequentQuestions',
            path: '/walker/frequentQuestions', 
            pageBuilder: (context, state) => pageBuilderFor(state, const FrequentQuestionsWidget()),
          ),
          
        ],
      ),

      // RUTA DE VERIFICACIÓN FUERA DE LOS SHELLROUTES
      GoRoute(
        path: '/verification-callback',
        name: 'verificationCallback',
        parentNavigatorKey: appNavigatorKey,  // ✅ USAR NAVEGADOR PRINCIPAL
        pageBuilder: (context, state) {
          final userId = state.uri.queryParameters['user_id'] ?? '';
          final sessionId = state.uri.queryParameters['session_id'] ?? '';
          
          debugPrint('🔗 Navegando a VerificationCallbackPage');
          debugPrint('   User ID: $userId');
          debugPrint('   Session ID: $sessionId');
          
          return pageBuilderFor(
            state,
            VerificationCallbackWidget(
              userId: userId,
              sessionId: sessionId,
            ),
          );
        },
      ),
    ],
  );
}



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
  }) {
    if (!mounted) return;
    goNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
  }) {
    if (!mounted) return;
    pushNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  void safePop() {
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}


// extension _GoRouterStateExtensions on GoRouterState {
//   Map<String, dynamic> get extraMap =>
//       extra != null ? extra as Map<String, dynamic> : {};
//   Map<String, dynamic> get allParams => <String, dynamic>{}
//     ..addAll(pathParameters)
//     ..addAll(uri.queryParameters)
//     ..addAll(extraMap);
//   TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
//       ? extraMap[kTransitionInfoKey] as TransitionInfo
//       : TransitionInfo.appDefault();
// }

// class FFParameters {
//   FFParameters(this.state, [this.asyncParams = const {}]);

//   final GoRouterState state;
//   final Map<String, Future<dynamic> Function(String)> asyncParams;

//   Map<String, dynamic> futureParamValues = {};

//   // Parameters are empty if the params map is empty or if the only parameter
//   // present is the special extra parameter reserved for the transition info.
//   bool get isEmpty =>
//       state.allParams.isEmpty ||
//       (state.allParams.length == 1 &&
//           state.extraMap.containsKey(kTransitionInfoKey));
//   bool isAsyncParam(MapEntry<String, dynamic> param) =>
//       asyncParams.containsKey(param.key) && param.value is String;
//   bool get hasFutures => state.allParams.entries.any(isAsyncParam);
//   Future<bool> completeFutures() => Future.wait(
//         state.allParams.entries.where(isAsyncParam).map(
//           (param) async {
//             final doc = await asyncParams[param.key]!(param.value)
//                 .onError((_, __) => null);
//             if (doc != null) {
//               futureParamValues[param.key] = doc;
//               return true;
//             }
//             return false;
//           },
//         ),
//       ).onError((_, __) => [false]).then((v) => v.every((e) => e));

//   dynamic getParam<T>(
//     String paramName,
//     ParamType type, {
//     bool isList = false,
//   }) {
//     if (futureParamValues.containsKey(paramName)) {
//       return futureParamValues[paramName];
//     }
//     if (!state.allParams.containsKey(paramName)) {
//       return null;
//     }
//     final param = state.allParams[paramName];
//     // Got parameter from `extras`, so just directly return it.
//     if (param is! String) {
//       return param;
//     }
//     // Return serialized value.
//     return deserializeParam<T>(
//       param,
//       type,
//       isList,
//     );
//   }
// }

// class FFRoute {
//   const FFRoute({
//     required this.name,
//     required this.path,
//     required this.builder,
//     this.requireAuth = false,
//     this.asyncParams = const {},
//     this.routes = const [],
//   });

//   final String name;
//   final String path;
//   final bool requireAuth;
//   final Map<String, Future<dynamic> Function(String)> asyncParams;
//   final Widget Function(BuildContext, FFParameters) builder;
//   final List<GoRoute> routes;

//   GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
//         name: name,
//         path: path,
//         redirect: (context, state) {
//           if (appStateNotifier.shouldRedirect) {
//             final redirectLocation = appStateNotifier.getRedirectLocation();
//             appStateNotifier.clearRedirectLocation();
//             return redirectLocation;
//           }

//           if (requireAuth && !appStateNotifier.loggedIn) {
//             appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
//             return '/login';
//           }
//           return null;
//         },
//         pageBuilder: (context, state) {
//           fixStatusBarOniOS16AndBelow(context);
//           final ffParams = FFParameters(state, asyncParams);
//           final page = ffParams.hasFutures
//               ? FutureBuilder(
//                   future: ffParams.completeFutures(),
//                   builder: (context, _) => builder(context, ffParams),
//                 )
//               : builder(context, ffParams);
//           final child = appStateNotifier.loading
//               ? Center(
//                   child: SizedBox(
//                     width: 50.0,
//                     height: 50.0,
//                     child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         FlutterFlowTheme.of(context).primary,
//                       ),
//                     ),
//                   ),
//                 )
//               : page;

//           final transitionInfo = state.transitionInfo;
//           return transitionInfo.hasTransition
//               ? CustomTransitionPage(
//                   key: state.pageKey,
//                   child: child,
//                   transitionDuration: transitionInfo.duration,
//                   transitionsBuilder:
//                       (context, animation, secondaryAnimation, child) =>
//                           PageTransition(
//                     type: transitionInfo.transitionType,
//                     duration: transitionInfo.duration,
//                     reverseDuration: transitionInfo.duration,
//                     alignment: transitionInfo.alignment,
//                     child: child,
//                   ).buildTransitions(
//                     context,
//                     animation,
//                     secondaryAnimation,
//                     child,
//                   ),
//                 )
//               : MaterialPage(key: state.pageKey, child: child);
//         },
//         routes: routes,
//       );
// }

// class TransitionInfo {
//   const TransitionInfo({
//     required this.hasTransition,
//     this.transitionType = PageTransitionType.fade,
//     this.duration = const Duration(milliseconds: 300),
//     this.alignment,
//   });

//   final bool hasTransition;
//   final PageTransitionType transitionType;
//   final Duration duration;
//   final Alignment? alignment;

//   static TransitionInfo appDefault() => const TransitionInfo(hasTransition: false);
// }

// class RootPageContext {
//   const RootPageContext(this.isRootPage, [this.errorRoute]);
//   final bool isRootPage;
//   final String? errorRoute;

//   static bool isInactiveRootPage(BuildContext context) {
//     final rootPageContext = context.read<RootPageContext?>();
//     final isRootPage = rootPageContext?.isRootPage ?? false;
//     final location = GoRouterState.of(context).uri.toString();
//     return isRootPage &&
//         location != '/' &&
//         location != rootPageContext?.errorRoute;
//   }

//   static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
//         value: RootPageContext(true, errorRoute),
//         child: child,
//       );
// }

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}

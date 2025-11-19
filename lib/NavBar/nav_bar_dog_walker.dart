import 'dart:async';
import 'package:dalk/backend/supabase/supabase.dart';
import 'package:dalk/components/pop_up_confirm_dialog/pop_up_confirm_dialog_widget.dart';
import 'package:dalk/components/scheduled_walk_container/scheduled_walk_container_widget.dart';
import 'package:dalk/dog_walker/walker_monitor.dart';
import 'package:flutter/material.dart';
import 'package:dalk/flutter_flow/flutter_flow_theme.dart';
import 'package:dalk/flutter_flow/flutter_flow_util.dart';
import 'package:go_router/go_router.dart';

class NavBarWalkerPage extends StatefulWidget {
  NavBarWalkerPage({
    Key? key,
    this.initialPage,
    this.page,
    this.disableResizeToAvoidBottomInset = false,
  }) : super(key: key);

  final String? initialPage;
  final Widget? page;
  final bool disableResizeToAvoidBottomInset;

  @override
  _NavBarWalkerPageState createState() => _NavBarWalkerPageState();
}

class _NavBarWalkerPageState extends State<NavBarWalkerPage> {
  late WalkerMonitor _walkerMonitor;
  StreamSubscription<String>? _cancelledByOwnerSubscription;

  @override
  void initState() {
    super.initState();

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _walkerMonitor = WalkerMonitor(userId: userId);
      _walkerMonitor.initialize();

      // Escuchar cuando el dueño cancele
      _cancelledByOwnerSubscription =
          _walkerMonitor.walkCancelledByOwnerUpdates.listen((walkId) async {
        print('NAVBAR (WALKER): Paseo $walkId cancelado por el dueño.');

        if (!mounted) return;
        await Future.delayed(Duration.zero);
        if (!mounted) return;

        context.go('/walker/currentWalk');
        // Mostrar pop-up de notificación
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: PopUpConfirmDialogWidget(
                title: "Paseo cancelado",
                message: "El paseo fue cancelado. El pago se hará efectivo cuando el dueño lo cubra.",
                confirmText: "Cerrar",
                cancelText: "",
                confirmColor: FlutterFlowTheme.of(context).error,
                cancelColor: FlutterFlowTheme.of(context).error,
                icon: Icons.cancel,
                iconColor: FlutterFlowTheme.of(context).error,
                onConfirm: () {
                  context.pop();
                },
                onCancel: () {
                  context.pop();
                },
              ),
            );
          },
        );
        context.go('/walker/currentWalk');

      });
    }
  }

  @override
  void dispose() {
    _cancelledByOwnerSubscription?.cancel();
    _walkerMonitor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const navPaths = <String>[
      '/walker/home',
      '/walker/currentWalk',
      '/walker/service',
      '/walker/profile',
    ];

    final currentLocation = GoRouterState.of(context).uri.toString();

    int currentIndex = navPaths.indexOf(currentLocation);

    if (currentIndex == -1) {
      for (var i = 0; i < navPaths.length; i++) {
        if (currentLocation.startsWith(navPaths[i])) {
          currentIndex = i;
          break;
        }
      }
    }

    final safeIndex = currentIndex != -1 ? currentIndex : 0;

    return Scaffold(
      resizeToAvoidBottomInset: !widget.disableResizeToAvoidBottomInset,
      body: widget.page!,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: (i) {
          final newPath = navPaths[i];
          context.go(newPath);
        },
        backgroundColor: FlutterFlowTheme.of(context).tertiary,
        selectedItemColor: FlutterFlowTheme.of(context).primary,
        unselectedItemColor: const Color(0xFFB1B1B1),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on, size: 30), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.perm_contact_cal, size: 30), label: 'Agenda'),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: 30), label: 'Perfil'),
        ],
      ),
    );
  }
}

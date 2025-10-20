import 'dart:async';
import 'package:dalk/backend/supabase/supabase.dart';
import 'package:dalk/common/walk_payment_window/walk_payment_window_widget.dart';
import 'package:dalk/components/pop_up_current_walk_options/pop_up_current_walk_options_widget.dart';
import 'package:dalk/dog_owner/walk_monitor.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dalk/common/current_walk_empty_window/current_walk_empty_window_widget.dart';
import 'package:dalk/dog_owner/dog_owner_profile/dog_owner_profile_widget.dart';
import 'package:dalk/dog_owner/home_dog_owner/home_dog_owner_widget.dart';
import 'package:dalk/dog_owner/pet_list/pet_list_widget.dart';
import 'package:dalk/flutter_flow/flutter_flow_theme.dart';
import 'package:dalk/flutter_flow/flutter_flow_util.dart';

class NavBarOwnerPage extends StatefulWidget {
  NavBarOwnerPage({
    Key? key,
    this.initialPage,
    this.page,
    this.disableResizeToAvoidBottomInset = false,
  }) : super(key: key);

  final String? initialPage;
  final Widget? page;
  final bool disableResizeToAvoidBottomInset;

  @override
  _NavBarPageState createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarOwnerPage> {
  String _currentPageName = 'homeDogOwner';
  late Widget? _currentPage;

  late WalkMonitor _walkMonitor;
  StreamSubscription<String>? _walkStartSubscription;
  StreamSubscription<String>? _walkFinishSubscription;

  @override
  void initState() {
    super.initState();

    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _walkMonitor = WalkMonitor(userId: userId);
      _walkMonitor.initialize();

      // Escucha paseos "En curso"
      _walkStartSubscription = _walkMonitor.walkStartedUpdates.listen((walkId) async {
        print('NAVBAR: Paseo $walkId cambió a En curso.');

        if (!mounted) return;
        await Future.delayed(Duration.zero);
        if (!mounted) return;

        showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          enableDrag: false,
          context: context,
          builder: (context) {
            return Padding(
              padding: MediaQuery.viewInsetsOf(context),
              child: const PopUpCurrentWalkOptionsWidget(),
            );
          },
        );
      });

    // Escucha paseos "Finalizado"
    _walkFinishSubscription = _walkMonitor.walkFinishedUpdates.listen((walkId) async {
      print('NAVBAR: Paseo $walkId cambió a Finalizado.');

      if (!mounted) return;
      await Future.delayed(Duration.zero);
      if (!mounted) return;

      // Navegar a la pantalla de pago
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WalkPaymentWindowWidget(
            walkId: int.tryParse(walkId) ?? 0,
            userType: 'Dueño',
          ),
        ),
      );

      // Actualizar current_walk_id a null
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId != null) {
        try {
          await SupaFlow.client
              .from('users')
              .update({'current_walk_id': null})
              .eq('uuid', currentUserId)
              .maybeSingle();
          print('current_walk_id actualizado a null');
        } catch (e) {
          print("Error al actualizar current_walk_id en Supabase: $e");
        }
      }
    });

    }
  }

  @override
  void dispose() {
    _walkStartSubscription?.cancel();
    _walkFinishSubscription?.cancel();
    _walkMonitor.dispose();
    super.dispose();
  }

  void changePage(String pageName) {
    if (_currentPageName != pageName) {
      safeSetState(() {
        _currentPageName = pageName;
        _currentPage = null;
        print('Navegación interna cambiada a: $pageName');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'homeDogOwner': HomeDogOwnerWidget(),
      'CurrentWalk': CurrentWalkEmptyWindowWidget(),
      'petList': PetListWidget(),
      'dogOwnerProfile': DogOwnerProfileWidget(),
    };
    final currentIndex = tabs.keys.toList().indexOf(_currentPageName);

    return Scaffold(
      resizeToAvoidBottomInset: !widget.disableResizeToAvoidBottomInset,
      body: _currentPage ?? tabs[_currentPageName],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => safeSetState(() {
          _currentPage = null;
          _currentPageName = tabs.keys.toList()[i];
        }),
        backgroundColor: FlutterFlowTheme.of(context).tertiary,
        selectedItemColor: FlutterFlowTheme.of(context).primary,
        unselectedItemColor: const Color(0xFFB1B1B1),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on, size: 30), label: 'Ver Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.pets_outlined, size: 30), label: 'Mascotas'),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: 30), label: 'Perfil'),
        ],
      ),
    );
  }
}

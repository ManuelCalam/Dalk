import 'dart:async';
import 'package:dalk/backend/supabase/supabase.dart';
import 'package:dalk/common/walk_payment_window/walk_payment_window_widget.dart';
import 'package:dalk/components/pop_up_current_walk_options/pop_up_current_walk_options_widget.dart';
import 'package:dalk/dog_owner/walk_monitor.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dalk/flutter_flow/flutter_flow_theme.dart';
import 'package:dalk/flutter_flow/flutter_flow_util.dart';
import 'package:go_router/go_router.dart'; // ¡Nueva Importación clave!

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
  _NavBarOwnerPageState createState() => _NavBarOwnerPageState();
}

class _NavBarOwnerPageState extends State<NavBarOwnerPage> {
  late WalkMonitor _walkMonitor;
  StreamSubscription<String>? _walkStartSubscription;
  StreamSubscription<String>? _walkFinishSubscription;

  @override
  void initState() {
    super.initState();

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
              child: PopUpCurrentWalkOptionsWidget(walkId: int.tryParse(walkId) ?? 0,),
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

      context.push(
        '/owner/walkPayment', 
        extra: <String, dynamic>{
            'walkId': int.tryParse(walkId) ?? 0,
            'userType': 'Dueño',
        }
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

          await SupaFlow.client
              .from('users')
              .update({'pet_trackers': null})
              .eq('uuid', currentUserId)
              .maybeSingle();
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

  @override
  Widget build(BuildContext context) {
    const navPaths = <String>[
      '/owner/home',         
      '/owner/currentWalk',  
      '/owner/petList',      
      '/owner/profile',      
    ];
    
    final currentLocation = GoRouterState.of(context).uri.toString();

    // 3. Determinar el índice activo
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
          BottomNavigationBarItem(icon: Icon(Icons.location_on, size: 30), label: 'Ver Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.pets_outlined, size: 30), label: 'Mascotas'),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: 30), label: 'Perfil'),
        ],
      ),
    );
  }
}
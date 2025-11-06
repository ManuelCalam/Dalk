import 'package:dalk/flutter_flow/flutter_flow_theme.dart';
import 'package:dalk/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ¡Importación clave para GoRouter!

class NavBarWalkerPage extends StatefulWidget {
  NavBarWalkerPage({
    Key? key,
    this.initialPage,
    this.page, // El widget actual de la ruta hija, pasado por ShellRoute.
    this.disableResizeToAvoidBottomInset = false,
  }) : super(key: key);

  final String? initialPage;
  final Widget? page;
  final bool disableResizeToAvoidBottomInset;

  @override
  // Se renombra el State para mayor claridad
  _NavBarWalkerPageState createState() => _NavBarWalkerPageState();
}

/// Esta es la clase State privada que ahora trabaja directamente con GoRouter.
class _NavBarWalkerPageState extends State<NavBarWalkerPage> {
  // ELIMINADO: String _currentPageName
  // ELIMINADO: late Widget? _currentPage
  // ELIMINADO: initState solo llama a super.initState() si no hay lógica extra.

  // ELIMINADO: didUpdateWidget (ya no es necesario, GoRouter se encarga de las actualizaciones)
  
  @override
  Widget build(BuildContext context) {
    // 1. Definir las rutas principales del NavBar en ORDEN.
    const navPaths = <String>[
      '/walker/home',        // Índice 0
      '/walker/currentWalk',  // Índice 1
      '/walker/service',      // Índice 2
      '/walker/profile',      // Índice 3
    ];
    
    // 2. Obtener la ruta actual de GoRouter (ej: /walker/service)
    final currentLocation = GoRouterState.of(context).uri.toString();

    // 3. Determinar el índice activo
    int currentIndex = navPaths.indexOf(currentLocation);

    // Manejar subrutas (si la ruta es /walker/profile/edit, queremos que Perfil siga activo)
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
        items: const <BottomNavigationBarItem>[
          // Asegúrate de que el orden de los íconos coincida con el orden de 'navPaths'
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30.0),
            label: '',
            tooltip: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on, size: 30.0),
            label: '',
            tooltip: 'Paseo Actual',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.perm_contact_cal, size: 30.0),
            label: '',
            tooltip: 'Servicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30.0),
            label: '',
            tooltip: 'Perfil',
          )
        ],
      ),
    );
  }
}
import 'package:dalk/common/current_walk_empty_window/current_walk_empty_window_widget.dart';

import 'package:dalk/dog_walker/dog_walker_profile/dog_walker_profile_widget.dart';
import 'package:dalk/dog_walker/home_dog_walker/home_dog_walker_widget.dart';
import 'package:dalk/flutter_flow/flutter_flow_theme.dart';
import 'package:dalk/flutter_flow/flutter_flow_util.dart';
import 'package:dalk/landing_pages/dog_walker_service/dog_walker_service_widget.dart';
import 'package:flutter/material.dart';

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
  _NavBarPageState createState() => _NavBarPageState();
}

/// This is the private State class that goes with NavBarPage.
class _NavBarPageState extends State<NavBarWalkerPage> {
  String _currentPageName = 'homeDogWalker';
  late Widget? _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
  }

// En nav_bar_dog_walker.dart, dentro de _NavBarPageState

@override
void didUpdateWidget(covariant NavBarWalkerPage oldWidget) {
  super.didUpdateWidget(oldWidget);
  
  // Definir las claves válidas para usar en la validación
  final validPages = const ['homeDogWalker', 'CurrentWalk', 'walkerService', 'dogWalkerProfile'];
  
  // Verificar si la página inicial ha cambiado Y si el nuevo valor no es nulo
  if (widget.initialPage != null && widget.initialPage != oldWidget.initialPage) {
    setState(() {
      // 🌟 Si el valor es válido, ¡lo usamos!
      if (validPages.contains(widget.initialPage)) {
        _currentPageName = widget.initialPage!;
      } else {
        // 🚨 Si el valor no es una página del walker, volvemos a Home.
        // Esto previene cargar una página de "Dueño" en la barra de "Paseador"
        _currentPageName = 'homeDogWalker';
      }
      _currentPage = null;
    });
  }
}
  

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'homeDogWalker': HomeDogWalkerWidget(),
      'CurrentWalk': CurrentWalkEmptyWindowWidget(),
      'walkerService': DogWalkerServiceWidget(),
      'dogWalkerProfile': DogWalkerProfileWidget(),
    };
  String pageToUse = tabs.containsKey(_currentPageName) ? _currentPageName : 'homeDogWalker';
  
  // Ahora el índice siempre será >= 0
  final currentIndex = tabs.keys.toList().indexOf(pageToUse);

    return Scaffold(
      resizeToAvoidBottomInset: !widget.disableResizeToAvoidBottomInset,
    body: _currentPage ?? tabs[pageToUse], 
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => safeSetState(() {
          _currentPage = null;
          _currentPageName = tabs.keys.toList()[i];
        }),
        backgroundColor: FlutterFlowTheme.of(context).tertiary,
        selectedItemColor: FlutterFlowTheme.of(context).primary,
        unselectedItemColor: Color(0xFFB1B1B1),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30.0,
            ),
            label: '',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.location_on,
              size: 30.0,
            ),
            label: '',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.perm_contact_cal,
              size: 30.0,
            ),
            label: 'Home',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 30.0,
            ),
            label: 'Home',
            tooltip: '',
          )
        ],
      ),
    );
  }
}

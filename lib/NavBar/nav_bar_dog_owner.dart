import 'package:dalk/current_walk/current_walk_widget.dart';
import 'package:dalk/dog_owner/dog_owner_profile/dog_owner_profile_widget.dart';
import 'package:dalk/dog_owner/home_dog_owner/home_dog_owner_widget.dart';
import 'package:dalk/dog_owner/pet_list/pet_list_widget.dart';
import 'package:dalk/flutter_flow/flutter_flow_theme.dart';
import 'package:dalk/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

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



/// This is the private State class that goes with NavBarPage.
class _NavBarPageState extends State<NavBarOwnerPage> {
  String _currentPageName = 'homeDogOwner';
  late Widget? _currentPage;

  @override
  void initState() {
    super.initState();
      print('NavBarOwnerPage initialPage: ${widget.initialPage}');

    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
  }
  
  @override
  void didUpdateWidget(covariant NavBarOwnerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPage != null) {
      setState(() {
        _currentPageName = widget.initialPage!;
        _currentPage = null;
      });
    }
}

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'homeDogOwner': HomeDogOwnerWidget(),
      'CurrentWalk': CurrentWalkWidget(),
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
              Icons.pets_outlined,
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
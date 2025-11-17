import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();

    final sessionActive = prefs.getBool('session_active') ?? false;
    final userType = prefs.getString('user_type');

    if (!mounted) return;

    if (sessionActive && userType != null) {
      if (userType == 'Dueño') {
        context.go('/owner/home');
      } else  if (userType == 'Paseador') {
        context.go('/walker/home');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFCCDBFF),
      // backgroundColor: FlutterFlowTheme.of(context).alternate,
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF0080C4),
          strokeWidth: 4,
        ),
      ),
    );
  }
}



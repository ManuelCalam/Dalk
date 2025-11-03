import 'package:dalk/backend/supabase/database/database.dart';
import 'package:dalk/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class RootNavWidget extends StatefulWidget {
  final String? initialPage;
  const RootNavWidget({super.key, this.initialPage});

  @override
  State<RootNavWidget> createState() => _RootNavWidgetState();
}

class _RootNavWidgetState extends State<RootNavWidget> {
  String? _userType;
  bool _loading = true;
  bool _redirecting = false;
  int _attempts = 0;
  final int _maxAttempts = 10;

  @override
  void initState() {
    super.initState();
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      setState(() {
        _loading = false;
        _userType = null;
      });
      
      Future.microtask(() => GoRouter.of(context).go('/login')); 
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('usertype')
          .eq('uuid', userId)
          .maybeSingle();

      final userType = response?['usertype'];

      if (userType == null && _attempts < _maxAttempts) {
        _attempts++;
        print("Haciendo intento en RootNavWidget: $_attempts");
        await Future.delayed(const Duration(milliseconds: 2500));
        return _checkUserType();
      }

      if (userType == null && _attempts >= _maxAttempts) {
        setState(() {
          _loading = false;
          _userType = null;
          _redirecting = true;
        });

        Future.delayed(const Duration(seconds: 2), () async {
          if (mounted) {
            await Supabase.instance.client.auth.signOut();
            GoRouter.of(context).go('/login');
          }
        });
        return;
      }

      setState(() {
        _userType = userType;
        _loading = false;
      });

      // Redirección según tipo
      if (userType == 'Dueño') {
        GoRouter.of(context).go(widget.initialPage ?? '/owner/home'); 
      } else if (userType == 'Paseador') {
        GoRouter.of(context).go(widget.initialPage ?? '/walker/home');
      } else if (userType == 'Indefinido') {
        GoRouter.of(context).go('/chooseUserType');
      } else {
        GoRouter.of(context).go('/login');
      }
    } catch (e) {
      debugPrint('Error al obtener userType: $e');
      setState(() {
        _loading = false;
        _userType = null;
      });
      GoRouter.of(context).go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_redirecting) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No se pudo obtener el tipo de usuario.\nRedirigiendo al inicio de sesión...',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_userType == null) {
      return const Scaffold(
        body: Center(
          child: Text('Error inesperado. Intenta iniciar sesión nuevamente.'),
        ),
      );
    }

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

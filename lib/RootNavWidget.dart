import 'package:dalk/NavBar/nav_bar_dog_walker.dart';
import 'package:dalk/backend/supabase/database/database.dart';
import 'package:dalk/landing_pages/login/login_widget.dart';
import 'package:flutter/material.dart';
import 'NavBar/nav_bar_dog_owner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final int _maxAttempts = 5;

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
        await Future.delayed(const Duration(milliseconds: 2500));
        return _checkUserType();
      }

      if (userType == null && _attempts >= _maxAttempts) {
        // Ya se intentó varias veces y no se encontró usuario
        setState(() {
          _loading = false;
          _userType = null;
          _redirecting = true;
        });

        // Esperar 2 segundos antes de enviar al login
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Supabase.instance.client.auth.signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginWidget()),
              (route) => false,
            );
          }
        });

        return;
      }

      // Si se encontró userType
      setState(() {
        _userType = userType;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error al obtener userType: $e');
      setState(() {
        _loading = false;
        _userType = null;
      });
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
      // No debería pasar (ya se maneja arriba), pero lo dejamos por seguridad
      return const Scaffold(
        body: Center(
          child: Text('Error inesperado. Intenta iniciar sesión nuevamente.'),
        ),
      );
    }

    // ✅ Tu lógica original
    if (_userType == 'Dueño') {
      return NavBarOwnerPage(
        key: ValueKey(widget.initialPage),
        initialPage: widget.initialPage,
      );
    } else if (_userType == 'Paseador') {
      return NavBarWalkerPage(initialPage: widget.initialPage);
    } else {
      return const Scaffold(
        body: Center(child: Text('Tipo de usuario no reconocido')),
      );
    }
  }
}

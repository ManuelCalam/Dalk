import 'package:dalk/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';  
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'VerificationCallbackPage_model.dart';
import 'package:provider/provider.dart';

class VerificationCallbackWidget extends StatefulWidget {
  const VerificationCallbackWidget({
    super.key,
    required this.userId,
    required this.sessionId,

  });

  final String userId;
  final String sessionId;

  static String routeName = 'verificationCallback';
  static String routePath = '/verification-callback';

  @override
  State<VerificationCallbackWidget> createState() => _VerificationCallbackWidgetState();
}

class _VerificationCallbackWidgetState extends State<VerificationCallbackWidget> {
  late VerificationCallbackModel _model;
  bool _isChecking = true;
  String _statusMessage = 'Verificando tu identidad...';
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VerificationCallbackModel());

    _listenVerificationStatus();
  }


  @override
  void dispose() {
    _channel?.unsubscribe();
    _model.dispose();
    super.dispose();
  }

void _listenVerificationStatus() {
  final sessionId = widget.sessionId;

  debugPrint('🟢 Escuchando cambios para session_id: $sessionId');

  _channel = SupaFlow.client
      .channel('identity_verification_changes_$sessionId')
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'identity_verifications',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'session_id',
          value: sessionId,
        ),
        callback: (payload) {
          final newRow = payload.newRecord;

          final status = newRow['status'] as String?;
          final result = newRow['verification_result'] as int?;
          final failureReason = newRow['failure_reason'] as String?;

          debugPrint('📡 Cambio Realtime detectado:');
          debugPrint('status = $status, result = $result');

          if (!mounted) return;

          if (status == 'success') {
            setState(() {
              _statusMessage = '¡Verificación exitosa!';
              _isChecking = false;
            });

            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) context.go('/walker/home');
            });

          } else if (status == 'failed') {

            _handleAutomaticFailure(failureReason);

          } else {
            setState(() {
              _statusMessage = 'Verificando...';
            });
          }
        },
      )
      .subscribe();
}



  Future<void> _handleAutomaticFailure(String? failureReason) async {
  setState(() {
    _isChecking = false;
    _statusMessage = 'Verificación fallida ❌';
  });

  // Opcional: mostrar un mensaje antes de redirigir
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(failureReason != null
          ? 'Verificación fallida: $failureReason'
          : 'Verificación fallida'),
      backgroundColor: Colors.red,
    ),
  );

  try {
    // 1️⃣ Sign out supabase
    await Supabase.instance.client.auth.signOut();

    // 2️⃣ Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 3️⃣ Clear provider
    if (context.mounted) {
      context.read<UserProvider>().clearUser();
    }

    // 4️⃣ Navegar al login
    Future.microtask(() {
      if (context.mounted) context.go('/login');
    });

  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cerrando sesión: $e')),
      );
    }
  }
}


  void _handleVerificationError(String error) {
    if (!mounted) return;

    setState(() {
      _isChecking = false;
      _statusMessage = 'Error en verificación';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).secondary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isChecking)
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
            const SizedBox(height: 24),
            Text(
              _statusMessage,
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                font: GoogleFonts.lexend(),
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            if (!_isChecking && _statusMessage.contains('exitosa'))
              const SizedBox(height: 16),
            if (!_isChecking && _statusMessage.contains('exitosa'))
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
          ],
        ),
      ),
    );
  }
}
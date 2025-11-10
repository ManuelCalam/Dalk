import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';  // 🔑 IMPORT NECESARIO
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'VerificationCallbackPage_model.dart';

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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VerificationCallbackModel());
    _checkVerificationStatus();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // 🔑 CONSULTAR STATUS EN BD Y REDIRIGIR
  Future<void> _checkVerificationStatus() async {
    try {
      debugPrint('🔍 Consultando status de verificación...');
      debugPrint('User ID: ${widget.userId}');
      debugPrint('Session ID: ${widget.sessionId}');

      // Esperar 3 segundos para dar tiempo al webhook de actualizar la BD
      await Future.delayed(const Duration(seconds: 3));

      // 🔑 USAR SupaFlow.client (ya importado correctamente)
      final response = await SupaFlow.client
          .from('identity_verifications')
          .select('status, verification_result, failure_reason')
          .eq('session_id', widget.sessionId)
          .maybeSingle();

      if (response == null) {
        debugPrint('❌ No se encontró registro de verificación');
        _handleVerificationError('No se encontró el registro de verificación');
        return;
      }

      final status = response['status'] as String?;
      final result = response['verification_result'] as int?;
      final failureReason = response['failure_reason'] as String?;

      debugPrint('📊 Status: $status, Result: $result');

      if (!mounted) return;

      // 🔑 LÓGICA DE REDIRECCIÓN SEGÚN STATUS
      if (status == 'completed' && (result ?? 0) >= 90) {
        // ✅ VERIFICACIÓN EXITOSA
        setState(() {
          _isChecking = false;
          _statusMessage = '¡Verificación exitosa! ✅';
        });

        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          context.goNamed('/walker_home');  // 🔑 Usar la ruta correcta del nav.dart
        }
      } else if (status == 'VERIFYING' || status == 'OPEN') {
        // ⏳ AÚN PROCESANDO
        setState(() {
          _statusMessage = 'Procesando verificación, por favor espera...';
        });

        // Reintentar después de 5 segundos
        await Future.delayed(const Duration(seconds: 5));
        if (mounted) _checkVerificationStatus();
      } else {
        // ❌ VERIFICACIÓN FALLIDA
        _handleVerificationFailure(status, failureReason);
      }
    } catch (e, stackTrace) {
      debugPrint('💥 Error consultando status: $e');
      debugPrint('Stack trace: $stackTrace');
      _handleVerificationError('Error consultando el estado: $e');
    }
  }

  void _handleVerificationFailure(String? status, String? failureReason) {
    setState(() {
      _isChecking = false;
      _statusMessage = 'Verificación fallida ❌';
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Verificación no completada',
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                  font: GoogleFonts.lexend(),
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu verificación de identidad no pudo completarse.',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.lexend(),
                color: Colors.white70,
              ),
            ),
            if (failureReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  'Motivo: $failureReason',
                  style: TextStyle(color: Colors.red[200], fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await authManager.signOut();
              if (mounted) {
                context.go('/');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Volver al inicio', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
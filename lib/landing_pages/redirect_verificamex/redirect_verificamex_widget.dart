import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/backend/supabase/supabase.dart';
import 'package:dalk/landing_pages/login/login_widget.dart';
import 'package:dalk/dog_walker/home_dog_walker/home_dog_walker_widget.dart';

class RedirectVerificamexWidget extends StatefulWidget {
  final String userId;
  final String sessionId;

  const RedirectVerificamexWidget({
    Key? key,
    required this.userId,
    required this.sessionId,
  }) : super(key: key);

  @override
  _RedirectVerificamexWidgetState createState() =>
      _RedirectVerificamexWidgetState();
}

class _RedirectVerificamexWidgetState extends State<RedirectVerificamexWidget> {
  late InAppWebViewController _webViewController;
  Timer? _statusTimer;
  bool _checkingStatus = false;

  @override
  void initState() {
    super.initState();
    _startVerificationChecker();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  /// 🔍 Consulta periódicamente el estado de verificación en identity_verifications
  void _startVerificationChecker() {
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_checkingStatus) return; // evita llamadas simultáneas
      _checkingStatus = true;

      try {
        final response = await Supabase.instance.client
            .from('identity_verifications')
            .select('status')
            .eq('user_uuid', widget.userId)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        final status = response?['status'];
        debugPrint('🔎 Estado actual de verificación: $status');

        if (status == 'completed') {
          _statusTimer?.cancel();
          await _handleVerificationSuccess();
        } else if (status == 'failed') {
          _statusTimer?.cancel();
          await _handleVerificationFailed();
        }
      } catch (e) {
        debugPrint('⚠️ Error consultando verificación: $e');
      } finally {
        _checkingStatus = false;
      }
    });
  }

  /// ✅ Caso: Verificación completada con éxito
  /// ✅ Caso: Verificación completada con éxito
Future<void> _handleVerificationSuccess() async {
  try {
    final supabase = Supabase.instance.client;

    // 🔑 Recuperar el access_token desde la BD
    final verificationData = await supabase
        .from('identity_verifications')
        .select('access_token')
        .eq('user_uuid', widget.userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    final storedToken = verificationData?['access_token'];
    
    if (storedToken != null) {
      debugPrint('🔑 Token recuperado desde BD');
      // Si necesitas usar el token, aquí lo tienes disponible
    }

    // Actualiza el estado del usuario
    await supabase
        .from('users')
        .update({'verification_status': 'verified'})
        .eq('id', widget.userId);

    if (mounted) {
      debugPrint('✅ Verificación completada. Redirigiendo al Home...');
      context.pushReplacementNamed(HomeDogWalkerWidget.routeName);
    }
  } catch (e) {
    debugPrint('❌ Error actualizando usuario a verified: $e');
  }
}

  /// ❌ Caso: Verificación fallida
  Future<void> _handleVerificationFailed() async {
    try {
      final supabase = Supabase.instance.client;

      // Elimina registros y usuario
      await supabase.from('users').delete().eq('id', widget.userId);
      await supabase.auth.admin.deleteUser(widget.userId);

      if (mounted) {
        debugPrint('❌ Verificación fallida. Redirigiendo al Login...');
        context.pushReplacementNamed(LoginWidget.routeName);
      }
    } catch (e) {
      debugPrint('❌ Error eliminando usuario tras fallo: $e');
    }
  }

  /// 🌐 HTML embebido con animaciones y mensajes
  String _getEmbeddedHtml() {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Verificación Completada - Dalk</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body { 
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
      text-align: center; 
      padding: 40px 20px; 
      background: linear-gradient(135deg, #163143 0%, #0080C4 100%);
      color: #E0ECFF; 
      margin: 0;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    
    .container { 
      max-width: 400px; 
      background: rgba(22, 49, 67, 0.9);
      border-radius: 20px;
      padding: 40px 30px;
      box-shadow: 0 8px 32px rgba(0, 128, 196, 0.3);
      border: 1px solid rgba(224, 236, 255, 0.2);
    }
    
    .success-icon {
      width: 80px;
      height: 80px;
      background: #0080C4;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto 24px;
      animation: pulse 2s infinite;
    }
    
    .success-icon::before {
      content: '✓';
      font-size: 40px;
      color: #E0ECFF;
      font-weight: bold;
    }
    
    .title { 
      color: #E0ECFF;
      font-size: 24px;
      font-weight: 600;
      margin-bottom: 16px;
    }
    
    .subtitle {
      color: #CCDBFF;
      font-size: 16px;
      margin-bottom: 32px;
      line-height: 1.5;
    }
    
    .loading { 
      width: 60px; 
      height: 60px; 
      border: 4px solid rgba(0, 128, 196, 0.2); 
      border-top: 4px solid #0080C4; 
      border-radius: 50%; 
      animation: spin 1s linear infinite; 
      margin: 24px auto; 
    }
    
    .status-text {
      color: #CCDBFF;
      font-size: 14px;
      margin-top: 24px;
      padding: 16px;
      background: rgba(0, 128, 196, 0.1);
      border-radius: 12px;
      border: 1px solid rgba(0, 128, 196, 0.3);
    }
    
    .warning-text {
      color: #CCDBFF;
      font-size: 12px;
      margin-top: 16px;
      opacity: 0.8;
    }
    
    @keyframes spin { 
      0% { transform: rotate(0deg); } 
      100% { transform: rotate(360deg); } 
    }
    
    @keyframes pulse {
      0%, 100% { transform: scale(1); }
      50% { transform: scale(1.05); }
    }
    
    .countdown {
      color: #0080C4;
      font-weight: bold;
      font-size: 16px;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="success-icon"></div>
    <h2 class="title">¡Fotos Enviadas Exitosamente!</h2>
    <p class="subtitle">
      Hemos recibido las fotos de tu INE y CURP.<br>
      Verificamex está analizando tus documentos.
    </p>
    <div class="loading"></div>
    <div class="status-text">
      <strong>Estado:</strong> Procesando verificación...<br>
      <strong>Tiempo estimado:</strong> 0-4 minutos<br>
      <strong>Progreso:</strong> <span id="progress-text">Analizando documentos...</span>
    </div>
    <p class="warning-text">
      ⚠️ <strong>Importante:</strong> No cierres esta ventana.<br>
      El resultado se mostrará automáticamente.
    </p>
    <div style="margin-top: 24px;">
      <div class="countdown">
        Esta ventana se cerrará automáticamente al completarse
      </div>
    </div>
  </div>
  
  <script>
    console.log('🎉 Usuario completó captura de fotos');
    console.log('🎉 Session ID: ${widget.sessionId}');
    console.log('🎉 User ID: ${widget.userId}');
    
    const progressMessages = [
      'Analizando documentos...',
      'Verificando INE...',
      'Validando CURP...',
      'Comparando datos...',
      'Finalizando verificación...'
    ];
    
    let currentMessage = 0;
    const progressElement = document.getElementById('progress-text');
    setInterval(() => {
      currentMessage = (currentMessage + 1) % progressMessages.length;
      if (progressElement) {
        progressElement.textContent = progressMessages[currentMessage];
      }
    }, 30000);
    
    setInterval(() => {
      console.log('💓 Heartbeat - esperando resultado del webhook...');
    }, 60000);
  </script>
</body>
</html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: InAppWebView(
          initialData: InAppWebViewInitialData(data: _getEmbeddedHtml()),
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              mediaPlaybackRequiresUserGesture: false,
              javaScriptEnabled: true,
            ),
          ),
          onWebViewCreated: (controller) => _webViewController = controller,
        ),
      ),
    );
  }
}

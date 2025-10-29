import 'package:flutter/material.dart';
import 'package:dalk/backend/supabase/database/database.dart';
import 'package:dalk/flutter_flow/flutter_flow_util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerificationCallbackPage extends StatefulWidget {
  static const String routeName = 'VerificationCallbackPage';
  static const String routePath = '/verification_callback';

  final String? status;
  final String? sessionId;
  final String? userId;

  const VerificationCallbackPage({
    super.key,
    this.status,
    this.sessionId,
    this.userId,
  });

  @override
  State<VerificationCallbackPage> createState() => _VerificationCallbackPageState();
}

class _VerificationCallbackPageState extends State<VerificationCallbackPage> {
  @override
  void initState() {
    super.initState();
    AppStateNotifier.instance.setIgnoreAuthChange(false);
    _handleVerification();
  }

  Future<void> _handleVerification() async {
    if (widget.status == 'success') {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await Supabase.instance.client
            .from('users')
            .update({'usertype': 'PaseadorVerificado'})
            .eq('uuid', userId);
      }
    }

    if (mounted) {
      context.goNamed('RootNavWidget');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Procesando verificación...'),
      ),
    );
  }
}

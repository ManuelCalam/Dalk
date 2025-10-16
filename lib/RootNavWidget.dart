import 'package:dalk/NavBar/nav_bar_dog_walker.dart';
import 'package:dalk/backend/supabase/database/database.dart';
import 'package:dalk/landing_pages/login/login_widget.dart';
import 'package:dalk/landing_pages/redirect_verificamex/redirect_verificamex_widget.dart';
import 'package:flutter/material.dart';
import 'NavBar/nav_bar_dog_owner.dart';

class RootNavWidget extends StatelessWidget {
  final String? initialPage;
  const RootNavWidget({super.key, this.initialPage});

  Future<Map<String, dynamic>?> getUserInfo() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await Supabase.instance.client
        .from('users')
        .select('usertype, verification_status, uuid')
        .eq('uuid', userId)
        .maybeSingle();

    return response;
  }

  Future<String?> getPendingSessionId(String uuid) async {
    final response = await Supabase.instance.client
        .from('identity_verifications')
        .select('session_id')
        .eq('user_uuid', uuid)
        .eq('status', 'pending')
        .order('created_at', ascending: false)
        .maybeSingle();

    return response?['session_id'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getUserInfo(),
      builder: (context, snapshot) {
        // Mientras la future está esperando, mostrar loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Si hubo error al obtener info, mostrar mensaje simple (puedes ajustar)
        if (snapshot.hasError) {
          debugPrint('Error al obtener userInfo: ${snapshot.error}');
          return Scaffold(
            body: Center(
              child: Text('Error al cargar la app. Intenta reiniciar.'),
            ),
          );
        }

        // Si la future terminó y data es null -> usuario no logueado -> Login
        if (snapshot.connectionState == ConnectionState.done && snapshot.data == null) {
          return LoginWidget();
        }

        // A partir de aquí snapshot.data está disponible y no es null
        final userInfo = snapshot.data!;
        final userType = userInfo['usertype'];
        final verificationStatus = userInfo['verification_status'];
        final uuid = userInfo['uuid'];

        if (userType == 'Dueño') {
          return NavBarOwnerPage(
            key: ValueKey(initialPage),
            initialPage: initialPage,
          );
        } else if (userType == 'Paseador') {
          if (verificationStatus != 'verified') {
            // Busca el sessionId pendiente de identity_verifications
            return FutureBuilder<String?>(
              future: getPendingSessionId(uuid),
              builder: (context, sessionSnapshot) {
                if (sessionSnapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                if (sessionSnapshot.hasError) {
                  debugPrint('Error al obtener sessionId: ${sessionSnapshot.error}');
                  // Si hay error, mejor mandar a Redirect con session vacía o al Login según tu UX
                  return Scaffold(
                    body: Center(
                      child: Text('Error al cargar verificación.'),
                    ),
                  );
                }
                final sessionId = sessionSnapshot.data ?? '';
                return RedirectVerificamexWidget(
                  sessionId: sessionId,
                  userId: uuid,
                );
              },
            );
          }
          return NavBarWalkerPage(initialPage: initialPage);
        } else {
          return Scaffold(body: Center(child: Text('Tipo de usuario no reconocido')));
        }
      },
    );
  }
}

import 'package:dalk/NavBar/nav_bar_dog_owner.dart';
import 'package:dalk/landing_pages/login/login_widget.dart';
import 'package:flutter/material.dart';
import 'package:dalk/backend/supabase/database/database.dart';

class RootNavWidget extends StatelessWidget {
  final String? initialPage;
  const RootNavWidget({super.key, this.initialPage});

  Future<String?> getUserType() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await Supabase.instance.client
        .from('users')
        .select('usertype')
        .eq('uuid', userId)
        .maybeSingle();

    return response?['usertype'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getUserType(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final userType = snapshot.data;

        // Si no hay usuario logueado o paseador no verificado → Login
        if (userType == null || userType == 'Paseador') {
          return LoginWidget();
        }

        // Dueños van directo a su home
        if (userType == 'Dueño') {
          return NavBarOwnerPage(
            key: ValueKey(initialPage),
            initialPage: initialPage,
          );
        }

        // Cualquier otro caso → Login
        return LoginWidget();
      },
    );
  }
}

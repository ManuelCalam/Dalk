import 'package:dalk/NavBar/nav_bar_dog_walker.dart';
import 'package:dalk/backend/supabase/database/database.dart';
import 'package:flutter/material.dart';
import 'NavBar/nav_bar_dog_owner.dart';

class RootNavWidget extends StatelessWidget {
  final String? initialPage;
  const RootNavWidget({super.key, this.initialPage});

  Future<String?> getUserType() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if(userId == null) return null;

    final response = await Supabase.instance.client
      .from('users')
      .select('usertype')
      .eq('uuid', userId)
      .maybeSingle();

      return response?['usertype'];
  }

  @override
  Widget build(BuildContext context) {
      print('InitialPage recibido: $initialPage');

    return FutureBuilder<String?>(
      future: getUserType(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final userType = snapshot.data;
        if(userType == 'Dueño') {
            print('NavBarOwnerPage initialPage from RootNav: $initialPage');
            return NavBarOwnerPage(
              key: ValueKey(initialPage),
              initialPage: initialPage);
        } else if(userType == 'Paseador') {
            return NavBarWalkerPage(initialPage: initialPage);
        } else {
          return Scaffold(body: Center(child: Text('Tipo de usuario no reconocido')));
        }
      },
    );
  }
}
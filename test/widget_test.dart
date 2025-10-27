import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'mocks/mock_user_provider.dart';
import 'mocks/mock_supabase.dart';
import 'mocks/mock_firebase.dart';
import 'mocks/mock_app_links.dart';
import 'package:flutter/material.dart';
import 'package:dalk/main.dart'; // Tu main.dart real

void main() {
  testWidgets('Carga principal de la app sin errores', (tester) async {
    final mockUserProvider = MockUserProvider();
    final mockSupabase = MockSupabaseClient();
    final mockFirebase = MockFirebaseMessaging();
    final mockAppLinks = MockAppLinks();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MockUserProvider>.value(value: mockUserProvider),
          // Aquí podrías agregar más providers de mocks si los usas
        ],
        child: MyApp(), // tu app real
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
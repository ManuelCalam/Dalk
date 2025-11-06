import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient {
  Stream<dynamic> authStream() => Stream.empty();

  // Puedes agregar métodos que uses en tu app
  void initialize() {}
}

class MockSupaFlow {
  static final instance = MockSupaFlow();
  final client = MockSupabaseClient();
}
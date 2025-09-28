import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SupabaseClient _supabase;
  late final StreamSubscription<List<Map<String, dynamic>>> _subscription;

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  SubscriptionProvider(this._supabase) {
    _initSubscriptionStatus();
  }

  // Método de inicialización que obtiene el estado inicial y se suscribe a los cambios
  void _initSubscriptionStatus() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return;
    }

    // 1. Obtener el estado inicial de la suscripción
    _supabase
        .from('users')
        .select('subscription_status')
        .eq('uuid', userId)
        .single()
        .then((data) {
          final status = data['subscription_status'] as String?;
          _isPremium = status == 'active';
          notifyListeners();
        });

    // 2. Suscribirse a los cambios en tiempo real en la base de datos
    _subscription = _supabase
        .from('users')
        .stream(primaryKey: ['uuid']) // stream() es para escuchar cambios
        .eq('uuid', userId)
        .listen((data) {
          // El stream devuelve una lista, pero con .eq('uuid', userId) solo habrá un elemento
          if (data.isNotEmpty) {
            final status = data.first['subscription_status'] as String?;
            final newIsPremium = status == 'active';
            if (_isPremium != newIsPremium) {
              _isPremium = newIsPremium;
              notifyListeners(); 
            }
          }
        });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
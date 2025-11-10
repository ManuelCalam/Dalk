import 'dart:async';
import 'package:flutter/foundation.dart'; // Importado para debugPrint
import 'package:supabase_flutter/supabase_flutter.dart';

class WalkerMonitor {
  final String userId;
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  late final RealtimeChannel _channel;

  // Controlador de Stream para las cancelaciones del dueño
  final _walkCancelledByOwnerController = StreamController<String>.broadcast();

  Stream<String> get walkCancelledByOwnerUpdates => _walkCancelledByOwnerController.stream;

  WalkerMonitor({required this.userId});

  void initialize() {
    _channel = _supabaseClient.channel('walker_walks_channel_$userId');

    _channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'walks',
      // Filtramos para escuchar SÓLO los paseos asignados a este Walker
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'walker_id',
        value: userId,
      ),
      callback: (payload) {
        final newStatus = payload.newRecord['status'];
        final oldStatus = payload.oldRecord['status'];
        final walkId = payload.newRecord['id'];

        debugPrint('REALTIME (WALKER): Evento detectado para $walkId | old=$oldStatus | new=$newStatus');

        if (newStatus == 'Cancelado_Dueño' && oldStatus != 'Cancelado_Dueño') {
          debugPrint('REALTIME (WALKER): ALERTA! Paseo $walkId que estaba EN CURSO fue cancelado por el dueño.');
          _walkCancelledByOwnerController.add(walkId.toString());
        }
      },
    );

    _channel.subscribe((status, error) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        debugPrint('REALTIME (WALKER): Monitor suscrito para walker: $userId');
      } else if (error != null) {
        debugPrint('REALTIME (WALKER): ERROR en la suscripción: $error');
      }
    });
  }

  void dispose() {
    _channel.unsubscribe();
    _walkCancelledByOwnerController.close();
    debugPrint('REALTIME (WALKER): Monitor deshabilitado.');
  }
}
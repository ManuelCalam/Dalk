import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalkMonitor {
  final String userId;
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  late final RealtimeChannel _channel;

  // Dos controladores: uno para En curso y otro para Finalizado
  final _startedController = StreamController<String>.broadcast();
  final _finishedController = StreamController<String>.broadcast();
  final _canceledByWalkerController = StreamController<String>.broadcast();

  Stream<String> get walkStartedUpdates => _startedController.stream;
  Stream<String> get walkFinishedUpdates => _finishedController.stream;
  Stream<String> get walkCanceledWalkerUpdates => _canceledByWalkerController.stream;

  WalkMonitor({required this.userId});

  void initialize() {
    _channel = _supabaseClient.channel('walks_channel_$userId');

    _channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'walks',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'owner_id',
        value: userId,
      ),
      callback: (payload) {
        final newStatus = payload.newRecord['status'];
        final oldStatus = payload.oldRecord['status'];
        final walkId = payload.newRecord['id'];

        print('REALTIME EVENT DETECTED: $walkId | old=$oldStatus | new=$newStatus');

        // Detectar inicio
        if (newStatus == 'En curso' && oldStatus != 'En curso') {
          print('REALTIME: Paseo $walkId cambió a En curso');
          _startedController.add(walkId.toString());
        }

        // Detectar finalización
        if (newStatus == 'Finalizado' && oldStatus != 'Finalizado') {
          print('REALTIME: Paseo $walkId cambió a Finalizado');
          _finishedController.add(walkId.toString());
        }

        // Detectar finalización
        if (newStatus == 'Cancelado_Paseador' && oldStatus != 'Cancelado_Paseador') {
          print('REALTIME: Paseo $walkId cambió a Cancelado_Dueño');
          _canceledByWalkerController.add(walkId.toString());
        }
      },
    );

    _channel.subscribe((status, error) {
      print('Realtime status: $status');
      if (error != null) print('Realtime error: $error');
    });

    print('REALTIME: Monitor de paseos inicializado para el usuario: $userId');
  }

  void dispose() {
    _channel.unsubscribe();
    _startedController.close();
    _finishedController.close();
    _canceledByWalkerController.close();
    print('REALTIME: Monitor de paseos deshabilitado.');
  }
}

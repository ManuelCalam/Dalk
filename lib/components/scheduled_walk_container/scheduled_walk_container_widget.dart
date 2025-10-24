import 'dart:async';
import 'package:dalk/backend/supabase/supabase.dart' show SupaFlow;
import 'package:dalk/common/chat/chat_widget.dart';
import 'package:dalk/components/pop_up_walk_options/pop_up_walk_options_widget.dart';
import 'package:dalk/dog_walker/background_service/background_service.dart';
import 'package:dalk/dog_walker/background_service/on_ios_background';
import 'package:dalk/flutter_flow/flutter_flow_icon_button.dart';
import 'package:dalk/flutter_flow/flutter_flow_widgets.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_background_service/flutter_background_service.dart'
    show
        AndroidConfiguration,
        FlutterBackgroundService,
        IosConfiguration;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart' hide LatLng;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'scheduled_walk_container_model.dart';
export 'scheduled_walk_container_model.dart';

class ScheduledWalkContainerWidget extends StatefulWidget {
  final String walkId;
  final String userType;
  const ScheduledWalkContainerWidget({
    required this.walkId,
    required this.userType,
    super.key,
  });

  @override
  State<ScheduledWalkContainerWidget> createState() => ScheduledWalkContainerWidgetState();
}



class ScheduledWalkContainerWidgetState
    extends State<ScheduledWalkContainerWidget> with WidgetsBindingObserver {
  late ScheduledWalkContainerModel _model;

  final ValueNotifier<Set<Marker>> _markersNotifier = ValueNotifier({});
  final ValueNotifier<String> _timerDisplayNotifier = ValueNotifier('00:00');

  Timer? _locationTimer;
  StreamSubscription<DatabaseEvent>? _locationSubscription;

  List<StreamSubscription<DatabaseEvent>> _trackerSubscriptions = []; 

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ScheduledWalkContainerModel());

    WidgetsBinding.instance.addObserver(this);

    // Inicialización del set de marcadores (punto de inicio)
    _markersNotifier.value = {
      Marker(
        markerId: const MarkerId("inicio"),
        position: _model.googleMapsCenter,
        infoWindow: const InfoWindow(title: "Punto de inicio"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),
    };

    if (widget.userType == 'Paseador') {
      // Al cargar la ventana, siempre iniciamos el rastreo en primer plano.
      _startSendingLocation(); 
    } else if (widget.userType == 'Dueño') {
      _listenToWalkerLocation();
      _listenToTrackerLocation(); 
    }

    _model.textController ??= TextEditingController(text: '[username]');
    _model.textFieldFocusNode ??= FocusNode();

    // Timer
  }

  // --- LÓGICA DEL CICLO DE VIDA (RESUMED/PAUSED) ---

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.userType != 'Paseador') return;

    if (state == AppLifecycleState.paused) {
      _locationTimer?.cancel();
      _setTrackingIds(includeCurrentWalk: true); 
      FlutterBackgroundService().invoke("setAsBackground"); 
    }

    if (state == AppLifecycleState.resumed) {
      _startSendingLocation(); 
    }
  }

  // --- MÉTODOS DE SERVICIO DE FONDO MULTI-WALK ---

  // Helper para obtener todos los IDs activos
  Future<List<String>> _getActiveWalkIds() async {
    final currentUserId = SupaFlow.client.auth.currentUser?.id;
    if (currentUserId == null) return [];
    
    final activeWalksRes = await SupaFlow.client
        .from('walks')
        .select('id')
        .eq('walker_id', currentUserId)
        .eq('status', 'En curso')
        .order('created_at', ascending: true);

    return activeWalksRes
        .map((e) => e['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
  }

  // Lógica centralizada para enviar IDs de rastreo al servicio de fondo
  Future<void> _setTrackingIds({required bool includeCurrentWalk}) async {
    final allActiveWalkIds = await _getActiveWalkIds();
    
    final List<String> trackingIds = includeCurrentWalk
        ? allActiveWalkIds
        : allActiveWalkIds.where((id) => id != widget.walkId).toList();
        
    await _ensureServiceIsRunning();

    if (trackingIds.isEmpty) {
        FlutterBackgroundService().invoke("stopService"); 
        print('UI: Servicio de fondo detenido. trackingIds está vacío.');
    } else {
        FlutterBackgroundService().invoke("setTrackingIds", {"walkIds": trackingIds});
        print('UI: Background Service actualizado para rastrear: $trackingIds');
    }
  }
  
  // 1. Helper para configurar e iniciar el servicio si no está corriendo.
  Future<void> _ensureServiceIsRunning() async { 
    final service = FlutterBackgroundService();

    bool isRunning = await service.isRunning();

    if (!isRunning) {
        await service.configure(
            androidConfiguration: AndroidConfiguration(
                onStart: onStart, 
                isForegroundMode: true,
                autoStart: true,
            ),
            iosConfiguration: IosConfiguration(
                autoStart: true,
                onForeground: onStart,
                onBackground: onIosBackground,
            ),
        );
        await service.startService(); 
    }
    await Future.delayed(const Duration(milliseconds: 500)); 
  }



  void _startSendingLocation() async {
    // final hasPermission = await _handleLocationPermission();
    // if (!hasPermission) return;

    await _setTrackingIds(includeCurrentWalk: false); 
    
    _locationTimer?.cancel(); 

    const interval = Duration(seconds: 6);
    final ref = FirebaseDatabase.instance.ref('walk_locations/${widget.walkId}');

    _locationTimer = Timer.periodic(interval, (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Check de mounted después de la primera operación asíncrona
      if (!mounted) {
          timer.cancel();
          return;
      }

      // Enviamos ubicación a Firebase
      await ref.update({
        'lat': position.latitude,
        'lng': position.longitude,
      });

      final currentLatLng = LatLng(position.latitude, position.longitude);
      
      // Obtener el controlador del mapa
      final controller = await _model.googleMapsController.future;

      // Check de mounted antes de usar el ValueNotifier
      if (!mounted) {
          timer.cancel();
          return;
      }
      
      // Actualizar solo el ValueNotifier de marcadores
      final newWalkerMarker = Marker(
        markerId: const MarkerId("walker"),
        position: currentLatLng,
        infoWindow: const InfoWindow(title: 'Tú estás aquí'),
      );

      // Reemplazar o agregar el marcador del paseador
      final newMarkers = Set<Marker>.from(_markersNotifier.value);
      newMarkers.removeWhere((m) => m.markerId.value == 'walker');
      newMarkers.add(newWalkerMarker);

      _markersNotifier.value = newMarkers; 

      controller.animateCamera(CameraUpdate.newLatLng(currentLatLng));
    });
  }

// Future<bool> _handleLocationPermission() async {
//   LocationPermission permission = await Geolocator.checkPermission();

//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission(); 
//     if (permission == LocationPermission.denied) {
//       return false;
//     }
//   }

//   if (permission == LocationPermission.deniedForever) {
//     return false;
//   }

//   return true;
// }


  // --- NUEVA LÓGICA DE RASTREO POR UUID DEL DISPOSITIVO ---

  // 1. Obtener TODOS los UUIDs de rastreador del Dueño
  Future<List<String>> _fetchAllTrackerIds() async {
    final currentUserId = SupaFlow.client.auth.currentUser?.id;
    if (currentUserId == null) return [];

    try {
      final response = await SupaFlow.client
          .from('users')
          .select('pet_trackers')
          .eq('uuid', currentUserId)
          .limit(1)
          .maybeSingle(); 

      if (response == null || !response.containsKey('pet_trackers')) return [];

      final trackers = response['pet_trackers'];

      // pet_trackers es un array de UUIDs. Filtramos y convertimos a List<String>.
      if (trackers is List) {
        return trackers.map((e) => e.toString()).where((id) => id.isNotEmpty).toList();
      }
      return [];

    } catch (e) {
      print('Error fetching pet_trackers: $e');
      return [];
    }
  }

  // 2. Escuchar la ubicación de CADA rastreador (Tracker UUID) en Firebase RTDB
  void _listenToTrackerLocation() async {
    // 1. Obtener TODOS los UUIDs
    final trackerIds = await _fetchAllTrackerIds();

    if (trackerIds.isEmpty) {
      print('ADVERTENCIA: Dueño no tiene rastreadores asignados o no está autenticado.');
      return;
    }

    // Limpiar suscripciones anteriores
    _trackerSubscriptions.forEach((sub) => sub.cancel());
    _trackerSubscriptions.clear();

    // Crear una suscripción para CADA rastreador
    for (final trackerId in trackerIds) {
      // Ruta de Firebase: dog_locations/UUID_DEL_RASTREADOR
      final ref = FirebaseDatabase.instance.ref('dog_locations/$trackerId');

      final subscription = ref.onValue.listen((event) async {
        if (!mounted) return;

        final data = event.snapshot.value as Map?;
        // La estructura de datos esperada es {lat: ..., lng: ...}
        if (data != null && data.containsKey('lat') && data.containsKey('lng')) {
          final lat = (data['lat'] as num).toDouble();
          final lng = (data['lng'] as num).toDouble();
          final position = LatLng(lat, lng);

          // Usamos el UUID como ID del marcador para poder actualizarlo
          final markerId = "tracker_$trackerId"; 

          // Marcador del Rastreador (Azul para diferenciarlo del Paseador)
          final newTrackerMarker = Marker(
            markerId: MarkerId(markerId),
            position: position,
            infoWindow: InfoWindow(title: 'Rastreador: ${trackerId.substring(0, 8)}...'), // Mostrar parte del UUID
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), 
          );

          // Actualizar el set de marcadores
          // 1. Clonar el set actual
          final newMarkers = Set<Marker>.from(_markersNotifier.value);

          // 2. Remover el marcador antiguo de este rastreador específico
          newMarkers.removeWhere((m) => m.markerId.value == markerId);

          // 3. Agregar el nuevo marcador
          newMarkers.add(newTrackerMarker);

          // 4. Notificar a la UI
          _markersNotifier.value = newMarkers;

          // Opcional: Animar la cámara al último rastreador que se actualizó. 
          final controller = await _model.googleMapsController.future;
          controller.animateCamera(CameraUpdate.newLatLng(position));
        }
      }, onError: (Object error) {
        print('Firebase RTDB error for tracker $trackerId: $error');
      });
      
      _trackerSubscriptions.add(subscription);
    }
  }

  // --- FIN NUEVA LÓGICA DE RASTREO ---


  // Método aplicado para el dueño para obtener la ubicación del paseador
  void _listenToWalkerLocation() {
    final ref = FirebaseDatabase.instance.ref('walk_locations/${widget.walkId}');

    _locationSubscription = ref.onValue.listen((event) async {
      // Comprobar mounted y cancelar la suscripción si el widget se ha ido
      if (!mounted) {
        _locationSubscription?.cancel();
        return;
      }

      final data = event.snapshot.value as Map?;
      if (data != null && data.containsKey('lat') && data.containsKey('lng')) {
        final lat = (data['lat'] as num).toDouble();
        final lng = (data['lng'] as num).toDouble();
        final position = LatLng(lat, lng);

        final controller = await _model.googleMapsController.future;

        final newWalkerMarker = Marker(
          markerId: const MarkerId("walker"),
          position: position,
          infoWindow: const InfoWindow(title: 'Paseador'),
        );

        // Reemplazar o agregar el marcador del paseador
        final newMarkers = Set<Marker>.from(_markersNotifier.value);
        newMarkers.removeWhere((m) => m.markerId.value == 'walker');
        newMarkers.add(newWalkerMarker);

        _markersNotifier.value = newMarkers;
        controller.animateCamera(CameraUpdate.newLatLng(position));
      }
    });
  }

    Future<void> handleWalkCompletion() async { 
    final currentUserId = SupaFlow.client.auth.currentUser?.id;

    if (currentUserId == null) {
      print("Error: No se pudo obtener el ID del usuario actual.");
      return;
    }

    _locationTimer?.cancel();
    
    await SupaFlow.client
      .from('walks')
      .update({'status': 'Finalizado'})
      .eq('id', widget.walkId);
    
    // print("Paseo ${widget.walkId} marcado como Finalizado.");


    final remainingWalksRes = await SupaFlow.client
        .from('walks')
        .select('id')
        .eq('walker_id', currentUserId)
        .eq('status', 'En curso')
        .order('created_at', ascending: true);

    final List<String> allActiveWalkIds = remainingWalksRes
        .map((e) => e['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    // El primer paseo en la lista será el nuevo paseo principal (foreground)
    final nextForegroundWalkId = allActiveWalkIds.isNotEmpty 
        ? allActiveWalkIds.first 
        : null;

    if (nextForegroundWalkId != null) {
      await SupaFlow.client
        .from('users')
        .update({'current_walk_id': nextForegroundWalkId})
        .eq('uuid', currentUserId)
        .maybeSingle();
        
      print("current_walk_id reasignado a $nextForegroundWalkId.");

      await _setTrackingIds(includeCurrentWalk: true);

    } else {
      
      await SupaFlow.client
        .from('users')
        .update({'current_walk_id': null})
        .eq('uuid', currentUserId)
        .maybeSingle();

      // Detener el servicio por completo ya que no hay nada más que rastrear
      FlutterBackgroundService().invoke('stopService'); 

      print("current_walk_id limpiado. Servicio de fondo detenido.");
    }

    // 5. Navegar a CurrentWalkEmptyWindow
    context.pushReplacementNamed(
      '_initialize',
      queryParameters: {'initialPage': 'CurrentWalk'},
    );

  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationTimer?.cancel(); 
    _locationSubscription?.cancel(); 
    _trackerSubscriptions.forEach((sub) => sub.cancel()); 

    if (widget.userType == 'Paseador') {
      _setTrackingIds(includeCurrentWalk: true); 
    }

    _model.maybeDispose();
    _stopWatchTimer.dispose();
    _markersNotifier.dispose(); 
    _timerDisplayNotifier.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> fetchWalkInfoFromView(String walkId) async {
    final response = await SupaFlow.client
        .from('walks_with_names')
        .select()
        .eq('id', walkId)
        .limit(1)
        .maybeSingle();
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      child: Column(
        children: [
          // Mapa - 60% del alto
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.6, // 60%
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            child: ValueListenableBuilder<Set<Marker>>(
              valueListenable: _markersNotifier,
              builder: (context, currentMarkers, child) {
                return GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _model.googleMapsController.complete(controller);
                  },
                  initialCameraPosition: CameraPosition(
                    target: _model.googleMapsCenter,
                    zoom: 14,
                  ),
                  zoomControlsEnabled: true,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapType: MapType.normal,
                  markers: currentMarkers, 
                );
              },
            ),
          ),

          // Contenedor de información del usuario con scroll
          Expanded(
            // El FutureBuilder solo se ejecuta UNA VEZ (al cargar el widget)
            child: FutureBuilder<Map<String, dynamic>?>(
              future: fetchWalkInfoFromView(widget.walkId),
              builder: (context, snapshot) {
                // Mientras carga
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Si hay error
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                // Si no hay datos
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('No se encontraron datos'),
                  );
                }

                // Datos cargados correctamente - ahora snapshot.data contiene la info
                final walkData = snapshot.data!;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).tertiary,
                        // borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                15, 15, 15, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  decoration: const BoxDecoration(),
                                  child: Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.2,
                                    height:
                                        MediaQuery.sizeOf(context).width * 0.2,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.network(
                                      widget.userType == 'Dueño'
                                          ? walkData['walker_photo_url']
                                          : walkData['dog_photo_url'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                                    child: TextFormField(
                                  
                                      controller: _model.textController..text = widget.userType == 'Dueño' 
                                                  ? walkData['walker_name'] 
                                                  : walkData['pet_name'],
                                      focusNode: _model.textFieldFocusNode,
                                      autofocus: false,
                                      readOnly: true,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        labelText: widget.userType == 'Dueño' ? 'Paseador' : 'Mascota',
                                        labelStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.lexend(
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color: FlutterFlowTheme.of(context)
                                                  .primary,
                                              fontSize: 18,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                        hintStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              font: GoogleFonts.lexend(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0x00000000),
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0x00000000),
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color:
                                                FlutterFlowTheme.of(context).error,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color:
                                                FlutterFlowTheme.of(context).error,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        filled: true,
                                        fillColor:
                                            FlutterFlowTheme.of(context).alternate,
                                        prefixIcon: Icon(
                                          widget.userType == 'Dueño' ?
                                          Icons.person : Icons.pets_outlined,
                                          color:
                                              FlutterFlowTheme.of(context).primary,
                                          size: 25,
                                        ),
                                      ),
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.lexend(
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context).secondaryBackground,
                                        fontSize: 23,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                      ),
                                      textAlign: TextAlign.start,
                                      cursorColor:
                                          FlutterFlowTheme.of(context).primaryText,
                                      enableInteractiveSelection: false,
                                      validator: _model.textControllerValidator
                                          .asValidator(context),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: const AlignmentDirectional(1, 0),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        10, 0, 0, 0),
                                    child: FlutterFlowIconButton(
                                      borderRadius: 8,
                                      icon: Icon(
                                        Icons.chat,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatWidget(
                                              walkerId: walkData['walker_id'],
                                              ownerId: walkData['owner_id'],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          

                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 0, 0, 15),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.9,
                              height: MediaQuery.sizeOf(context).height * 0.06,
                              decoration: const BoxDecoration(),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 10, 0, 0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                     await showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      enableDrag: false,
                                      context: context,
                                      builder: (context) {
                                        return Padding(
                                          padding:
                                              MediaQuery.viewInsetsOf(context),
                                          child: PopUpWalkOptionsWidget(walkId: int.parse(widget.walkId), usertype: widget.userType,  onWalkCompletion: handleWalkCompletion),
                                        );
                                      },
                                    ).then((value) => safeSetState(() {}));
                                  },
                                  text: 'Ver detalles',
                                  icon: const Icon(
                                    Icons.keyboard_double_arrow_up_rounded,
                                    size: 30,
                                  ),
                                  options: FFButtonOptions(
                                    height: 40,
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        16, 0, 16, 0),
                                    iconAlignment: IconAlignment.end,
                                    iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 0, 0),
                                    color: FlutterFlowTheme.of(context).primary,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.lexend(
                                            fontWeight: FlutterFlowTheme.of(
                                                    context)
                                                .titleSmall
                                                .fontWeight,
                                          ),
                                          color: Colors.white,
                                          letterSpacing: 0.0,
                                        ),
                                    elevation: 0,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
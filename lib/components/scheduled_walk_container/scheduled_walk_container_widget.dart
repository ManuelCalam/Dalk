import 'dart:async';
import 'package:dalk/dog_walker/background_service/background_service.dart';
import 'package:dalk/dog_walker/background_service/on_ios_background';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_background_service/flutter_background_service.dart' show AndroidConfiguration, FlutterBackgroundService, IosConfiguration, ServiceInstance;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart' hide LatLng;
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
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
    Key? key,
  }) : super(key: key);

  @override
  State<ScheduledWalkContainerWidget> createState() =>
      _ScheduledWalkContainerWidgetState();
}

class _ScheduledWalkContainerWidgetState
    extends State<ScheduledWalkContainerWidget> with WidgetsBindingObserver{
  late ScheduledWalkContainerModel _model;
  
  Timer? _locationTimer;
  Marker? _walkerMarker;
  StreamSubscription<DatabaseEvent>? _locationSubscription;
  bool _isForeground = true;


  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }
        

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ScheduledWalkContainerModel());

    WidgetsBinding.instance.addObserver(this);

    if (widget.userType == 'Paseador') {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        _startSendingLocation(); // Primer plano
      } else {
        _startBackgroundService(); // Segundo plano
      }
    } else if (widget.userType == 'Dueño') {
      _listenToWalkerLocation();
    }

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.userType != 'Paseador') return;

    if (state == AppLifecycleState.paused) {
      // App en segundo plano
      print("App en segundo plano. Deteniendo Timer, background continúa...");
      _locationTimer?.cancel();
      _isForeground = false;
    }

    if (state == AppLifecycleState.resumed) {
      // App vuelve al primer plano
      print("App en primer plano. Activando envío con Timer...");
      _isForeground = true;
      _stopBackgroundService(); 
      _startSendingLocation();
    }
  }


  void _stopSendingLocation() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  void _stopBackgroundService() {
    FlutterBackgroundService().invoke("stopService");
  }


  void _startBackgroundService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart, 
        isForegroundMode: true,
        autoStart: true,),
      iosConfiguration: IosConfiguration(
          autoStart: true,
          onForeground: onStart,
          onBackground: onIosBackground, 
      ), 
    );

    await service.startService();
    service.invoke("setData", {"walkId": widget.walkId});
  }



  // Método aplicado al paseador para mandar su ubicación
  void _startSendingLocation() async {
    const interval = Duration(seconds: 6);
    final ref = FirebaseDatabase.instance.ref('walk_locations/${widget.walkId}');

    _locationTimer = Timer.periodic(interval, (timer) async {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Enviamos ubicación a Firebase
      await ref.update({
        'lat': position.latitude,
        'lng': position.longitude,
      });

      final currentLatLng = LatLng(position.latitude, position.longitude);
      final controller = await _model.googleMapsController.future;

      // Actualizamos el mapa y el marcador localmente
      setState(() {
        _walkerMarker = Marker(
          markerId: const MarkerId("walker"),
          position: currentLatLng,
          infoWindow: const InfoWindow(title: 'Tú estás aquí'),
        );
        _model.googleMapsCenter = currentLatLng;
      });

      controller.animateCamera(CameraUpdate.newLatLng(currentLatLng));
    });
  }


  Future<bool> _handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    if (permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
    }

    return true;
  }



  // Método aplicado para el dueño para obtener la ubicación del paseador
  void _listenToWalkerLocation() {
    final ref = FirebaseDatabase.instance.ref('walk_locations/${widget.walkId}');

    _locationSubscription = ref.onValue.listen((event) async {
      final data = event.snapshot.value as Map?;
      if (data != null && data.containsKey('lat') && data.containsKey('lng')) {
        final lat = (data['lat'] as num).toDouble();
        final lng = (data['lng'] as num).toDouble();
        final position = LatLng(lat, lng);

        final controller = await _model.googleMapsController.future;

        setState(() {
          _walkerMarker = Marker(
            markerId: const MarkerId("walker"),
            position: position,
            infoWindow: const InfoWindow(title: 'Paseador'),
          );
          _model.googleMapsCenter = position;
        });

        controller.animateCamera(CameraUpdate.newLatLng(position));
      }
    });
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationTimer?.cancel();
    _locationSubscription?.cancel();
    _stopBackgroundService();
    _model.maybeDispose();
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [


          Container(
            width: MediaQuery.of(context).size.width ,
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            child: GoogleMap(
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
              markers: {
                if (_walkerMarker != null) _walkerMarker!,
                Marker(
                  markerId: const MarkerId("inicio"),
                  position: _model.googleMapsCenter,
                  infoWindow: const InfoWindow(title: "Punto de inicio"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
                ),
              },
            ),
          ),
          Container(
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.8,
                height: MediaQuery.sizeOf(context).height * 0.1,
                child: Container(
                  decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).alternate,
                  borderRadius: BorderRadius.circular(15),
                ),
                  padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width * 0.17,
                        height: MediaQuery.sizeOf(context).height * 0.1,
                        decoration: BoxDecoration(),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1633332755192-727a05c4013d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxfHx1c2VyfGVufDB8fHx8MTc0NjQ1OTI1OXww&ixlib=rb-4.0.3&q=80&w=1080',
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.sizeOf(context).width * 0.6,
                        height: 70,
                        decoration: BoxDecoration(),
                        child: Align(
                          alignment: AlignmentDirectional(-1, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: AlignmentDirectional(-1, -1),
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width,
                                  height: 35,
                                  decoration: BoxDecoration(),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                        width: 140,
                                        height: 100,
                                        decoration: BoxDecoration(),
                                        child: Align(
                                          alignment:
                                              AlignmentDirectional(-1, 0),
                                          child: AutoSizeText(
                                            'Nombre',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.lexend(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  fontSize: 18,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Align(
                                          alignment: AlignmentDirectional(1, 0),
                                          child: Container(
                                            height: 100,
                                            decoration: BoxDecoration(),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Flexible(
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            1, 0),
                                                    child: Icon(
                                                      Icons.star,
                                                      color: Color(0xFFE2B433),
                                                      size: 24,
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          1, 0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 0, 10, 0),
                                                    child: AutoSizeText(
                                                      '4.8',
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      minFontSize: 10,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            font: GoogleFonts
                                                                .lexend(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                            ),
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            fontSize: 20,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(-1, -1),
                                child: Container(
                                  height: 35,
                                  decoration: BoxDecoration(),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Align(
                                        alignment: AlignmentDirectional(-1, 0),
                                        child: AutoSizeText(
                                          'Tiempo:',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.lexend(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                fontSize: 16,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                      Align(
                                        alignment: AlignmentDirectional(1, 0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  5, 0, 10, 0),
                                          child: AutoSizeText(
                                            '10:30',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.lexend(
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  fontSize: 20,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: AlignmentDirectional(1, 0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0, 0, 3, 0),
                                            child: Container(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.1,
                                              decoration: BoxDecoration(),
                                              child: Icon(
                                                Icons.chat,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                size: 32,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}





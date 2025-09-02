
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart' hide LatLng;
import 'dart:ui';
import 'scheduled_walk_container_widget.dart' show ScheduledWalkContainerWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class ScheduledWalkContainerModel
    extends FlutterFlowModel<ScheduledWalkContainerWidget> {
  LatLng googleMapsCenter = LatLng(13.106061, -59.613158);
  final Completer<GoogleMapController> googleMapsController = Completer();
  
  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}

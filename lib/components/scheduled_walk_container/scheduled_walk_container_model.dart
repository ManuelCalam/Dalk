
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '/flutter_flow/flutter_flow_util.dart' hide LatLng;
import 'scheduled_walk_container_widget.dart' show ScheduledWalkContainerWidget;
import 'package:flutter/material.dart';

import 'dart:async';

class ScheduledWalkContainerModel
    extends FlutterFlowModel<ScheduledWalkContainerWidget> {
  LatLng googleMapsCenter = LatLng(13.106061, -59.613158);
  final Completer<GoogleMapController> googleMapsController = Completer();

  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;


  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}

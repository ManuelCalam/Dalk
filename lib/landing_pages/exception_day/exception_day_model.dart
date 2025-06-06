import '/components/go_back_container/go_back_container_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'exception_day_widget.dart' show ExceptionDayWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ExceptionDayModel extends FlutterFlowModel<ExceptionDayWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Model for goBackContainer component.
  late GoBackContainerModel goBackContainerModel;
  // State field(s) for wilDogWalkerWork_Switch widget.
  bool? wilDogWalkerWorkSwitchValue;
  DateTime? datePicked1;
  // State field(s) for workZone_Input widget.
  FocusNode? workZoneInputFocusNode;
  TextEditingController? workZoneInputTextController;
  String? Function(BuildContext, String?)? workZoneInputTextControllerValidator;
  DateTime? datePicked2;
  DateTime? datePicked3;

  @override
  void initState(BuildContext context) {
    goBackContainerModel = createModel(context, () => GoBackContainerModel());
  }

  @override
  void dispose() {
    goBackContainerModel.dispose();
    workZoneInputFocusNode?.dispose();
    workZoneInputTextController?.dispose();
  }
}

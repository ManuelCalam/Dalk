import '/components/go_back_container/go_back_container_widget.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'premium_plan_info_widget.dart' show PremiumPlanInfoWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PremiumPlanInfoModel extends FlutterFlowModel<PremiumPlanInfoWidget> {
  ///  Local state fields for this page.

  bool planValidity = true;

  ///  State fields for stateful widgets in this page.

  late NotificationContainerModel notificationContainerModel;
  // Model for goBackContainer component.
  late GoBackContainerModel goBackContainerModel;
  // State field(s) for planValidity_Switch widget.
  bool? planValiditySwitchValue;
  // State field(s) for addGPS_Switch widget.
  bool? addGPSSwitchValue;
  // State field(s) for addInsurance_Switch widget.
  bool? addInsuranceSwitchValue;

  @override
  void initState(BuildContext context) {
    notificationContainerModel =
        createModel(context, () => NotificationContainerModel());
    goBackContainerModel = createModel(context, () => GoBackContainerModel());
  }

  @override
  void dispose() {
    notificationContainerModel.dispose();
    goBackContainerModel.dispose();
  }
}

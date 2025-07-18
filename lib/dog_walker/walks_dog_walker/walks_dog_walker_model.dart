import '/components/go_back_container/go_back_container_widget.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_button_tabbar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'walks_dog_walker_widget.dart' show WalksDogWalkerWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class WalksDogWalkerModel extends FlutterFlowModel<WalksDogWalkerWidget> {
  ///  Local state fields for this page.

  String selectedTab = 'Solicitados';

  ///  State fields for stateful widgets in this page.

  // Model for notificationContainer component.
  late NotificationContainerModel notificationContainerModel;
  // Model for goBackContainer component.
  late GoBackContainerModel goBackContainerModel;
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

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
    tabBarController?.dispose();
  }
}

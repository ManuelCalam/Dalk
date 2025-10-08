import '/components/go_back_container/go_back_container_widget.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'walks_record_widget.dart' show WalksRecordWidget;
import 'package:flutter/material.dart';

class WalksRecordModel extends FlutterFlowModel<WalksRecordWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for notificationContainer component.
  late NotificationContainerModel notificationContainerModel;
  // Model for goBackContainer component.
  late GoBackContainerModel goBackContainerModel;

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

import '/components/go_back_container/go_back_container_widget.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'add_tracker_to_account_widget.dart' show AddTrackerToAccountWidget;
import 'package:flutter/material.dart';

class AddTrackerToAccountModel
    extends FlutterFlowModel<AddTrackerToAccountWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Model for notificationContainer component.
  late NotificationContainerModel notificationContainerModel;
  // Model for goBackContainer component.
  late GoBackContainerModel goBackContainerModel;
  // State field(s) for SerialNumber_Input widget.
  FocusNode? serialNumberInputFocusNode;
  TextEditingController? serialNumberInputTextController;
  String? Function(BuildContext, String?)?
      serialNumberInputTextControllerValidator;
  // State field(s) for TrackerAlias_Input widget.
  FocusNode? trackerAliasInputFocusNode;
  TextEditingController? trackerAliasInputTextController;
  String? Function(BuildContext, String?)?
      trackerAliasInputTextControllerValidator;

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
    serialNumberInputFocusNode?.dispose();
    serialNumberInputTextController?.dispose();

    trackerAliasInputFocusNode?.dispose();
    trackerAliasInputTextController?.dispose();
  }
}

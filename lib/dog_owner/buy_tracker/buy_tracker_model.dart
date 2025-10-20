import '/components/go_back_container/go_back_container_widget.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'buy_tracker_widget.dart' show BuyTrackerWidget;
import 'package:flutter/material.dart';

class BuyTrackerModel extends FlutterFlowModel<BuyTrackerWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for notificationContainer component.
  late NotificationContainerModel notificationContainerModel;
  // Model for goBackContainer component.
  late GoBackContainerModel goBackContainerModel;
  // State field(s) for CountController widget.
  int? countControllerValue;
  // State field(s) for NameDogOwner_Input widget.
  FocusNode? nameDogOwnerInputFocusNode;
  TextEditingController? nameDogOwnerInputTextController;
  String? Function(BuildContext, String?)?
      nameDogOwnerInputTextControllerValidator;

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
    nameDogOwnerInputFocusNode?.dispose();
    nameDogOwnerInputTextController?.dispose();
    trackerAliasInputFocusNode?.dispose();
    trackerAliasInputTextController?.dispose();
  }
}

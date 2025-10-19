import '/flutter_flow/flutter_flow_util.dart';
import 'succesfull_tracker_purchase_widget.dart'
    show SuccesfullTrackerPurchaseWidget;
import 'package:flutter/material.dart';

class SuccesfullTrackerPurchaseModel
    extends FlutterFlowModel<SuccesfullTrackerPurchaseWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for NameDogOwner_Input widget.
  FocusNode? nameDogOwnerInputFocusNode;
  TextEditingController? nameDogOwnerInputTextController;
  String? Function(BuildContext, String?)?
      nameDogOwnerInputTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    nameDogOwnerInputFocusNode?.dispose();
    nameDogOwnerInputTextController?.dispose();
  }
}

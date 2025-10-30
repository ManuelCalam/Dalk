import 'package:dalk/components/go_back_container/go_back_container_model.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'walker_stripe_account_widget.dart' show WalkerStripeAccountWidget;
import 'package:flutter/material.dart';

class WalkerStripeAccountModel
    extends FlutterFlowModel<WalkerStripeAccountWidget> {
  ///  State fields for stateful widgets in this page.
  /// 
  late GoBackContainerModel goBackContainerModel;


  // State field(s) for NameDogOwner_Input widget.
  FocusNode? nameDogOwnerInputFocusNode1;
  TextEditingController? nameDogOwnerInputTextController1;
  String? Function(BuildContext, String?)?
      nameDogOwnerInputTextController1Validator;
  // State field(s) for NameDogOwner_Input widget.
  FocusNode? nameDogOwnerInputFocusNode2;
  TextEditingController? nameDogOwnerInputTextController2;
  String? Function(BuildContext, String?)?
      nameDogOwnerInputTextController2Validator;
  // State field(s) for NameDogOwner_Input widget.
  FocusNode? nameDogOwnerInputFocusNode3;
  TextEditingController? nameDogOwnerInputTextController3;
  String? Function(BuildContext, String?)?
      nameDogOwnerInputTextController3Validator;

  @override
  void initState(BuildContext context) {
    goBackContainerModel = createModel(context, () => GoBackContainerModel());
  }

  @override
  void dispose() {
    goBackContainerModel.dispose();
    nameDogOwnerInputFocusNode1?.dispose();
    nameDogOwnerInputTextController1?.dispose();

    nameDogOwnerInputFocusNode2?.dispose();
    nameDogOwnerInputTextController2?.dispose();

    nameDogOwnerInputFocusNode3?.dispose();
    nameDogOwnerInputTextController3?.dispose();
  }
}

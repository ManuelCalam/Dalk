import '/components/go_back_container/go_back_container_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'owner_debt_widget.dart' show OwnerDebtWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OwnerDebtModel extends FlutterFlowModel<OwnerDebtWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for goBackContainer component.
  late GoBackContainerModel goBackContainerModel;
  // State field(s) for NameDogOwner_Input widget.
  FocusNode? nameDogOwnerInputFocusNode;
  TextEditingController? nameDogOwnerInputTextController;
  String? Function(BuildContext, String?)?
      nameDogOwnerInputTextControllerValidator;

  @override
  void initState(BuildContext context) {
    goBackContainerModel = createModel(context, () => GoBackContainerModel());
  }

  @override
  void dispose() {
    goBackContainerModel.dispose();
    nameDogOwnerInputFocusNode?.dispose();
    nameDogOwnerInputTextController?.dispose();
  }
}

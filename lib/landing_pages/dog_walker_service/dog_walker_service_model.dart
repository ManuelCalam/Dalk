import '/components/go_back_container/go_back_container_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import 'dog_walker_service_widget.dart' show DogWalkerServiceWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DogWalkerServiceModel extends FlutterFlowModel<DogWalkerServiceWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Model for goBackContainer component.
  late GoBackContainerModel goBackContainerModel;
  // State field(s) for dogWalkerFee_Input widget.
  FocusNode? dogWalkerFeeInputFocusNode;
  TextEditingController? dogWalkerFeeInputTextController;
  String? Function(BuildContext, String?)?
      dogWalkerFeeInputTextControllerValidator;
  String? _dogWalkerFeeInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Teléfono is required';
    }

    return null;
  }

  // State field(s) for dogWalkerInfo_Input widget.
  FocusNode? dogWalkerInfoInputFocusNode;
  TextEditingController? dogWalkerInfoInputTextController;
  String? Function(BuildContext, String?)?
      dogWalkerInfoInputTextControllerValidator;
  // State field(s) for workZone_Input widget.
  FocusNode? workZoneInputFocusNode;
  TextEditingController? workZoneInputTextController;
  String? Function(BuildContext, String?)? workZoneInputTextControllerValidator;
  String? _workZoneInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Teléfono is required';
    }

    return null;
  }

  // State field(s) for ChoiceChips widget.
  FormFieldController<List<String>>? choiceChipsValueController;
  List<String>? get choiceChipsValues => choiceChipsValueController?.value;
  set choiceChipsValues(List<String>? val) =>
      choiceChipsValueController?.value = val;
  DateTime? datePicked1;
  DateTime? datePicked2;

  @override
  void initState(BuildContext context) {
    goBackContainerModel = createModel(context, () => GoBackContainerModel());
    dogWalkerFeeInputTextControllerValidator =
        _dogWalkerFeeInputTextControllerValidator;
    workZoneInputTextControllerValidator =
        _workZoneInputTextControllerValidator;
  }

  @override
  void dispose() {
    goBackContainerModel.dispose();
    dogWalkerFeeInputFocusNode?.dispose();
    dogWalkerFeeInputTextController?.dispose();

    dogWalkerInfoInputFocusNode?.dispose();
    dogWalkerInfoInputTextController?.dispose();

    workZoneInputFocusNode?.dispose();
    workZoneInputTextController?.dispose();
  }
}

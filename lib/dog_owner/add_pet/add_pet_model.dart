import '/components/go_back_container/go_back_container_widget.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'add_pet_widget.dart' show AddPetWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddPetModel extends FlutterFlowModel<AddPetWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for notificationContainer component.
  late NotificationContainerModel notificationContainerModel;
  // Model for goBackContainer component.
  late GoBackContainerModel goBackContainerModel;
  // State field(s) for name_Input widget.
  FocusNode? nameInputFocusNode;
  TextEditingController? nameInputTextController;
  String? Function(BuildContext, String?)? nameInputTextControllerValidator;
  // State field(s) for age_Input widget.
  FocusNode? ageInputFocusNode;
  TextEditingController? ageInputTextController;
  String? Function(BuildContext, String?)? ageInputTextControllerValidator;
  // State field(s) for gender_Input widget.
  FocusNode? genderInputFocusNode;
  TextEditingController? genderInputTextController;
  String? Function(BuildContext, String?)? genderInputTextControllerValidator;
  // State field(s) for race_Input widget.
  FocusNode? raceInputFocusNode;
  TextEditingController? raceInputTextController;
  String? Function(BuildContext, String?)? raceInputTextControllerValidator;
  // State field(s) for dogSize_Menu widget.
  String? dogSizeMenuValue;
  FormFieldController<String>? dogSizeMenuValueController;
  // State field(s) for behaviour_Chips widget.
  FormFieldController<List<String>>? behaviourChipsValueController;
  List<String>? get behaviourChipsValues =>
      behaviourChipsValueController?.value;
  set behaviourChipsValues(List<String>? val) =>
      behaviourChipsValueController?.value = val;
  // State field(s) for dogInfo_Input widget.
  FocusNode? dogInfoInputFocusNode;
  TextEditingController? dogInfoInputTextController;
  String? Function(BuildContext, String?)? dogInfoInputTextControllerValidator;

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
    nameInputFocusNode?.dispose();
    nameInputTextController?.dispose();

    ageInputFocusNode?.dispose();
    ageInputTextController?.dispose();

    genderInputFocusNode?.dispose();
    genderInputTextController?.dispose();

    raceInputFocusNode?.dispose();
    raceInputTextController?.dispose();

    dogInfoInputFocusNode?.dispose();
    dogInfoInputTextController?.dispose();
  }
}

import '/components/go_back_container/go_back_container_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'sing_in_dog_walker_widget.dart' show SingInDogWalkerWidget;
import 'package:flutter/material.dart';


class SingInDogWalkerModel extends FlutterFlowModel<SingInDogWalkerWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Model for goBackContainer component.
  late GoBackContainerModel goBackContainerModel;
  // State field(s) for NameDogWalker_Input widget.
  FocusNode? nameDogWalkerInputFocusNode;
  TextEditingController? nameDogWalkerInputTextController;
  String? Function(BuildContext, String?)?
      nameDogWalkerInputTextControllerValidator;
  // State field(s) for EmailDogWalker_Input widget.
  FocusNode? emailDogWalkerInputFocusNode;
  TextEditingController? emailDogWalkerInputTextController;
  String? Function(BuildContext, String?)?
      emailDogWalkerInputTextControllerValidator;
  // State field(s) for PhoneDogWalker_Input widget.
  FocusNode? phoneDogWalkerInputFocusNode;
  TextEditingController? phoneDogWalkerInputTextController;
  String? Function(BuildContext, String?)?
      phoneDogWalkerInputTextControllerValidator;
  DateTime? datePicked;
  // State field(s) for GenderDogWalker_Menu widget.
  String? genderDogWalkerMenuValue;
  FormFieldController<String>? genderDogWalkerMenuValueController;
  // State field(s) for StreetDogWalker_Input widget.
  FocusNode? streetDogWalkerInputFocusNode;
  TextEditingController? streetDogWalkerInputTextController;
  String? Function(BuildContext, String?)?
      streetDogWalkerInputTextControllerValidator;
  // State field(s) for interiorNumberDogWalker_Input widget.
  FocusNode? interiorNumberDogWalkerInputFocusNode;
  TextEditingController? interiorNumberDogWalkerInputTextController;
  String? Function(BuildContext, String?)?interiorNumberDogWalkerInputTextControllerValidator;
  // State field(s) for ZipCodeDogWalker_Input widget.
  FocusNode? zipCodeDogWalkerInputFocusNode;
  TextEditingController? zipCodeDogWalkerInputTextController;
  String? Function(BuildContext, String?)? zipCodeDogWalkerInputTextControllerValidator;
  // State field(s) for ZipCodeDogWalker_Input widget.
  FocusNode? exteriorNumberDogWalkerFocusNode;
  TextEditingController? exteriorNumberDogWalkerTextController;
  String? Function(BuildContext, String?)? exteriorNumberDogWalkerTextControllerValidator;
  // State field(s) for NeighborhoodDogWalker_Input widget.
  FocusNode? neighborhoodDogWalkerInputFocusNode;
  TextEditingController? neighborhoodDogWalkerInputTextController;
  String? Function(BuildContext, String?)?
      neighborhoodDogWalkerInputTextControllerValidator;
  // State field(s) for CountryDogWalker_Input widget.
  FocusNode? cityDogWalkerInputFocusNode;
  TextEditingController? cityDogWalkerInputTextController;
  String? Function(BuildContext, String?)?
      cityDogWalkerInputTextControllerValidator;
  // State field(s) for PassDogWalker_Input widget.
  FocusNode? passDogWalkerInputFocusNode;
  TextEditingController? passDogWalkerInputTextController;
  late bool passDogWalkerInputVisibility;
  String? Function(BuildContext, String?)?
      passDogWalkerInputTextControllerValidator;
  // State field(s) for confirmPassDogWalker_Input widget.
  FocusNode? confirmPassDogWalkerInputFocusNode;
  TextEditingController? confirmPassDogWalkerInputTextController;
  late bool confirmPassDogWalkerInputVisibility;
  String? Function(BuildContext, String?)?
      confirmPassDogWalkerInputTextControllerValidator;

  @override
  void initState(BuildContext context) {
    goBackContainerModel = createModel(context, () => GoBackContainerModel());
    passDogWalkerInputVisibility = false;
    confirmPassDogWalkerInputVisibility = false;
  }

  @override
  void dispose() {
    goBackContainerModel.dispose();
    nameDogWalkerInputFocusNode?.dispose();
    nameDogWalkerInputTextController?.dispose();

    emailDogWalkerInputFocusNode?.dispose();
    emailDogWalkerInputTextController?.dispose();

    phoneDogWalkerInputFocusNode?.dispose();
    phoneDogWalkerInputTextController?.dispose();

    streetDogWalkerInputFocusNode?.dispose();
    streetDogWalkerInputTextController?.dispose();

    interiorNumberDogWalkerInputFocusNode?.dispose();
    interiorNumberDogWalkerInputTextController?.dispose();

    exteriorNumberDogWalkerFocusNode?.dispose();
    exteriorNumberDogWalkerTextController?.dispose();

    zipCodeDogWalkerInputFocusNode?.dispose();
    zipCodeDogWalkerInputTextController?.dispose();

    neighborhoodDogWalkerInputFocusNode?.dispose();
    neighborhoodDogWalkerInputTextController?.dispose();

    cityDogWalkerInputFocusNode?.dispose();
    cityDogWalkerInputTextController?.dispose();

    passDogWalkerInputFocusNode?.dispose();
    passDogWalkerInputTextController?.dispose();

    confirmPassDogWalkerInputFocusNode?.dispose();
    confirmPassDogWalkerInputTextController?.dispose();
  }
}

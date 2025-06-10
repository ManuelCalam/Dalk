import '/components/go_back_container/go_back_container_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'sing_in_dog_walker_widget.dart' show SingInDogWalkerWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
  String? _nameDogWalkerInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Teléfono is required';
    }

    return null;
  }

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
  String? _phoneDogWalkerInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Ingresa un numero de telefono';
    }

    return null;
  }

  DateTime? datePicked;
  // State field(s) for GenderDogWalker_Menu widget.
  String? genderDogWalkerMenuValue;
  FormFieldController<String>? genderDogWalkerMenuValueController;
  // State field(s) for StreetDogWalker_Input widget.
  FocusNode? streetDogWalkerInputFocusNode;
  TextEditingController? streetDogWalkerInputTextController;
  String? Function(BuildContext, String?)?
      streetDogWalkerInputTextControllerValidator;
  String? _streetDogWalkerInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Calle is required';
    }

    return null;
  }

  // State field(s) for ApartamentNumDogWalker_Input widget.
  FocusNode? apartamentNumDogWalkerInputFocusNode;
  TextEditingController? apartamentNumDogWalkerInputTextController;
  String? Function(BuildContext, String?)?
      apartamentNumDogWalkerInputTextControllerValidator;
  String? _apartamentNumDogWalkerInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Int is required';
    }

    return null;
  }

  // State field(s) for ZipCodeDogWalker_Input widget.
  FocusNode? zipCodeDogWalkerInputFocusNode;
  TextEditingController? zipCodeDogWalkerInputTextController;
  String? Function(BuildContext, String?)?
      zipCodeDogWalkerInputTextControllerValidator;
  String? _zipCodeDogWalkerInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Cp is required';
    }

    return null;
  }

  // State field(s) for NeighborhoodDogWalker_Input widget.
  FocusNode? neighborhoodDogWalkerInputFocusNode;
  TextEditingController? neighborhoodDogWalkerInputTextController;
  String? Function(BuildContext, String?)?
      neighborhoodDogWalkerInputTextControllerValidator;
  String? _neighborhoodDogWalkerInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Colonia is required';
    }

    return null;
  }

  // State field(s) for CountryDogWalker_Input widget.
  FocusNode? cityDogWalkerInputFocusNode;
  TextEditingController? cityDogWalkerInputTextController;
  String? Function(BuildContext, String?)?
      cityDogWalkerInputTextControllerValidator;
  String? _cityDogWalkerInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Ciudad is required';
    }

    return null;
  }

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
    nameDogWalkerInputTextControllerValidator =
        _nameDogWalkerInputTextControllerValidator;
    phoneDogWalkerInputTextControllerValidator =
        _phoneDogWalkerInputTextControllerValidator;
    streetDogWalkerInputTextControllerValidator =
        _streetDogWalkerInputTextControllerValidator;
    apartamentNumDogWalkerInputTextControllerValidator =
        _apartamentNumDogWalkerInputTextControllerValidator;
    zipCodeDogWalkerInputTextControllerValidator =
        _zipCodeDogWalkerInputTextControllerValidator;
    neighborhoodDogWalkerInputTextControllerValidator =
        _neighborhoodDogWalkerInputTextControllerValidator;
    cityDogWalkerInputTextControllerValidator =
        _cityDogWalkerInputTextControllerValidator;
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

    apartamentNumDogWalkerInputFocusNode?.dispose();
    apartamentNumDogWalkerInputTextController?.dispose();

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

import '/components/go_back_container/go_back_container_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import 'dog_owner_update_profile_widget.dart' show DogOwnerUpdateProfileWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DogOwnerUpdateProfileModel
    extends FlutterFlowModel<DogOwnerUpdateProfileWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Model for goBackContainer component.
  late GoBackContainerModel goBackContainerModel;
  // State field(s) for NameDogOwner_Input widget.
  FocusNode? nameDogOwnerInputFocusNode;
  TextEditingController? nameDogOwnerInputTextController;
  String? Function(BuildContext, String?)?
      nameDogOwnerInputTextControllerValidator;
  String? _nameDogOwnerInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'TelÃ©fono is required';
    }

    return null;
  }

  // State field(s) for PhoneDogOwner_Input widget.
  FocusNode? phoneDogOwnerInputFocusNode;
  TextEditingController? phoneDogOwnerInputTextController;
  String? Function(BuildContext, String?)?
      phoneDogOwnerInputTextControllerValidator;
  String? _phoneDogOwnerInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'TelÃ©fono is required';
    }

    return null;
  }

  DateTime? datePicked;
  // State field(s) for GenderDogOwner_Menu widget.
  String? genderDogOwnerMenuValue;
  FormFieldController<String>? genderDogOwnerMenuValueController;
  // State field(s) for StreetDogOwner_Input widget.
  FocusNode? streetDogOwnerInputFocusNode;
  TextEditingController? streetDogOwnerInputTextController;
  String? Function(BuildContext, String?)?
      streetDogOwnerInputTextControllerValidator;
  String? _streetDogOwnerInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Calle is required';
    }

    return null;
  }

  // State field(s) for ApartamentNumDogOwner_Input widget.
  FocusNode? apartamentNumDogOwnerInputFocusNode;
  TextEditingController? apartamentNumDogOwnerInputTextController;
  String? Function(BuildContext, String?)?
      apartamentNumDogOwnerInputTextControllerValidator;
  String? _apartamentNumDogOwnerInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Int is required';
    }

    return null;
  }

  // State field(s) for ZipCodeDogOwner_Input widget.
  FocusNode? zipCodeDogOwnerInputFocusNode;
  TextEditingController? zipCodeDogOwnerInputTextController;
  String? Function(BuildContext, String?)?
      zipCodeDogOwnerInputTextControllerValidator;
  String? _zipCodeDogOwnerInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Cp is required';
    }

    return null;
  }

  // State field(s) for NeighborhoodDogOwner_Input widget.
  FocusNode? neighborhoodDogOwnerInputFocusNode;
  TextEditingController? neighborhoodDogOwnerInputTextController;
  String? Function(BuildContext, String?)?
      neighborhoodDogOwnerInputTextControllerValidator;
  String? _neighborhoodDogOwnerInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Colonia is required';
    }

    return null;
  }

  // State field(s) for CityDogOwner_Input widget.
  FocusNode? cityDogOwnerInputFocusNode;
  TextEditingController? cityDogOwnerInputTextController;
  String? Function(BuildContext, String?)?
      cityDogOwnerInputTextControllerValidator;
  String? _cityDogOwnerInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Ciudad is required';
    }

    return null;
  }

  @override
  void initState(BuildContext context) {
    goBackContainerModel = createModel(context, () => GoBackContainerModel());
    nameDogOwnerInputTextControllerValidator =
        _nameDogOwnerInputTextControllerValidator;
    phoneDogOwnerInputTextControllerValidator =
        _phoneDogOwnerInputTextControllerValidator;
    streetDogOwnerInputTextControllerValidator =
        _streetDogOwnerInputTextControllerValidator;
    apartamentNumDogOwnerInputTextControllerValidator =
        _apartamentNumDogOwnerInputTextControllerValidator;
    zipCodeDogOwnerInputTextControllerValidator =
        _zipCodeDogOwnerInputTextControllerValidator;
    neighborhoodDogOwnerInputTextControllerValidator =
        _neighborhoodDogOwnerInputTextControllerValidator;
    cityDogOwnerInputTextControllerValidator =
        _cityDogOwnerInputTextControllerValidator;
  }

  @override
  void dispose() {
    goBackContainerModel.dispose();
    nameDogOwnerInputFocusNode?.dispose();
    nameDogOwnerInputTextController?.dispose();

    phoneDogOwnerInputFocusNode?.dispose();
    phoneDogOwnerInputTextController?.dispose();

    streetDogOwnerInputFocusNode?.dispose();
    streetDogOwnerInputTextController?.dispose();

    apartamentNumDogOwnerInputFocusNode?.dispose();
    apartamentNumDogOwnerInputTextController?.dispose();

    zipCodeDogOwnerInputFocusNode?.dispose();
    zipCodeDogOwnerInputTextController?.dispose();

    neighborhoodDogOwnerInputFocusNode?.dispose();
    neighborhoodDogOwnerInputTextController?.dispose();

    cityDogOwnerInputFocusNode?.dispose();
    cityDogOwnerInputTextController?.dispose();
  }
}

import '/components/go_back_container/go_back_container_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'sing_in_dog_owner_widget.dart' show SingInDogOwnerWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SingInDogOwnerModel extends FlutterFlowModel<SingInDogOwnerWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Model for goBackContainer component.
  late GoBackContainerModel goBackContainerModel;
  // State field(s) for NameDogOwner_Input widget.
  FocusNode? nameDogOwnerInputFocusNode;
  TextEditingController? nameDogOwnerInputTextController;
  String? Function(BuildContext, String?)?
      nameDogOwnerInputTextControllerValidator;
  // State field(s) for EmailDogOwner_Input widget.
  FocusNode? emailDogOwnerInputFocusNode;
  TextEditingController? emailDogOwnerInputTextController;
  String? Function(BuildContext, String?)?
      emailDogOwnerInputTextControllerValidator;
  // State field(s) for PhoneDogOwner_Input widget.
  FocusNode? phoneDogOwnerInputFocusNode;
  TextEditingController? phoneDogOwnerInputTextController;
  String? Function(BuildContext, String?)?
      phoneDogOwnerInputTextControllerValidator;
  DateTime? datePicked;
  // State field(s) for GenderDogOwner_Menu widget.
  String? genderDogOwnerMenuValue;
  FormFieldController<String>? genderDogOwnerMenuValueController;
  // State field(s) for StreetDogOwner_Input widget.
  FocusNode? streetDogOwnerInputFocusNode;
  TextEditingController? streetDogOwnerInputTextController;
  String? Function(BuildContext, String?)?
      streetDogOwnerInputTextControllerValidator;
  // State field(s) for ApartamentNumDogOwner_Input widget.
  FocusNode? apartamentNumDogOwnerInputFocusNode;
  TextEditingController? apartamentNumDogOwnerInputTextController;
  String? Function(BuildContext, String?)?
      apartamentNumDogOwnerInputTextControllerValidator;
  // State field(s) for ZipCodeDogOwner_Input widget.
  FocusNode? zipCodeDogOwnerInputFocusNode;
  TextEditingController? zipCodeDogOwnerInputTextController;
  String? Function(BuildContext, String?)?
      zipCodeDogOwnerInputTextControllerValidator;
  // State field(s) for NeighborhoodDogOwner_Input widget.
  FocusNode? neighborhoodDogOwnerInputFocusNode;
  TextEditingController? neighborhoodDogOwnerInputTextController;
  String? Function(BuildContext, String?)?
      neighborhoodDogOwnerInputTextControllerValidator;
  // State field(s) for CountryDogOwner_Input widget.
  FocusNode? cityDogOwnerInputFocusNode;
  TextEditingController? cityDogOwnerInputTextController;
  String? Function(BuildContext, String?)?
      cityDogOwnerInputTextControllerValidator;
  // State field(s) for PassDogOwner_Input widget.
  FocusNode? passDogOwnerInputFocusNode;
  TextEditingController? passDogOwnerInputTextController;
  late bool passDogOwnerInputVisibility;
  String? Function(BuildContext, String?)?
      passDogOwnerInputTextControllerValidator;
  // State field(s) for confirmPassDogOwner_Input widget.
  FocusNode? confirmPassDogOwnerInputFocusNode;
  TextEditingController? confirmPassDogOwnerInputTextController;
  late bool confirmPassDogOwnerInputVisibility;
  String? Function(BuildContext, String?)?
      confirmPassDogOwnerInputTextControllerValidator;

  @override
  void initState(BuildContext context) {
    goBackContainerModel = createModel(context, () => GoBackContainerModel());
    passDogOwnerInputVisibility = false;
    confirmPassDogOwnerInputVisibility = false;
  }

  @override
  void dispose() {
    goBackContainerModel.dispose();
    nameDogOwnerInputFocusNode?.dispose();
    nameDogOwnerInputTextController?.dispose();

    emailDogOwnerInputFocusNode?.dispose();
    emailDogOwnerInputTextController?.dispose();

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

    passDogOwnerInputFocusNode?.dispose();
    passDogOwnerInputTextController?.dispose();

    confirmPassDogOwnerInputFocusNode?.dispose();
    confirmPassDogOwnerInputTextController?.dispose();
  }
}

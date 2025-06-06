import '/components/go_back_container/go_back_container_widget.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'add_address_widget.dart' show AddAddressWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddAddressModel extends FlutterFlowModel<AddAddressWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for notificationContainer component.
  late NotificationContainerModel notificationContainerModel;
  // Model for goBackContainer component.
  late GoBackContainerModel goBackContainerModel;
  // State field(s) for alias_Input widget.
  FocusNode? aliasInputFocusNode;
  TextEditingController? aliasInputTextController;
  String? Function(BuildContext, String?)? aliasInputTextControllerValidator;
  // State field(s) for address_Input widget.
  FocusNode? addressInputFocusNode;
  TextEditingController? addressInputTextController;
  String? Function(BuildContext, String?)? addressInputTextControllerValidator;
  // State field(s) for houseNumber_Input widget.
  FocusNode? houseNumberInputFocusNode;
  TextEditingController? houseNumberInputTextController;
  String? Function(BuildContext, String?)?
      houseNumberInputTextControllerValidator;
  // State field(s) for zipCode_Input widget.
  FocusNode? zipCodeInputFocusNode;
  TextEditingController? zipCodeInputTextController;
  String? Function(BuildContext, String?)? zipCodeInputTextControllerValidator;
  // State field(s) for neighborhood_Input widget.
  FocusNode? neighborhoodInputFocusNode;
  TextEditingController? neighborhoodInputTextController;
  String? Function(BuildContext, String?)?
      neighborhoodInputTextControllerValidator;
  // State field(s) for city_Input widget.
  FocusNode? cityInputFocusNode;
  TextEditingController? cityInputTextController;
  String? Function(BuildContext, String?)? cityInputTextControllerValidator;

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
    aliasInputFocusNode?.dispose();
    aliasInputTextController?.dispose();

    addressInputFocusNode?.dispose();
    addressInputTextController?.dispose();

    houseNumberInputFocusNode?.dispose();
    houseNumberInputTextController?.dispose();

    zipCodeInputFocusNode?.dispose();
    zipCodeInputTextController?.dispose();

    neighborhoodInputFocusNode?.dispose();
    neighborhoodInputTextController?.dispose();

    cityInputFocusNode?.dispose();
    cityInputTextController?.dispose();
  }
}

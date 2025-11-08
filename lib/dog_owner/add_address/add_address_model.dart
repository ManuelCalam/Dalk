import 'package:dalk/flutter_flow/form_field_controller.dart';

import '/components/go_back_container/go_back_container_widget.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'add_address_widget.dart' show AddAddressWidget;
import 'package:flutter/material.dart';

class AddAddressModel extends FlutterFlowModel<AddAddressWidget> {
  ///  State fields for stateful widgets in this page.
  final formKey = GlobalKey<FormState>();

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
  // State field(s) for int_Input widget.
  FocusNode? interiorNumberInputFocusNode;
  TextEditingController? interiorNumberInputTextController;
  String? Function(BuildContext, String?)? interiorNumberInputTextControllerValidator;
  // State field(s) for ext_Input widget.
  FocusNode? exteriorNumberInputFocusNode;
  TextEditingController? exteriorNumberInputTextController;
  String? Function(BuildContext, String?)? exteriorNumberInputTextControllerValidator;
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
  FormFieldController<String>? neighborhoodInputValueController;
  String? neighborhoodInputValue;

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

    interiorNumberInputFocusNode?.dispose();
    interiorNumberInputTextController?.dispose();

    zipCodeInputFocusNode?.dispose();
    zipCodeInputTextController?.dispose();

    neighborhoodInputFocusNode?.dispose();
    neighborhoodInputTextController?.dispose();

    cityInputFocusNode?.dispose();
    cityInputTextController?.dispose();
  }
}

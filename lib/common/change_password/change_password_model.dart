import '/components/go_back_container/go_back_container_widget.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'change_password_widget.dart' show ChangePasswordWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChangePasswordModel extends FlutterFlowModel<ChangePasswordWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for notificationContainer component.
  late NotificationContainerModel notificationContainerModel;
  // Model for goBackContainer component.
  late GoBackContainerModel goBackContainerModel;
  // State field(s) for currentPass_Input widget.
  FocusNode? currentPassInputFocusNode;
  TextEditingController? currentPassInputTextController;
  late bool currentPassInputVisibility;
  String? Function(BuildContext, String?)?
      currentPassInputTextControllerValidator;
  // State field(s) for newPass_Input widget.
  FocusNode? newPassInputFocusNode;
  TextEditingController? newPassInputTextController;
  late bool newPassInputVisibility;
  String? Function(BuildContext, String?)? newPassInputTextControllerValidator;
  // State field(s) for confirmNewPass_Input widget.
  FocusNode? confirmNewPassInputFocusNode;
  TextEditingController? confirmNewPassInputTextController;
  late bool confirmNewPassInputVisibility;
  String? Function(BuildContext, String?)?
      confirmNewPassInputTextControllerValidator;

  @override
  void initState(BuildContext context) {
    notificationContainerModel =
        createModel(context, () => NotificationContainerModel());
    goBackContainerModel = createModel(context, () => GoBackContainerModel());
    currentPassInputVisibility = false;
    newPassInputVisibility = false;
    confirmNewPassInputVisibility = false;
  }

  @override
  void dispose() {
    notificationContainerModel.dispose();
    goBackContainerModel.dispose();
    currentPassInputFocusNode?.dispose();
    currentPassInputTextController?.dispose();

    newPassInputFocusNode?.dispose();
    newPassInputTextController?.dispose();

    confirmNewPassInputFocusNode?.dispose();
    confirmNewPassInputTextController?.dispose();
  }
}

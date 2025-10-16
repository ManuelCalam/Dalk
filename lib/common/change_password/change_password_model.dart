import '/components/go_back_container/go_back_container_widget.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'change_password_widget.dart' show ChangePasswordWidget;
import 'package:flutter/material.dart';


class ChangePasswordModel extends FlutterFlowModel<ChangePasswordWidget> {
  // Controladores de texto para los campos de contraseña
  TextEditingController? newPasswordController;
  TextEditingController? confirmPasswordController;

  // Modelos hijos
  late NotificationContainerModel notificationContainerModel;
  late GoBackContainerModel goBackContainerModel;

  // Campo actual (actualmente no usado pero lo dejamos completo)
  FocusNode? currentPassInputFocusNode;
  TextEditingController? currentPassInputTextController;
  late bool currentPassInputVisibility;
  String? Function(BuildContext, String?)?
      currentPassInputTextControllerValidator;

  // Campo para nueva contraseña
  FocusNode? newPassInputFocusNode;
  TextEditingController? newPassInputTextController;
  bool newPassInputVisibility = false;
  String? Function(BuildContext, String?)? newPassInputTextControllerValidator;

  // Campo para confirmar nueva contraseña
  FocusNode? confirmNewPassInputFocusNode;
  TextEditingController? confirmNewPassInputTextController;
  bool confirmNewPassInputVisibility = false;
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

    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    currentPassInputFocusNode = FocusNode();
    currentPassInputTextController = TextEditingController();

    newPassInputFocusNode = FocusNode();
    newPassInputTextController = TextEditingController();

    confirmNewPassInputFocusNode = FocusNode();
    confirmNewPassInputTextController = TextEditingController();
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

    newPasswordController?.dispose();
    confirmPasswordController?.dispose();
  }
}
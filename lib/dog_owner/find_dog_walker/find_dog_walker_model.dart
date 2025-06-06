import '/cards/find_dog_walker_card/find_dog_walker_card_widget.dart';
import '/components/go_back_container/go_back_container_widget.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'find_dog_walker_widget.dart' show FindDogWalkerWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FindDogWalkerModel extends FlutterFlowModel<FindDogWalkerWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for notificationContainer component.
  late NotificationContainerModel notificationContainerModel;
  // Model for goBackContainer component.
  late GoBackContainerModel goBackContainerModel;
  // State field(s) for findDogWalker_Input widget.
  FocusNode? findDogWalkerInputFocusNode;
  TextEditingController? findDogWalkerInputTextController;
  String? Function(BuildContext, String?)?
      findDogWalkerInputTextControllerValidator;
  // Model for findDogWalker_Card component.
  late FindDogWalkerCardModel findDogWalkerCardModel;

  @override
  void initState(BuildContext context) {
    notificationContainerModel =
        createModel(context, () => NotificationContainerModel());
    goBackContainerModel = createModel(context, () => GoBackContainerModel());
    findDogWalkerCardModel =
        createModel(context, () => FindDogWalkerCardModel());
  }

  @override
  void dispose() {
    notificationContainerModel.dispose();
    goBackContainerModel.dispose();
    findDogWalkerInputFocusNode?.dispose();
    findDogWalkerInputTextController?.dispose();

    findDogWalkerCardModel.dispose();
  }
}

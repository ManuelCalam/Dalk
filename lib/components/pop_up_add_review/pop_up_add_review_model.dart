import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'pop_up_add_review_widget.dart' show PopUpAddReviewWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PopUpAddReviewModel extends FlutterFlowModel<PopUpAddReviewWidget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for RatingBar widget.
  double? ratingBarValue;
  // State field(s) for dogWalkerInfo_Input widget.
  FocusNode? dogWalkerInfoInputFocusNode;
  TextEditingController? dogWalkerInfoInputTextController;
  String? Function(BuildContext, String?)?
      dogWalkerInfoInputTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    dogWalkerInfoInputFocusNode?.dispose();
    dogWalkerInfoInputTextController?.dispose();
  }
}

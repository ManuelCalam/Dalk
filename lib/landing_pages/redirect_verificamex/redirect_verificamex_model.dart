import '/flutter_flow/flutter_flow_util.dart';
import 'redirect_verificamex_widget.dart' show RedirectVerificamexWidget;
import 'package:flutter/material.dart';

class RedirectVerificamexModel
    extends FlutterFlowModel<RedirectVerificamexWidget> {
  ///  State fields for stateful widgets in this page.

  // Estado del polling
  bool isPolling = false;
  String verificationStatus = 'pending';
  
  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    // Limpiar recursos si es necesario
  }
}
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/cards/address_card/address_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'set_walk_schedule_widget.dart' show SetWalkScheduleWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SetWalkScheduleModel extends FlutterFlowModel<SetWalkScheduleWidget> {
  ///  State fields for stateful widgets in this page.

  DateTime? datePicked1;
  DateTime? datePicked2;
  Stream<List<AddressesRow>>? addressesListViewSupabaseStream;
  // Models for address_Card dynamic component.
  late FlutterFlowDynamicModels<AddressCardModel> addressCardModels;

  @override
  void initState(BuildContext context) {
    addressCardModels = FlutterFlowDynamicModels(() => AddressCardModel());
  }

  @override
  void dispose() {
    addressCardModels.dispose();
  }
}

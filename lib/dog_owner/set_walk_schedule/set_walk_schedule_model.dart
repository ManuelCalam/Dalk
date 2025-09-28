import '/backend/supabase/supabase.dart';
import '/cards/address_card/address_card_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'set_walk_schedule_widget.dart' show SetWalkScheduleWidget;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SetWalkScheduleModel extends FlutterFlowModel<SetWalkScheduleWidget> {
  ///  State fields for stateful widgets in this page.

  DateTime? datePicked1;
  DateTime? datePicked2;
  Stream<List<AddressesRow>>? addressesListViewSupabaseStream;
  String selectedWalkDuration = '30 min';
  int customWalkDuration = 30;
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

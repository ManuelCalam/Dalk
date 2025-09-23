import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'address_card_model.dart';
export 'address_card_model.dart';

class AddressCardWidget extends StatefulWidget {
  const AddressCardWidget({
    super.key,
    required this.alias,
    required this.id,
    bool? selected,
  }) : this.selected = selected ?? false;

  final String? alias;
  final int? id;
  final bool selected;

  @override
  State<AddressCardWidget> createState() => _AddressCardWidgetState();
}

class _AddressCardWidgetState extends State<AddressCardWidget> {
  late AddressCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddressCardModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.0,
      height: 110.0,
      decoration: BoxDecoration(
        color: widget!.selected == true
            ? FlutterFlowTheme.of(context).primary
            : FlutterFlowTheme.of(context).alternate,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 100.0,
            height: 70.0,
            decoration: BoxDecoration(),
            child: Align(
              alignment: AlignmentDirectional(0.0, 0.0),
              child: FaIcon(
                FontAwesomeIcons.home,
                color: widget!.selected == true
                    ? FlutterFlowTheme.of(context).primaryBackground
                    : FlutterFlowTheme.of(context).primary,
                size: 40.0,
              ),
            ),
          ),
          Container(
            width: 100.0,
            height: 30.0,
            decoration: BoxDecoration(),
            child: Align(
              alignment: AlignmentDirectional(0.0, 0.0),
              child: AutoSizeText(
                valueOrDefault<String>(
                  widget!.alias,
                  'Direccion',
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                minFontSize: 8.0,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.lexend(
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      fontSize: 12.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

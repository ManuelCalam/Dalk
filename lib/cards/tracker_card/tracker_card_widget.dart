import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'tracker_card_model.dart';
export 'tracker_card_model.dart';

class TrackerCardWidget extends StatefulWidget {
  const TrackerCardWidget({
    super.key,
    required this.alias,
    required this.id,
    bool? selected,
  }) : this.selected = selected ?? false;

  final String? alias;
  final String? id;
  final bool selected;

  @override
  State<TrackerCardWidget> createState() => _TrackerCardWidgetState();
}

class _TrackerCardWidgetState extends State<TrackerCardWidget> {
  late TrackerCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TrackerCardModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 110,
      decoration: BoxDecoration(
        color: widget!.selected == true
            ? FlutterFlowTheme.of(context).primary
            : FlutterFlowTheme.of(context).alternate,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 100,
            height: 70,
            decoration: BoxDecoration(),
            child: Align(
              alignment: AlignmentDirectional(0, 0),
              child: Icon(
                Icons.track_changes,
                color: widget!.selected == true
                    ? FlutterFlowTheme.of(context).primaryBackground
                    : FlutterFlowTheme.of(context).primary,
                size: 45,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(),
            child: Align(
              alignment: AlignmentDirectional(0, 0),
              child: AutoSizeText(
                valueOrDefault<String>(
                  widget!.alias,
                  '[alias]',
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                minFontSize: 8,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.lexend(
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      fontSize: 12,
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

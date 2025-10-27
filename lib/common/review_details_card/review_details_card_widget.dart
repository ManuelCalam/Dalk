import 'package:dalk/utils/validation.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'review_details_card_model.dart';
export 'review_details_card_model.dart';

class ReviewDetailsCardWidget extends StatefulWidget {
  const ReviewDetailsCardWidget({
    super.key,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    required this.imageUrl,
  });

  final String userName;
  final int rating;
  final String comment;
  final DateTime date;
  final String imageUrl;

  @override
  State<ReviewDetailsCardWidget> createState() =>
      _ReviewDetailsCardWidgetState();
}

class _ReviewDetailsCardWidgetState extends State<ReviewDetailsCardWidget> {
  late ReviewDetailsCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReviewDetailsCardModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = Validators.formatDisplayName(widget.userName);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).alternate,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: const AlignmentDirectional(-1, 0),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  width: 80,
                  height: 80,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Flexible(
              child: Align(
                alignment: const AlignmentDirectional(0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: const AlignmentDirectional(-1, -1),
                            child: Text(
                              displayName,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.lexend(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context).primary,
                                    fontSize: 20,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                          ),
                          const Flexible(
                            child: Align(
                              alignment: AlignmentDirectional(1, -1),
                              child: Icon(
                                Icons.star_rounded,
                                color: Color(0xFFE2B433),
                                size: 24,
                              ),
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(1, -1),
                            child: Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
                              child: Text(
                                (widget.rating != null ? '${widget.rating} ' : '[rate]'),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.lexend(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      fontSize: 18,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(-1, 0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 5, 20, 20),
                        child: Text(
                          widget.comment,
                          textAlign: TextAlign.justify,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.lexend(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle:
                                      FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                letterSpacing: 0.0,
                                fontWeight:
                                    FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                fontStyle:
                                    FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

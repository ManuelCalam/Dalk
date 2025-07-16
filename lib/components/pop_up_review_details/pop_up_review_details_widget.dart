import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'pop_up_review_details_model.dart';
export 'pop_up_review_details_model.dart';

class PopUpReviewDetailsWidget extends StatefulWidget {
  const PopUpReviewDetailsWidget({super.key});

  @override
  State<PopUpReviewDetailsWidget> createState() =>
      _PopUpReviewDetailsWidgetState();
}

class _PopUpReviewDetailsWidgetState extends State<PopUpReviewDetailsWidget> {
  late PopUpReviewDetailsModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PopUpReviewDetailsModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0, 0),
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height * 0.45,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).tertiary,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(15, 20, 10, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional(1, 0),
                      child: FlutterFlowIconButton(
                        borderRadius: 8,
                        buttonSize: 40,
                        icon: FaIcon(
                          FontAwesomeIcons.angleDown,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 24,
                        ),
                        onPressed: () async {
                          // Action 1
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 25),
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 0.9,
                  height: 100,
                  decoration: BoxDecoration(),
                  child: Form(
                    key: _model.formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        AutoSizeText(
                          'Tu reseÃ±a',
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.lexend(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 20,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                          child: RatingBar.builder(
                            onRatingUpdate: (newValue) => safeSetState(
                                () => _model.ratingBarValue = newValue),
                            itemBuilder: (context, index) => Icon(
                              Icons.star_rounded,
                              color: FlutterFlowTheme.of(context).accent1,
                            ),
                            direction: Axis.horizontal,
                            initialRating: _model.ratingBarValue ??= 0,
                            unratedColor:
                                FlutterFlowTheme.of(context).alternate,
                            itemCount: 5,
                            itemSize: 55,
                            glowColor: FlutterFlowTheme.of(context).accent1,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).alternate,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: AutoSizeText(
                                  'MÃ¡s detalles',
                                  textAlign: TextAlign.justify,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyLarge
                                      .override(
                                        font: GoogleFonts.lexend(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyLarge
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyLarge
                                                  .fontStyle,
                                        ),
                                        fontSize: 16,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .fontStyle,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

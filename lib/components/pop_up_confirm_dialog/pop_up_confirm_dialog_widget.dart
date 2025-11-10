import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pop_up_confirm_dialog_model.dart';
export 'pop_up_confirm_dialog_model.dart';

class PopUpConfirmDialogWidget extends StatefulWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;
  final Color cancelColor;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final IconData icon;
  final Color iconColor;
  
  const PopUpConfirmDialogWidget({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.confirmColor,
    required this.cancelColor,
    required this.onConfirm,
    required this.onCancel,
    required this.icon,
    required this.iconColor
  });

  @override
  State<PopUpConfirmDialogWidget> createState() =>
      _PopUpConfirmDialogWidgetState();
}

class _PopUpConfirmDialogWidgetState extends State<PopUpConfirmDialogWidget> {
  late PopUpConfirmDialogModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PopUpConfirmDialogModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0, 0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.75,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).tertiary,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(15, 20, 10, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      alignment: const AlignmentDirectional(1, 0),
                      child: FlutterFlowIconButton(
                        borderRadius: 8,
                        icon: Icon(
                          Icons.cancel,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 30,
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 25),
              child: Container(
                width: MediaQuery.sizeOf(context).width * 0.65,
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                ),
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 0,
                  child: Form(
                    key: _model.formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AutoSizeText(
                          widget.title,
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
                                    color: FlutterFlowTheme.of(context).primary,
                                    fontSize: 20,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                    decoration: TextDecoration.none,

                                  ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                          child: Text(
                            widget.message,
                            textAlign: TextAlign.center,
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
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                  decoration: TextDecoration.none,
                                ),
                          ),
                        ),
                        Icon(
                          widget.icon,
                          color: widget.iconColor,
                          size: 40,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Align(
                            alignment: const AlignmentDirectional(0, 1),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width,
                              height: 100,
                              decoration: const BoxDecoration(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if(widget.confirmText != '')
                                  FFButtonWidget(
                                    onPressed: () {
                                      widget.onConfirm();
                                    },
                                    text: widget.confirmText,
                                    options: FFButtonOptions(
                                      width: MediaQuery.sizeOf(context).width *
                                          0.6,
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                              0.045,
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          16, 0, 16, 0),
                                      iconPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 0, 0, 0),
                                      color: widget.confirmColor,
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.lexend(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                            color: Colors.white,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                      elevation: 0,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  if(widget.cancelText != '')
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0, 7, 0, 0),
                                    child: FFButtonWidget(
                                      onPressed: () {
                                        widget.onCancel();
                                      },
                                      text: widget.cancelText,
                                      options: FFButtonOptions(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                0.6,
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.045,
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            16, 0, 16, 0),
                                        iconPadding:
                                            const EdgeInsetsDirectional.fromSTEB(
                                                0, 0, 0, 0),
                                        color: widget.cancelColor,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              font: GoogleFonts.lexend(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontStyle,
                                              ),
                                              color: Colors.white,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                        elevation: 0,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
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

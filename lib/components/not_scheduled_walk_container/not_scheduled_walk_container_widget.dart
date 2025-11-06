import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'not_scheduled_walk_container_model.dart';
export 'not_scheduled_walk_container_model.dart';

class NotScheduledWalkContainerWidget extends StatefulWidget {
  const NotScheduledWalkContainerWidget({
    required this.userType,
    super.key,
  });

  final String userType;

  @override
  State<NotScheduledWalkContainerWidget> createState() =>
      _NotScheduledWalkContainerWidgetState();
}

class _NotScheduledWalkContainerWidgetState
    extends State<NotScheduledWalkContainerWidget> {
  late NotScheduledWalkContainerModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NotScheduledWalkContainerModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: 400,
            minHeight: MediaQuery.sizeOf(context).height * 0.7,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Sección del icono y texto
              Flexible(
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Container(
                          constraints: const BoxConstraints(
                            maxHeight: 300,
                          ),
                          child: Center(
                            child: FaIcon(
                              FontAwesomeIcons.dog,
                              color: FlutterFlowTheme.of(context).primary,
                              size: _calculateIconSize(context),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '¡No tienes ningún paseo activo!',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.lexend(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).primary,
                                fontSize: _calculateTextSize(context),
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Sección de botones
              Flexible(
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Primer botón
                      SizedBox(
                        width: double.infinity,
                        height: _calculateButtonHeight(context),
                        child: FFButtonWidget(
                          onPressed: () {
                            widget.userType == 'Dueño'
                                ? context.push('/owner/requestWalk')
                                : context.push('/walker/walksList');
                          },
                          text: widget.userType == 'Dueño'
                              ? 'Agendar Paseo'
                              : 'Ver Paseos Pendientes',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: _calculateButtonHeight(context),
                            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            color: FlutterFlowTheme.of(context).accent1,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  font: GoogleFonts.lexend(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                  fontSize: _calculateButtonTextSize(context),
                                ),
                            elevation: 0,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Segundo botón
                      SizedBox(
                        width: double.infinity,
                        height: _calculateButtonHeight(context),
                        child: FFButtonWidget(
                          onPressed: () async {
                            widget.userType == 'Dueño'
                                ? context.push('/owner/walksList')
                                : context.push('/walker/walksRecord',
                                    extra: {'userType': 'Paseador'});
                          },
                          text: widget.userType == 'Dueño'
                              ? 'Ver mi Agenda'
                              : 'Ver Historial',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: _calculateButtonHeight(context),
                            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  font: GoogleFonts.lexend(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                  fontSize: _calculateButtonTextSize(context),
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
            ],
          ),
        ),
      ),
    );
  }

  double _calculateIconSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 350) return 120;
    if (width < 400) return 150;
    return 180;
  }

  double _calculateTextSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 350) return 14;
    if (width < 400) return 16;
    return 18;
  }

  double _calculateButtonHeight(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    if (height < 600) return 36;
    return 40;
  }

  double _calculateButtonTextSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 350) return 12;
    if (width < 400) return 13;
    return 14;
  }
}
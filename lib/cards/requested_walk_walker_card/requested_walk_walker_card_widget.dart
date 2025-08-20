import 'package:dalk/backend/supabase/supabase.dart';
import '/components/pop_up_dog_profile/pop_up_dog_profile_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'requested_walk_walker_card_model.dart';
export 'requested_walk_walker_card_model.dart';

class RequestedWalkWalkerCardWidget extends StatefulWidget {
  const RequestedWalkWalkerCardWidget({
    super.key,
    required this.id,
    String? petName,
    String? dogOwner,
    required this.date,
    required this.time,
    String? status,
  })  : this.petName = petName ?? '[petName]',
        this.dogOwner = dogOwner ?? '[dogOwner]',
        this.status = status ?? '[status]';

  final int id;
  final String petName;
  final String dogOwner;
  final DateTime? date;
  final DateTime? time;
  final String status;

  @override
  State<RequestedWalkWalkerCardWidget> createState() =>
      _RequestedWalkWalkerCardWidgetState();
}

class _RequestedWalkWalkerCardWidgetState
    extends State<RequestedWalkWalkerCardWidget> {
  late RequestedWalkWalkerCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RequestedWalkWalkerCardModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).alternate,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(10, 0, 5, 0),
              child: Container(
                width: MediaQuery.sizeOf(context).width * 0.15,
                height: MediaQuery.sizeOf(context).height * 0.1,
                decoration: BoxDecoration(),
                child: Align(
                  alignment: AlignmentDirectional(0, 0),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxNHx8dXNlcnxlbnwwfHx8fDE3NDY1NTY1OTR8MA&ixlib=rb-4.1.0&q=80&w=1080',
                        width: MediaQuery.sizeOf(context).width,
                        height: MediaQuery.sizeOf(context).height,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 15),
              child: Container(
                width: MediaQuery.sizeOf(context).width * 0.4,
                decoration: BoxDecoration(),
                child: Align(
                  alignment: AlignmentDirectional(0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(-1, 0),
                        child: AutoSizeText(
                          widget!.status,
                          maxLines: 2,
                          minFontSize: 10,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.lexend(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    fontSize: 16,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 2, 0, 0),
                            child: AutoSizeText(
                              'Mascota:',
                              maxLines: 1,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.lexend(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(5, 2, 0, 0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                await showModalBottomSheet(
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  enableDrag: false,
                                  context: context,
                                  builder: (context) {
                                    return Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: PopUpDogProfileWidget(),
                                    );
                                  },
                                ).then((value) => safeSetState(() {}));
                              },
                              child: AutoSizeText(
                                widget!.petName,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.lexend(
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                      decoration: TextDecoration.underline,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 2, 0, 0),
                            child: AutoSizeText(
                              'Dueño:',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.lexend(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(5, 2, 0, 0),
                            child: Text(
                              widget!.dogOwner,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.lexend(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 2, 0, 0),
                            child: AutoSizeText(
                              'Fecha:',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.lexend(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(5, 2, 0, 0),
                            child: AutoSizeText(
                              dateTimeFormat("d/M/y", widget!.date),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.lexend(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 2, 0, 0),
                            child: AutoSizeText(
                              'Hora:',
                              maxLines: 1,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.lexend(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(5, 2, 0, 0),
                            child: AutoSizeText(
                              dateTimeFormat("Hm", widget!.time),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.lexend(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 90,
                decoration: BoxDecoration(),
                child: Align(
                  alignment: AlignmentDirectional(0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(  // Boton para abrir el chat con el dueño
                        child: Container(
                          height: MediaQuery.sizeOf(context).height,
                          decoration: BoxDecoration(),
                          child: Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: FlutterFlowIconButton(
                              borderRadius: 0,
                              buttonSize:
                                  MediaQuery.sizeOf(context).width * 0.18,
                              icon: Icon(
                                Icons.sms,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 30,
                              ),
                              onPressed: () {
                                print('openChat_btn pressed ...');
                              },
                            ),
                          ),
                        ),
                      ),
                      Flexible(  // Boton para aceptar el paseo
                        child: Container(
                          height: MediaQuery.sizeOf(context).height,
                          decoration: BoxDecoration(),
                          child: Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: FlutterFlowIconButton(
                              borderRadius: 0,
                              icon: Icon(
                                Icons.check_circle,
                                color: Color(0xFF3DBB0B),
                                size: 32,
                              ),
                              onPressed: () async {
                                await SupaFlow.client
                                    .from('walks')
                                    .update({'status': 'Aceptado'})
                                    .eq('id', widget.id);

                                // Invoca la función Edge para notificación push
                                await Supabase.instance.client.functions.invoke(
                                  'send-walk-notification',
                                  body: {
                                    'walk_id': widget.id,
                                    'new_status': 'Aceptado',
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Container( // Boton para cancelar o eliminar el chat
                        height: MediaQuery.sizeOf(context).height,
                        decoration: BoxDecoration(),
                        child: Align(
                          alignment: AlignmentDirectional(0, 0),
                          child: FlutterFlowIconButton(
                            borderRadius: 0,
                            icon: Icon(
                              Icons.cancel,
                              color: Color(0xFFC40606),
                              size: 32,
                            ),
                            onPressed: () async {
                              final response = await SupaFlow.client
                                  .from('walks')
                                  .select('status')
                                  .eq('id', widget.id)
                                  .single();

                              if (response != null) {
                                final currentStatus = response['status'];
                                if (currentStatus == 'Por confirmar') {
                                  await SupaFlow.client
                                    .from('walks')
                                    .update({'status': 'Rechazado'})
                                    .eq('id', widget.id);

                                  // Notificación: Rechazado
                                  await Supabase.instance.client.functions.invoke(
                                    'send-walk-notification',
                                    body: {
                                      'walk_id': widget.id,
                                      'new_status': 'Rechazado',
                                    },
                                  );
                                }
                                else if (currentStatus == 'Aceptado') {
                                  await SupaFlow.client
                                    .from('walks')
                                    .update({'status': 'Cancelado'})
                                    .eq('id', widget.id);

                                  // Notificación: Cancelado
                                  await Supabase.instance.client.functions.invoke(
                                    'send-walk-notification',
                                    body: {
                                      'walk_id': widget.id,
                                      'new_status': 'Cancelado',
                                    },
                                  );
                                }
                                else if (currentStatus == 'Rechazado' || currentStatus == 'Cancelado') {
                                  await SupaFlow.client
                                    .from('walks')
                                    .delete()
                                    .eq('id', widget.id);

                                  // Si quieres notificar el borrado, puedes agregar aquí otra invocación
                                  // await Supabase.instance.client.functions.invoke(
                                  //   'send-walk-notification',
                                  //   body: {
                                  //     'walk_id': widget.id,
                                  //     'new_status': 'Eliminado',
                                  //   },
                                  // );
                                }
                              }
                            }
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
    );
  }
}

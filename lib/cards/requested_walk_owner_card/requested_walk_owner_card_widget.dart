import 'package:dalk/backend/supabase/supabase.dart';
import 'package:dalk/common/chat/chat_widget.dart';
import 'package:dalk/components/pop_up_confirm_dialog/pop_up_confirm_dialog_widget.dart';
import '/components/pop_up_dog_profile/pop_up_dog_profile_widget.dart';
import '/components/pop_up_dog_walker_profile/pop_up_dog_walker_profile_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/auth/supabase_auth/auth_util.dart'; 
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'requested_walk_owner_card_model.dart';
export 'requested_walk_owner_card_model.dart';

class RequestedWalkOwnerCardWidget extends StatefulWidget {
  const RequestedWalkOwnerCardWidget({
    super.key,
    required this.id,
    String? status,
    String? petName,
    String? dogWalker,
    required this.date,
    required this.time,
    required this.walkerId,
    required this.ownerId,
    required this.photoUrl
  })  : status = status ?? '[status]',
        petName = petName ?? '[petName]',
        dogWalker = dogWalker ?? '[walkerName]';

  final int id;
  final String status;
  final String petName;
  final String dogWalker;
  final DateTime? date;
  final DateTime? time;
  final String photoUrl;
  //chat
  final String walkerId;
  final String ownerId;


  @override
  State<RequestedWalkOwnerCardWidget> createState() =>
      _RequestedWalkOwnerCardWidgetState();
}

class _RequestedWalkOwnerCardWidgetState
    extends State<RequestedWalkOwnerCardWidget> {
  late RequestedWalkOwnerCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RequestedWalkOwnerCardModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  Future<void> deleteWalk(BuildContext context, int id, String currentUserUid) async {
    try {
      final response = await SupaFlow.client
          .from('walks')
          .select('owner_id, walker_id, status')
          .eq('id', id)
          .single();

      final dbOwnerId = response['owner_id'];
      final dbWalkerId = response['walker_id'];

      if ((currentUserUid == dbOwnerId || currentUserUid == dbWalkerId)) {
        await SupaFlow.client.from('walks').delete().eq('id', id);
      }
      Navigator.pop(context);
    } catch (e) {
      handleError(context, e);
    }
  }


  Future<void> cancelWalk(BuildContext context, int id) async {
    try {
      final response = await SupaFlow.client
          .from('walks')
          .select('status')
          .eq('id', id)
          .single();

      final currentStatus = response['status'];

      if (currentStatus == 'Por confirmar' || currentStatus == 'Aceptado') {
        await SupaFlow.client
            .from('walks')
            .update({'status': 'Cancelado'})
            .eq('id', id);

      if (currentStatus == 'Aceptado') {
          await Supabase.instance.client.functions.invoke(
            'send-walk-notification',
            body: {
              'walk_id': id,
              'new_status': 'Cancelado',
            },
          );
        }
      }
        Navigator.pop(context);
    } catch (e) {
      handleError(context, e);
    }
  }

  void handleError(BuildContext context, dynamic e) {
    if (e.toString().contains('foreign key') ||
        e.toString().contains('violates')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede eliminar: hay datos relacionados'),
          backgroundColor: Colors.orange,
        ),
      );
    }
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
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).width,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Image.network(
                    widget.photoUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 15),
                child: Container(
                  decoration: const BoxDecoration(),
                  child: Align(
                    alignment: const AlignmentDirectional(0, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: const AlignmentDirectional(-1, 0),
                          child: AutoSizeText(
                            widget!.status,
                            maxLines: 2,
                            minFontSize: 10,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
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
                              padding: const EdgeInsetsDirectional.fromSTEB(0, 2, 0, 0),
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
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(5, 2, 0, 0),
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
                                        padding:
                                            MediaQuery.viewInsetsOf(context),
                                        child: const PopUpDogProfileWidget(),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                },
                                child: AutoSizeText(
                                  widget.petName,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.lexend(
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
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
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 2, 0, 0),
                              child: AutoSizeText(
                                'Paseador:',
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
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(5, 2, 0, 0),
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
                                        padding:
                                            MediaQuery.viewInsetsOf(context),
                                        child: PopUpDogWalkerProfileWidget(),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                },
                                child: Text(
                                  widget!.dogWalker,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.lexend(
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
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
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 2, 0, 0),
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
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(5, 2, 0, 0),
                              child: AutoSizeText(
                                dateTimeFormat("d/M/y", widget.date),
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
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 2, 0, 0),
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
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(5, 2, 0, 0),
                              child: AutoSizeText(
                                dateTimeFormat("Hm", widget.time),
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
            ),
            Container(
              width: MediaQuery.sizeOf(context).width * 0.25,
              height: 90,
              decoration: BoxDecoration(),
              child: Align(
                alignment: AlignmentDirectional(0, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        width: 50,
                        height: MediaQuery.sizeOf(context).height,
                        decoration: BoxDecoration(),
                        child: Align(
                          alignment: AlignmentDirectional(0, 0),
                          child: FlutterFlowIconButton(
                            borderRadius: 0,
                            buttonSize: MediaQuery.sizeOf(context).width * 0.18,
                            icon: Icon(
                              Icons.sms,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 30,
                            ),

                            onPressed: () async {
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatWidget(
                                    walkerId: widget.walkerId,
                                    ownerId: widget.ownerId,   
                                  ),
                                ),
                              );
                              
                            },
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        width: 50,
                        height: MediaQuery.sizeOf(context).height,
                        decoration: BoxDecoration(),
                        child: Align(
                          alignment: AlignmentDirectional(0, 0),
                          child: FlutterFlowIconButton(
                            borderRadius: 0,
                            buttonSize: MediaQuery.sizeOf(context).width * 0.18,
                            icon: Icon(
                              Icons.cancel,
                              color: FlutterFlowTheme.of(context).error,
                              size: 32,
                            ),
                            onPressed: () async {
                              try {
                                final response = await SupaFlow.client
                                  .from('walks')
                                  .select('status')
                                  .eq('id', widget.id)
                                  .single();

                                final currentStatus = response['status'];
                                final bool isCancelled = currentStatus == 'Cancelado' || currentStatus == 'Rechazado';
                                
                                final Map<String, dynamic> dialogData = isCancelled 
                                  ? {
                                      'title': "Eliminar paseo",
                                      'message': "¿Estás seguro de que deseas eliminar este paseo?",
                                      'confirmText': "Eliminar paseo", 
                                      'icon': Icons.delete_forever_rounded,
                                      'onConfirm': () => deleteWalk(context, widget.id, currentUserUid),
                                    }
                                  : {
                                      'title': "Cancelar solicitud",
                                      'message': "¿Estás seguro de que deseas cancelar este paseo?",
                                      'confirmText': "Cancelar paseo",
                                      'icon': Icons.cancel_rounded,
                                      'onConfirm': () => cancelWalk(context, widget.id),
                                    };

                                showDialog(
                                  context: context,
                                  builder: (_) => PopUpConfirmDialogWidget(
                                    title: dialogData['title'],
                                    message: dialogData['message'],
                                    confirmText: dialogData['confirmText'],
                                    cancelText: "Cerrar",
                                    confirmColor: FlutterFlowTheme.of(context).error,
                                    cancelColor: FlutterFlowTheme.of(context).accent1,
                                    icon: dialogData['icon'],
                                    iconColor: FlutterFlowTheme.of(context).error,
                                    onConfirm: dialogData['onConfirm'],
                                    onCancel: () => Navigator.pop(context),
                                  ), 
                                );

                              } catch (e) {
                                handleError(context, e);                         
                              }
                              
                              
                            },
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

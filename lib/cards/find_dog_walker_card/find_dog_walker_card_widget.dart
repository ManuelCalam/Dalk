import 'package:dalk/auth/supabase_auth/auth_util.dart';
import 'package:dalk/backend/supabase/database/database.dart';
import 'package:dalk/common/chat/chat_widget.dart';
import 'package:dalk/components/pop_up_confirm_dialog/pop_up_confirm_dialog_widget.dart';
import 'package:dalk/dog_owner/set_walk_schedule/set_walk_schedule_widget.dart';
import 'package:dalk/dog_owner/walks_dog_owner/walks_dog_owner_widget.dart';

import '/components/pop_up_dog_walker_profile/pop_up_dog_walker_profile_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

export 'find_dog_walker_card_model.dart';

class FindDogWalkerCardWidget extends StatelessWidget {
  final String nombre;
  final String precio;
  final String calificacion;
  final String fotoUrl;
  final DateTime? date;
  final DateTime? time;
  final int? addressId;
  final int? petId;
  final String uuidPaseador;
  final int walkDuration;
  final String instructions;
  final bool recomendado;

  const FindDogWalkerCardWidget({
    required this.nombre,
    required this.precio,
    required this.calificacion,
    required this.fotoUrl,
    required this.date,
    required this.time,
    required this.addressId,
    required this.petId,
    required this.uuidPaseador,
    required this.walkDuration,
    required this.instructions,
    this.recomendado = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final primerNombre = nombre.split(" ").first;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).alternate,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: recomendado ? Colors.amber.shade50 : FlutterFlowTheme.of(context).alternate,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 5, 0),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.15,
                    height: MediaQuery.sizeOf(context).height * 0.1,
                    decoration: const BoxDecoration(),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).width,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Image.network(
                        fotoUrl,
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: const AlignmentDirectional(-1, 1),
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
                                        child: PopUpDogWalkerProfileWidget(walkerId: uuidPaseador),
                                      );
                                    },
                                  );
                                },
                                child: AutoSizeText(
                                  primerNombre,
                                  textAlign: TextAlign.start,
                                  maxLines: 2,
                                  minFontSize: 12,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.lexend(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        fontSize: 18,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                        decoration: TextDecoration.underline,
                                      ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  Icons.paid_sharp,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 24,
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      5, 2, 0, 0),
                                  child: AutoSizeText(
                                     '$precio MXN', 
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
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
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
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
                  decoration: const BoxDecoration(),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFE2B433),
                        size: 24,
                      ),
                      Align(
                        alignment: const AlignmentDirectional(-1, 0),
                        child: AutoSizeText(
                          calificacion,
                          maxLines: 1,
                          minFontSize: 10,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.lexend(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    fontSize: 20,
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
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                  child: Container(
                    decoration: const BoxDecoration(),
                    alignment: const AlignmentDirectional(0, 0),
                    child: FlutterFlowIconButton(
                      borderRadius: 0,
                      icon: Icon(
                        Icons.sms,
                        color: FlutterFlowTheme.of(context).primary,
                        size: 35,
                      ),
                         onPressed: () {
                          final currentUserId = SupaFlow.client.auth.currentUser?.id;
                            context.push(
                              '/owner/chat',
                              extra: <String, dynamic>{
                                'walkerId': uuidPaseador, 
                                'ownerId': currentUserId,
                              },
                            );
                          },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 15),
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 35,
                decoration: const BoxDecoration(),
                child: FFButtonWidget(
                  onPressed: () async {
                        // Unir fecha y hora para el registro de startTime como timestamp
                          final DateTime? startDateTime = (date != null && time != null)
                          ? DateTime(
                              date!.year,
                              date!.month,
                              date!.day,
                              time!.hour,
                              time!.minute,
                              time!.second,
                            )
                          : null;

                          DateTime? endDateTime;
                          if (startDateTime != null) {
                            endDateTime = startDateTime.add(Duration(minutes: walkDuration));
                          }

                          final jwt = Supabase.instance.client.auth.currentSession?.accessToken;
                            if (jwt == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Error: Usuario no autenticado')),
                              );
                              return;
                            }

                            try {
                              print(' Iniciando solicitud de paseo...');

                              if (petId == null || addressId == null || currentUserUid.isEmpty) {
                                throw Exception('Datos insuficientes para crear el paseo');
                              } else {
                                try {
                                  final response = await Supabase.instance.client
                                      .from('walks')
                                      .insert({
                                        'dog_id': petId,
                                        'walker_id': uuidPaseador,
                                        'owner_id': currentUserUid,
                                        'address_id': addressId,
                                        'status': 'Por confirmar',
                                        'startTime': startDateTime?.toIso8601String(),
                                        'endTime': endDateTime != null
                                          ? '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}:00'
                                          : null,
                                          
                                        'walk_duration_minutes': walkDuration,
                                        'walker_instructions': instructions.trim().isEmpty ? null : instructions.trim(),
                                        'payment_status': 'Pendiente'
                                      })
                                      .select('id')
                                      .single();

                                  //Alias para no romper el código de notificaciones
                                  final insertResponse = response;

                                  // Convertir el ID a int de manera segura
                                  final walkIdRaw = insertResponse['id'];
                                  final walkId = walkIdRaw is int
                                      ? walkIdRaw
                                      : int.parse(walkIdRaw.toString());
                                  print('Paseo insertado con ID: $walkId');

                                  // 2. Obtener datos adicionales para la notificación
                                  final userResponse = await Supabase.instance.client
                                      .from('users')
                                      .select('name')
                                      .eq('uuid', currentUserUid)
                                      .single();

                                  final petResponse = await Supabase.instance.client
                                      .from('pets')
                                      .select('name')
                                      .eq('id', petId!)
                                      .single();

                                  if (userResponse['name'] == null || petResponse['name'] == null) {
                                    throw Exception(
                                      'Error: No se pudieron obtener los datos del usuario o mascota',
                                    );
                                  }

                                  final ownerName = userResponse['name'].toString();
                                  final petName = petResponse['name'].toString();
                                  final dateString = date != null
                                      ? '${date!.day}/${date!.month}/${date!.year}'
                                      : 'fecha por confirmar';

                                  // print(
                                  //   'Datos para notificación: Owner: $ownerName, Pet: $petName, Date: $dateString',
                                  // );

                                  // 3. Llamar a la Edge Function para enviar notificación
                                  final notificationPayload = {
                                    'walk_id': walkId,
                                    'new_status': 'Solicitado',
                                    'actor_name': currentUserUid,
                                    'pet_name': petName,
                                    'date': dateString,
                                  };


                                  final notificationResponse = await Supabase.instance.client.functions
                                      .invoke('send-walk-notification', body: notificationPayload);

                                  // print('Respuesta de notificación: ${notificationResponse.data}');
                                  // print('Tipo de respuesta: ${notificationResponse.data.runtimeType}');

                                  // Verificar el tipo de dato antes de acceder
                                  // dynamic responseData = notificationResponse.data;
                                  // if (responseData != null) {
                                  //   if (responseData is Map<String, dynamic>) {
                                  //     if (responseData['success'] == true) {
                                  //       print('Notificación enviada exitosamente');
                                  //     } else {
                                  //       print('Respuesta de notificación: $responseData');
                                  //     }
                                  //   } else {
                                  //     print(' Tipo de respuesta inesperado: ${responseData.runtimeType}');
                                  //     print(' Contenido: $responseData');
                                  //   }
                                  // } else {
                                  //   print(' Respuesta nula');
                                  // }

                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   SnackBar(content: Text('¡Paseo solicitado!')),
                                  // );

                                  // ------------------------------------
                                  // Confirmación de Paseo Registrado
                                  // ------------------------------------
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: PopUpConfirmDialogWidget(
                                          title: "Paseo registrado" ,
                                          message: "¡Se ha registrado el paseo exitosamente!",
                                          confirmText: "Volver a agendar",
                                          cancelText: "Ver agenda",
                                          confirmColor: FlutterFlowTheme.of(context).accent1,
                                          cancelColor: FlutterFlowTheme.of(context).primary,
                                          icon: Icons.check_circle,
                                          iconColor: FlutterFlowTheme.of(context).success,
                                          onConfirm: () {
                                            context.pop();
                                            context.push('/owner/requestWalk');
                                          },
                                          onCancel: () {
                                            context.pop();
                                            context.push('/owner/walksList');
                                          },
                                        ),
                                      );
                                    },
                                  );



                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error al registrar solicitud: $e')),
                                  );
                                  print(e);
                                }
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al registrar solicitud: $e')),
                              );
                              print(e);
                            }
                      },
                  text: 'Solicitar paseo',
                  icon: const FaIcon(
                    FontAwesomeIcons.solidHandPointUp,
                    size: 20,
                  ),
                  options: FFButtonOptions(
                    height: 40,
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                    iconAlignment: IconAlignment.end,
                    iconPadding: const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
                          fontWeight: FlutterFlowTheme.of(context)
                              .titleSmall
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).titleSmall.fontStyle,
                        ),
                    elevation: 0,
                    borderRadius: BorderRadius.circular(8),
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
import 'package:dalk/backend/supabase/supabase.dart';
import 'package:dalk/components/pop_up_confirm_dialog/pop_up_confirm_dialog_widget.dart';
import 'package:dalk/components/scheduled_walk_container/scheduled_walk_container_widget.dart';
import 'package:geolocator/geolocator.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pop_up_walk_options_model.dart';
export 'pop_up_walk_options_model.dart';


typedef WalkCompletionCallback = Future<void> Function(); 

class PopUpWalkOptionsWidget extends StatefulWidget {
  const PopUpWalkOptionsWidget({
    super.key,
    required this.walkId,
    required this.usertype,
    this.onWalkCompletion,
  });

  final int walkId;
  final String? usertype;
  final WalkCompletionCallback? onWalkCompletion;

  @override
  State<PopUpWalkOptionsWidget> createState() => _PopUpWalkOptionsWidgetState();
}

class _PopUpWalkOptionsWidgetState extends State<PopUpWalkOptionsWidget> {
  late PopUpWalkOptionsModel _model;
  final currentUserId = SupaFlow.client.auth.currentUser?.id;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PopUpWalkOptionsModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  //Obtener información del View walks_with_names
  Future<Map<String, dynamic>?> fetchWalkInfoFromView(int walkId) async {
    final response = await SupaFlow.client
        .from('walks_with_names')
        .select()
        .eq('id', walkId)
        .limit(1)
        .maybeSingle();

    return response;
  }

  Future<bool> _checkAndRequestAlwaysPermission() async {
    // 1. Verificar el permiso actual
    LocationPermission permission = await Geolocator.checkPermission();

    bool requiresUpgrade = permission == LocationPermission.whileInUse || permission == LocationPermission.denied;

    if (requiresUpgrade) {
      // 2. Mostrar Diálogo de Explicación y Redirección
      bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => PopUpConfirmDialogWidget(
          title: "Permiso de Ubicación Crítico",
          message:
              "Para que el dueño pueda seguir el paseo y garantizar el servicio, necesitamos permiso de ubicación 'Permitir siempre'. Esto nos permite rastrear tu ubicación incluso cuando la aplicación no está abierta. ¿Deseas ir a configuración para cambiarlo?",
          confirmText: "Ir a Configuración",
          cancelText: "Cerrar",
          confirmColor: FlutterFlowTheme.of(context).primary,
          cancelColor: FlutterFlowTheme.of(context).accent1,
          icon: Icons.location_on,
          iconColor: FlutterFlowTheme.of(context).primary,
          onConfirm: () => Navigator.pop(context, true),
          onCancel: () => Navigator.pop(context, false), 
        ),
      );

      if (confirmed == true) {
        // 3. Redirigir a Configuración de la App
        await Geolocator.openAppSettings();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Busca el permiso de Ubicación y selecciona 'Permitir siempre'."),
            duration: Duration(seconds: 5),
          ),
        );
        return false; 
      } else {
        return false; 
      }
    }

    // El permiso ya es "AllowAlways" o "deniedForever" 
    return true; 
  }
  

  // Helper Function: Construye un botón con el formato necesario
  Widget _buildActionButton({
    required BuildContext context,
    required String text,
    required Color color,
    required VoidCallback onPressed,
    IconData? icon,
    bool isPrimary = false, 
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
      child: FFButtonWidget(
        onPressed:  onPressed, 
        text: text,
        options: FFButtonOptions(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height * 0.05,
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
          iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
          iconAlignment: IconAlignment.end,
          color: color, 
          textStyle: FlutterFlowTheme.of(context)
              .titleSmall
              .override(
                font: GoogleFonts.lexend(
                  fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                ),
                color: Colors.white,
                letterSpacing: 0.0,
                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
              ),
          elevation: 0,
          borderRadius: BorderRadius.circular(8),
        ),
        icon: icon != null ? Icon(icon, color: Colors.white) : null,
      ),
    );
  }

  // Función central: Determina y retorna la lista de botones
  List<Widget> _getButtonsBasedOnStatus(
    BuildContext context,
    String? userType,
    String walkStatus,
  ) {
    final List<Widget> buttons = [];

    // ------------------------------------
    // LÓGICA DEL USUARIO DUEÑO ("Dueño")
    // ------------------------------------
    if (userType == 'Dueño') {
      // if (walkStatus == 'Por confirmar' || walkStatus == 'Aceptado' || walkStatus == 'En curso') {
      if (walkStatus == 'Por confirmar' || walkStatus == 'Aceptado') {
        // Estatus "Por confirmar" o "Aceptado" o "En curso": Botón "Cancelar"
        buttons.add(_buildActionButton(
          context: context,
          text: 'Cancelar paseo',
          color: FlutterFlowTheme.of(context).error,
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => PopUpConfirmDialogWidget(
                title: "Cancelar paseo",
                message: "¿Estás seguro de que deseas cancelar este paseo?",
                confirmText: "Cancelar paseo",
                cancelText: "Cerrar",
                confirmColor: FlutterFlowTheme.of(context).error,
                cancelColor: FlutterFlowTheme.of(context).accent1,
                icon: Icons.cancel_rounded,
                iconColor: FlutterFlowTheme.of(context).error,
                onConfirm: () async => {
                  await SupaFlow.client
                    .from('walks')
                    .update({'status': 'Cancelado'})
                    .eq('id', widget.walkId),

                  //NECESARIO: Doble pop para cerrar el showDialog y el popUpWindow
                  Navigator.pop(context),
                  Navigator.pop(context),

                  //Envío de notificacion después de cerrar los menús
                  await Supabase.instance.client.functions.invoke(
                    'send-walk-notification',
                    body: {
                      'walk_id': widget.walkId,
                      'new_status': 'Cancelado',
                    },
                  )
                },
                onCancel: () => Navigator.pop(context),
              ), 
            );

          },
          icon: Icons.cancel_rounded,
        ));
      } else if (walkStatus == 'Rechazado' || walkStatus == 'Cancelado') {
        // Estatus "Rechazado" o "Cancelado": Botón "Borrar"
        buttons.add(_buildActionButton(
          context: context,
          text: 'Borrar paseo',
          color: FlutterFlowTheme.of(context).error, 
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => PopUpConfirmDialogWidget(
                title: "Eliminar paseo",
                message: "¿Estás seguro de que deseas eliminar este paseo?",
                confirmText: "Eliminar paseo",
                cancelText: "Cerrar",
                confirmColor: FlutterFlowTheme.of(context).error,
                cancelColor: FlutterFlowTheme.of(context).accent1,
                icon: Icons.delete_forever_rounded,
                iconColor: FlutterFlowTheme.of(context).error,
                onConfirm: () async => {
                  await SupaFlow.client.from('walks').delete().eq('id', widget.walkId),

                  //NECESARIO: Doble pop para cerrar el showDialog y el popUpWindow
                  Navigator.pop(context),
                  Navigator.pop(context)
                },
                onCancel: () => Navigator.pop(context),
              ), 
            );
          },
          icon: Icons.delete_forever_rounded,
        ));
      } 

    }

    // ------------------------------------
    // LÓGICA DEL USUARIO PASEADOR ("Paseador")
    // ------------------------------------
    else if (userType == 'Paseador') {
      if (walkStatus == 'Por confirmar') {
        // Estatus "Por confirmar": "Aceptar" y "Rechazar"
        
        // Botón 1: Aceptar
        buttons.add(_buildActionButton(
        context: context,
        text: 'Aceptar paseo',
        color: FlutterFlowTheme.of(context).success,
        onPressed: () async {
          // VERIFICAR/SOLICITAR PERMISO DE UBICACIÓN "PERMITIR SIEMPRE"
          final canProceed = await _checkAndRequestAlwaysPermission();
          
          if (!canProceed) {
            return; 
          }

          // PROCEDER CON EL DIÁLOGO DE CONFIRMACIÓN DEL PASEO
          showDialog(
            context: context,
            builder: (_) => PopUpConfirmDialogWidget(
              title: "Aceptar paseo",
              message: "¿Estás seguro de que deseas aceptar este paseo?",
              confirmText: "Aceptar paseo",
              cancelText: "Cerrar",
              confirmColor: FlutterFlowTheme.of(context).success,
              cancelColor: FlutterFlowTheme.of(context).accent1,
              icon: Icons.check_circle_rounded,
              iconColor: FlutterFlowTheme.of(context).success,
              onConfirm: () async {
                await SupaFlow.client
                    .from('walks')
                    .update({'status': 'Aceptado'})
                    .eq('id', widget.walkId);

                // NECESARIO: Doble pop para cerrar el showDialog y el popUpWindow
                Navigator.pop(context); 
                Navigator.pop(context); 

                // Envío de notificacion después de cerrar los menús
                await Supabase.instance.client.functions.invoke(
                  'send-walk-notification',
                  body: {
                    'walk_id': widget.walkId,
                    'new_status': 'Aceptado',
                  },
                );
              },
              onCancel: () => Navigator.pop(context),
            ),
          );
        },
        icon: Icons.check_circle,
      ));

        // Botón 2: Rechazar
        buttons.add(_buildActionButton(
          context: context,
          text: 'Rechazar paseo',
          color: FlutterFlowTheme.of(context).error,
          onPressed: () {
           showDialog(
              context: context,
              builder: (_) => PopUpConfirmDialogWidget(
                title: "Rechazar paseo",
                message: "¿Estás seguro de que deseas rechazar este paseo?",
                confirmText: "Rechazar paseo",
                cancelText: "Cerrar",
                confirmColor: FlutterFlowTheme.of(context).error,
                cancelColor: FlutterFlowTheme.of(context).accent1,
                icon: Icons.cancel_rounded,
                iconColor: FlutterFlowTheme.of(context).error,
                onConfirm: () async => {
                  await SupaFlow.client
                    .from('walks')
                    .update({'status': 'Rechazado'})
                    .eq('id', widget.walkId),


                  //NECESARIO: Doble pop para cerrar el showDialog y el popUpWindow
                  Navigator.pop(context),
                  Navigator.pop(context),

                  //Envío de notificacion después de cerrar los menús
                  await Supabase.instance.client.functions.invoke(
                    'send-walk-notification',
                    body: {
                      'walk_id': widget.walkId,
                      'new_status': 'Rechazado',
                    },
                  )
                },
                onCancel: () => Navigator.pop(context),
              ), 
            );

          },
          icon: Icons.cancel_rounded,
        ));
        
      } else if (walkStatus == 'Aceptado') {
        // Estatus "Aceptado": "Iniciar Viaje" y "Cancelar"
        
        // Botón 1: Iniciar paseo
        buttons.add(_buildActionButton(
          context: context,
          text: 'Iniciar paseo',
          color: FlutterFlowTheme.of(context).success, 
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => PopUpConfirmDialogWidget(
                title: "Iniciar paseo",
                message: "¿Estás seguro de que deseas iniciar este paseo?",
                confirmText: "Iniciar paseo",
                cancelText: "Cerrar",
                confirmColor: FlutterFlowTheme.of(context).success,
                cancelColor: FlutterFlowTheme.of(context).accent1,
                icon: FontAwesomeIcons.dog,
                iconColor: FlutterFlowTheme.of(context).primary,
                onConfirm: () async => {
                  

                  await SupaFlow.client
                    .from('walks')
                    .update({'status': 'En curso'})
                    .eq('id', widget.walkId),

                  context.pushNamed(
                    '_initialize',
                    queryParameters: {'initialPage': 'CurrentWalk'},
                  ),
                  //NECESARIO: Doble pop para cerrar el showDialog y el popUpWindow
                  Navigator.pop(context),
                  Navigator.pop(context),

                  await SupaFlow.client
                    .from('users') 
                    .update({'current_walk_id': widget.walkId}) 
                    .eq('uuid', currentUserId!) 
                    .maybeSingle(),


                  //Envío de notificacion después de cerrar los menús
                  await Supabase.instance.client.functions.invoke(
                    'send-walk-notification',
                    body: {
                      'walk_id': widget.walkId,
                      'new_status': 'En curso',
                    },
                  ),
                },
                onCancel: () => Navigator.pop(context),
              ), 
            );
          },
          icon: FontAwesomeIcons.dog,
        ));

        // Botón 2: Cancelar 
        buttons.add(_buildActionButton(
          context: context,
          text: 'Cancelar paseo',
          color: FlutterFlowTheme.of(context).error,
          onPressed: () {
             showDialog(
              context: context,
              builder: (_) => PopUpConfirmDialogWidget(
                title: "Cancelar paseo",
                message: "¿Estás seguro de que deseas cancelar este paseo?",
                confirmText: "Cancelar paseo",
                cancelText: "Cerrar",
                confirmColor: FlutterFlowTheme.of(context).error,
                cancelColor: FlutterFlowTheme.of(context).accent1,
                icon: Icons.cancel_rounded,
                iconColor: FlutterFlowTheme.of(context).error,
                onConfirm: () async => {
                  await SupaFlow.client
                    .from('walks')
                    .update({'status': 'Cancelado'})
                    .eq('id', widget.walkId),

                  //NECESARIO: Doble pop para cerrar el showDialog y el popUpWindow
                  Navigator.pop(context),
                  Navigator.pop(context),
                  
                  //Envío de notificacion después de cerrar los menús
                  await Supabase.instance.client.functions.invoke(
                          'send-walk-notification',
                          body: {
                            'walk_id': widget.walkId,
                            'new_status': 'Cancelado',
                          },
                  )
                },
                onCancel: () => Navigator.pop(context),
              ), 
            );
          },
          icon: Icons.cancel_rounded,
        ));
        
      } else if (walkStatus == 'Rechazado' || walkStatus == 'Cancelado') {
        // Estatus "Rechazado" o "Cancelado": Botón "Borrar"
        buttons.add(_buildActionButton(
          context: context,
          text: 'Borrar paseo',
          color: FlutterFlowTheme.of(context).error,
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => PopUpConfirmDialogWidget(
                title: "Eliminar paseo",
                message: "¿Estás seguro de que deseas eliminar este paseo?",
                confirmText: "Eliminar paseo",
                cancelText: "Cerrar",
                confirmColor: FlutterFlowTheme.of(context).error,
                cancelColor: FlutterFlowTheme.of(context).accent1,
                icon: Icons.delete_forever_rounded,
                iconColor: FlutterFlowTheme.of(context).error,
                onConfirm: () async => {
                  await SupaFlow.client.from('walks').delete().eq('id', widget.walkId),

                  //NECESARIO: Doble pop para cerrar el showDialog y el popUpWindow
                  Navigator.pop(context),
                  Navigator.pop(context)
                },
                onCancel: () => Navigator.pop(context),
              ), 
            );
          },
          icon: Icons.delete_forever_rounded,
        ));
      } else if(walkStatus == 'En curso'){
        // Estatus "En curso": "Terminar" y "Cancelar"
        
        // Botón 1: Terminar
        buttons.add(_buildActionButton(
          context: context,
          text: 'Terminar paseo',
          color: FlutterFlowTheme.of(context).primary, 
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => PopUpConfirmDialogWidget(
                title: "Terminar paseo",
                message: "¿Estás seguro de que deseas terminar este paseo?",
                confirmText: "Terminar paseo",
                cancelText: "Cerrar",
                confirmColor: FlutterFlowTheme.of(context).primary,
                cancelColor: FlutterFlowTheme.of(context).accent1,
                icon: Icons.check_circle_rounded,
                iconColor: FlutterFlowTheme.of(context).primary,

            onConfirm: () async {
              // ✅ CAMBIO CLAVE 3: Llamamos a la función usando ?.call()
              // Esto solo ejecuta la función si widget.onWalkCompletion NO es null.
              await widget.onWalkCompletion?.call(); 
              
              // Cerramos el PopUp, usando el contexto del diálogo
              if (Navigator.canPop(context)) {
                  Navigator.pop(context); 
              }
            },


                onCancel: () => Navigator.pop(context),
              ), 
            );

          },
          icon: Icons.check_circle,
        ));


        // // Botón 2: Cancelar (Color rojo)
        // buttons.add(_buildActionButton(
        //   context: context,
        //   text: 'Cancelar paseo',
        //   color: FlutterFlowTheme.of(context).error,
        //   onPressed: () {
        //      showDialog(
        //       context: context,
        //       builder: (_) => PopUpConfirmDialogWidget(
        //         title: "Cancelar paseo",
        //         message: "¿Estás seguro de que deseas cancelar este paseo?",
        //         confirmText: "Cancelar paseo",
        //         cancelText: "Cerrar",
        //         confirmColor: FlutterFlowTheme.of(context).error,
        //         cancelColor: FlutterFlowTheme.of(context).accent1,
        //         icon: Icons.cancel_rounded,
        //         iconColor: FlutterFlowTheme.of(context).error,
        //         onConfirm: () async => {
        //           await SupaFlow.client
        //             .from('walks')
        //             .update({'status': 'Cancelado'})
        //             .eq('id', widget.walkId),

        //           //NECESARIO: Doble pop para cerrar el showDialog y el popUpWindow
        //           Navigator.pop(context),
        //           Navigator.pop(context),
                  
        //           //Envío de notificacion después de cerrar los menús
        //           await Supabase.instance.client.functions.invoke(
        //             'send-walk-notification',
        //             body: {
        //               'walk_id': widget.walkId,
        //               'new_status': 'Cancelado',
        //             },
        //           )
        //         },
        //         onCancel: () => Navigator.pop(context),
        //       ), 
        //     );
        //   },
        //   icon: Icons.cancel_rounded,
        // ));
      }
    }

    return buttons;
  }


  @override
  Widget build(BuildContext context) {
    final int walkId = widget.walkId; 

    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchWalkInfoFromView(walkId),
      builder: (context, snapshot) {
        // -----------------------------------------------------
        // MANEJO DE ESTADOS (Cargando, Error, Datos no encontrados)
        // -----------------------------------------------------

        if (snapshot.connectionState == ConnectionState.waiting) {
          // Muestra un indicador de carga centrado mientras espera
          return Container(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height * 0.73,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).tertiary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final walkInfo = snapshot.data;

        if (snapshot.hasError || walkInfo == null || walkInfo.isEmpty) {
          // Muestra un mensaje de error si la carga falla o si los datos no se encuentran
          return Container(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height * 0.73,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).tertiary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
            child: Center(
              child: Text(
                'Error al cargar la información del paseo.',
                style: FlutterFlowTheme.of(context).headlineMedium,
              ),
            ),
          );
        }
        
        // -----------------------------------------------------
        // CONSTRUCCIÓN FINAL DEL WIDGET (Datos disponibles)
        // -----------------------------------------------------

        final DateTime? startTime = DateTime.tryParse(walkInfo['startTime'] as String? ?? '');

        
        final String dogName = walkInfo['pet_name'] as String? ?? 'N/A';
        final String userName = widget.usertype == 'Dueño' ? walkInfo['walker_name'] : walkInfo['owner_name'];
        final String photoUrl = walkInfo['dog_photo_url'] as String? ?? 'N/A';
        final String time = startTime != null  ? DateFormat('HH:mm').format(startTime)  : 'N/A';        
        final String date = startTime != null ? DateFormat('dd/MM/yyyy').format(startTime) : 'N/A';        
        final String address = walkInfo['owner_address'] as String? ?? 'N/A';
        final String duration = (walkInfo['walk_duration_minutes'] as int?)?.toString() ?? 'N/A';
        final String instructions = walkInfo['walker_instructions'] as String? ?? 'N/A';
        final String fee = (walkInfo['fee'] as int?)?.toString() ?? 'N/A';
        final String walkStatus = walkInfo['status'] as String? ?? 'N/A';
        
        
        
        return Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height * 0.73,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).tertiary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 0.92,
                  height: MediaQuery.sizeOf(context).height * 0.05,
                  decoration: const BoxDecoration(),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      FlutterFlowIconButton(
                        borderRadius: 8,
                        buttonSize: 40,
                        icon: Icon(
                          Icons.chat,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 28,
                        ),
                        onPressed: () {
                          print('IconButton pressed ...');
                        },
                      ),
                      Expanded(
                        child: Align(
                          alignment: const AlignmentDirectional(1, 0),
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
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.9,
                    decoration: const BoxDecoration(),
                    child: SingleChildScrollView(
                      primary: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                          AutoSizeText(
                            dogName,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.lexend(
                                    fontWeight: FontWeight.bold,
                                    fontStyle:
                                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontSize: 32,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle:
                                      FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                ),
                          ),
                          AutoSizeText(
                            userName,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.lexend(
                                    fontWeight: FontWeight.bold,
                                    fontStyle:
                                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).accent1,
                                  fontSize: 20,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle:
                                      FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width,
                              height: MediaQuery.sizeOf(context).height * 0.065,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).alternate,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Align(
                                    alignment: const AlignmentDirectional(-1, 0),
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          10, 0, 0, 0),
                                      child: Icon(
                                        Icons.watch_sharp,
                                        color: FlutterFlowTheme.of(context).primary,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                                    child: AutoSizeText(
                                      time,
                                      maxLines: 1,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.lexend(
                                              fontWeight: FontWeight.normal,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            fontSize: 18,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.normal,
                                            fontStyle: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width,
                              height: MediaQuery.sizeOf(context).height * 0.065,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).alternate,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Align(
                                      alignment: const AlignmentDirectional(-1, 0),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            10, 0, 0, 0),
                                        child: Icon(
                                          Icons.calendar_month,
                                          color:
                                              FlutterFlowTheme.of(context).primary,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          8, 0, 0, 0),
                                      child: AutoSizeText(
                                        date,
                                        maxLines: 1,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.lexend(
                                                fontWeight: FontWeight.normal,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color: FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                              fontSize: 18,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.normal,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width,
                              constraints: BoxConstraints(
                                minHeight:
                                    MediaQuery.sizeOf(context).height * 0.065,
                              ),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).alternate,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: const AlignmentDirectional(-1, 0),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            10, 0, 0, 0),
                                        child: Icon(
                                          Icons.home_rounded,
                                          color:
                                              FlutterFlowTheme.of(context).primary,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Align(
                                        alignment: const AlignmentDirectional(-1, 0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsetsDirectional.fromSTEB(
                                                      8, 0, 10, 0),
                                              child: AutoSizeText(
                                                address,
                                                textAlign: TextAlign.start,
                                                style: FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      color: FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryBackground,
                                                      fontSize: 18,
                                                      letterSpacing: 0.0,
                                                      fontWeight: FontWeight.normal,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
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
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width,
                              constraints: BoxConstraints(
                                minHeight:
                                    MediaQuery.sizeOf(context).height * 0.065,
                              ),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).alternate,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: const AlignmentDirectional(-1, 0),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            10, 0, 0, 0),
                                        child: Icon(
                                          Icons.timer,
                                          color:
                                              FlutterFlowTheme.of(context).primary,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Align(
                                        alignment: const AlignmentDirectional(-1, 0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsetsDirectional.fromSTEB(
                                                      8, 0, 10, 0),
                                              child: AutoSizeText(
                                                '$duration minutos',
                                                textAlign: TextAlign.start,
                                                style: FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      color: FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryBackground,
                                                      fontSize: 18,
                                                      letterSpacing: 0.0,
                                                      fontWeight: FontWeight.normal,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
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
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width,
                              constraints: BoxConstraints(
                                minHeight:
                                    MediaQuery.sizeOf(context).height * 0.065,
                              ),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).alternate,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: const AlignmentDirectional(-1, 0),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            10, 0, 0, 0),
                                        child: FaIcon(
                                          FontAwesomeIcons.solidHandshake,
                                          color:
                                              FlutterFlowTheme.of(context).primary,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Align(
                                        alignment: const AlignmentDirectional(-1, 0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsetsDirectional.fromSTEB(
                                                      8, 0, 10, 0),
                                              child: AutoSizeText(
                                                instructions,
                                                textAlign: TextAlign.start,
                                                style: FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      color: FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryBackground,
                                                      fontSize: 18,
                                                      letterSpacing: 0.0,
                                                      fontWeight: FontWeight.normal,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
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
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width,
                              constraints: BoxConstraints(
                                minHeight:
                                    MediaQuery.sizeOf(context).height * 0.065,
                              ),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).alternate,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: const AlignmentDirectional(-1, 0),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            10, 0, 0, 0),
                                        child: Icon(
                                          Icons.monetization_on_rounded,
                                          color:
                                              FlutterFlowTheme.of(context).primary,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Align(
                                        alignment: const AlignmentDirectional(-1, 0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsetsDirectional.fromSTEB(
                                                      8, 0, 10, 0),
                                              child: AutoSizeText(
                                                fee,
                                                textAlign: TextAlign.start,
                                                style: FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      color: FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryBackground,
                                                      fontSize: 18,
                                                      letterSpacing: 0.0,
                                                      fontWeight: FontWeight.normal,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
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
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1, 0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 10),
                              child: Text(
                                'Opciones de viaje',
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.lexend(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context).accent1,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          ),
                          ..._getButtonsBasedOnStatus(context, widget.usertype, walkStatus),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

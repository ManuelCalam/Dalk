
import 'dart:io';

import 'package:dalk/auth/supabase_auth/auth_util.dart';
import 'package:dalk/backend/supabase/database/database.dart';
import 'package:dalk/components/pop_up_confirm_dialog/pop_up_confirm_dialog_widget.dart';
import 'package:dalk/utils/validation.dart';
import 'package:flutter/services.dart';

import '/components/go_back_container/go_back_container_widget.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'add_tracker_to_account_model.dart';
export 'add_tracker_to_account_model.dart';

class AddTrackerToAccountWidget extends StatefulWidget {
  const AddTrackerToAccountWidget({super.key});

  static String routeName = 'addTrackerToAccount';
  static String routePath = '/addTrackerToAccount';

  @override
  State<AddTrackerToAccountWidget> createState() =>
      _AddTrackerToAccountWidgetState();
}

class _AddTrackerToAccountWidgetState extends State<AddTrackerToAccountWidget> {
  late AddTrackerToAccountModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddTrackerToAccountModel());

    _model.serialNumberInputTextController ??= TextEditingController();
    _model.serialNumberInputFocusNode ??= FocusNode();

    _model.trackerAliasInputTextController ??= TextEditingController();
    _model.trackerAliasInputFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondary,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height * 0.1,
                decoration: const BoxDecoration(
                  color: Color(0xFF162C43),
                ),
                child: wrapWithModel(
                  model: _model.notificationContainerModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const NotificationContainerWidget(),
                ),
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
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
                      wrapWithModel(
                        model: _model.goBackContainerModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const GoBackContainerWidget(),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 15),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.9,
                            decoration: const BoxDecoration(),
                            child: ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 5, 0, 0),
                                  child: AutoSizeText(
                                    'Activa el rastreador',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    minFontSize: 22,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.lexend(
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          fontSize: 32,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 0, 1),
                                  child: AutoSizeText(
                                    'Vincula el dispositivo a tu cuenta ingresando su alias y número de serie.',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    minFontSize: 10,
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
                                              .accent1,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 15, 0, 0),
                                  child: Icon(
                                    Icons.track_changes_rounded,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 80,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 7, 0, 7),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment:
                                              const AlignmentDirectional(-1, -1),
                                          child: Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    15, 15, 0, 0),
                                            child: Icon(
                                              Icons.warning_rounded,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .warning,
                                              size: 35,
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: AutoSizeText(
                                              'Recuerda: el número de serie viene con el rastreador físico, así que solo podrás registrarlo una vez lo tengas en tus manos.\nEsto asegura que cada dispositivo esté correctamente vinculado y listo para usar durante sus paseos.',
                                              textAlign: TextAlign.justify,
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.lexend(
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Form(
                                  key: _model.formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            0, 18, 0, 0),
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width,
                                          child: TextFormField(
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            controller: _model.serialNumberInputTextController,
                                            focusNode: _model
                                                .serialNumberInputFocusNode,
                                            autofocus: false,
                                            textInputAction:
                                                TextInputAction.done,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              labelText: 'Número de serie',
                                              labelStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyLarge
                                                  .override(
                                                    font: GoogleFonts.lexend(
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    fontSize: 16,
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyLarge
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyLarge
                                                            .fontStyle,
                                                  ),
                                              hintStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .labelMedium
                                                  .override(
                                                    font: GoogleFonts.lexend(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    fontSize: 16,
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium
                                                            .fontStyle,
                                                  ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .alternate,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              filled: true,
                                              fillColor:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              contentPadding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(10, 0, 0, 20),
                                              prefixIcon: Icon(
                                                Icons.numbers_sharp,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                size: 25,
                                              ),
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.lexend(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  fontSize: 16,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                            cursorColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            validator: (value) => Validators.serialNumberValidator(value),
                                            inputFormatters: [LengthLimitingTextInputFormatter(6)],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            0, 18, 0, 0),
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width,
                                          child: TextFormField(
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            controller: _model
                                                .trackerAliasInputTextController,
                                            focusNode: _model
                                                .trackerAliasInputFocusNode,
                                            autofocus: false,
                                            textInputAction:
                                                TextInputAction.next,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              labelText: 'Alias',
                                              labelStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyLarge
                                                  .override(
                                                    font: GoogleFonts.lexend(
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    fontSize: 16,
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyLarge
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyLarge
                                                            .fontStyle,
                                                  ),
                                              hintText:
                                                  'Ej. Luna o Rastreador de Max',
                                              hintStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .labelMedium
                                                  .override(
                                                    font: GoogleFonts.lexend(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    fontSize: 16,
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium
                                                            .fontStyle,
                                                  ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .alternate,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              filled: true,
                                              fillColor:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              contentPadding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(10, 0, 0, 20),
                                              prefixIcon: Icon(
                                                Icons
                                                    .drive_file_rename_outline_rounded,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                size: 25,
                                              ),
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.lexend(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  fontSize: 16,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                            cursorColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            validator: (value) {
                                              final required = Validators.requiredField(value, fieldName: 'Alias');
                                              if (required != null) return required;
                                              final min = Validators.minLength(value, 3, fieldName: 'Alias');
                                              if (min != null) return min;
                                              return Validators.maxLength(value, 18, fieldName: 'Alias');
                                            },                                                  
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(18),
                                            ],                   
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 15, 0, 0),
                                  child: FFButtonWidget(
                                    onPressed: () async {
                                      if (!_model.formKey.currentState!.validate()) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Por favor completa todos los campos correctamente')),
                                        );
                                        return;
                                      }

                                      final serialNumber = _model.serialNumberInputTextController.text.trim().toUpperCase();
                                      final alias = _model.trackerAliasInputTextController.text.trim();
                                      final currentUserUid = Supabase.instance.client.auth.currentUser?.id;

                                      if (currentUserUid == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Error: usuario no autenticado')),
                                        );
                                        return;
                                      }

                                      try {
                                        final orderResponse = await Supabase.instance.client
                                            .from('orders')
                                            .select('tracker_id')
                                            .eq('tracker_id', serialNumber)
                                            .eq('status', 'Pagada')
                                            .maybeSingle();

                                        if (orderResponse == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Número de serie no vinculado a ningún rastreador')),
                                          );
                                          return;
                                        }

                                        final existingTrackers = await Supabase.instance.client
                                            .from('trackers')
                                            .select('id')
                                            .eq('registered_by', currentUserUid)
                                            .eq('serial_number', serialNumber);

                                        print('currentUser: $currentUserUid');
                                        print('Existing trackers: $existingTrackers');

                                        if (existingTrackers.isNotEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Ya registraste este rastreador en tu cuenta')),
                                          );
                                          return;
                                        }

                                        // Insertar en la tabla trackers
                                        await Supabase.instance.client.from('trackers').insert({
                                          'registered_by': currentUserUid,
                                          'alias': alias,
                                          'serial_number': serialNumber,
                                        });

                                        // Mostrar popup de éxito
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Dialog(
                                              backgroundColor: Colors.transparent,
                                              child: PopUpConfirmDialogWidget(
                                                title: "Vinculación exitosa",
                                                message:
                                                    "¡Se ha vinculado el rastreador a tu cuenta correctamente! Podrás utilizarlo al abrir un paseo en curso o cuando un paseador inicie un paseo.",
                                                confirmText: "Agendar un paseo",
                                                cancelText: "Ir a menú principal",
                                                confirmColor: FlutterFlowTheme.of(context).accent1,
                                                cancelColor: FlutterFlowTheme.of(context).primary,
                                                icon: Icons.check_circle,
                                                iconColor: FlutterFlowTheme.of(context).success,
                                                onConfirm: () {
                                                  context.pop();
                                                  context.go('/owner/requestWalk');
                                                },
                                                onCancel: () {
                                                  context.pop();
                                                  context.go('/owner/home');
                                                },
                                              ),
                                            );
                                          },
                                        );
                                      } on SocketException {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Sin conexión a Internet. Intenta nuevamente.')),
  ); }
                                      
                                      catch (e) {
                                        print('Error registrando rastreador: $e');
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error al registrar el rastreador: $e')),
                                        );
                                      }
                                    },
                                    text: 'Vincular',
                                    icon: const Icon(
                                      Icons.track_changes_rounded,
                                      size: 25,
                                    ),
                                    options: FFButtonOptions(
                                      height: 40,
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          16, 0, 16, 0),
                                      iconAlignment: IconAlignment.end,
                                      iconPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 0, 0, 0),
                                      color:
                                          FlutterFlowTheme.of(context).accent1,
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
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:dalk/SubscriptionProvider.dart';
import 'package:provider/provider.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import 'package:dalk/cards/pet_card/pet_card_widget.dart';
import '/cards/address_card/address_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'set_walk_schedule_model.dart';
export 'set_walk_schedule_model.dart';

class SetWalkScheduleWidget extends StatefulWidget {
  const SetWalkScheduleWidget({
    super.key,
    required this.selectedAddress,
    required this.selectedPet
  });

  final int? selectedAddress;
  final int? selectedPet;
  // String selectedWalkDuration = '30 min';
  // int customWalkDuration = 30;

  static String routeName = 'setWalkSchedule';
  static String routePath = '/setWalkSchedule';

  @override
  State<SetWalkScheduleWidget> createState() => _SetWalkScheduleWidgetState();
}

class _SetWalkScheduleWidgetState extends State<SetWalkScheduleWidget> {
  late SetWalkScheduleModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  int? selectedAddressId;
  int? selectedPetId;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SetWalkScheduleModel());
    selectedAddressId = widget.selectedAddress;
    selectedPetId = widget.selectedPet;
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<SubscriptionProvider>().isPremium;

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
              Expanded(
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).tertiary,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: MediaQuery.sizeOf(context).height * 0.1,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondary,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              color: Color(0xFF162C43),
                              offset: Offset(
                                0.0,
                                2.0,
                              ),
                            )
                          ],
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40.0),
                            bottomRight: Radius.circular(40.0),
                            topLeft: Radius.circular(0.0),
                            topRight: Radius.circular(0.0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Align(
                              alignment: AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    15.0, 0.0, 0.0, 0.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.safePop();
                                  },
                                  child: Icon(
                                    Icons.chevron_left_outlined,
                                    color: FlutterFlowTheme.of(context).accent2,
                                    size: 32.0,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Text(
                                  'Agendar',
                                  textAlign: TextAlign.center,
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
                                            .accent2,
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 15.0, 0.0),
                              child: Icon(
                                Icons.notifications_sharp,
                                color: FlutterFlowTheme.of(context).accent2,
                                size: 32.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 15.0, 0.0, 15.0),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.9,
                            decoration: BoxDecoration(),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: AutoSizeText(
                                      'Escoge la fecha',
                                      maxLines: 1,
                                      minFontSize: 11.0,
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
                                                .accent1,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.normal,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 18.0, 0.0, 0.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        final _datePicked1Date =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: getCurrentTimestamp,
                                          firstDate: getCurrentTimestamp,
                                          lastDate: DateTime(2050),
                                          builder: (context, child) {
                                            return wrapInMaterialDatePickerTheme(
                                              context,
                                              child!,
                                              headerBackgroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              headerForegroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .info,
                                              headerTextStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .headlineLarge
                                                      .override(
                                                        font:
                                                            GoogleFonts.lexend(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .headlineLarge
                                                                  .fontStyle,
                                                        ),
                                                        fontSize: 32.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .headlineLarge
                                                                .fontStyle,
                                                      ),
                                              pickerBackgroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              pickerForegroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              selectedDateTimeBackgroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              selectedDateTimeForegroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .info,
                                              actionButtonForegroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              iconSize: 24.0,
                                            );
                                          },
                                        );

                                        if (_datePicked1Date != null) {
                                          safeSetState(() {
                                            _model.datePicked1 = DateTime(
                                              _datePicked1Date.year,
                                              _datePicked1Date.month,
                                              _datePicked1Date.day,
                                            );
                                          });
                                        } else if (_model.datePicked1 != null) {
                                          safeSetState(() {
                                            _model.datePicked1 =
                                                getCurrentTimestamp;
                                          });
                                        }
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                1.0,
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.05,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .alternate,
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(8.0, 0.0, 0.0, 0.0),
                                              child: Icon(
                                                Icons.calendar_month,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                size: 25.0,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(7.0, 0.0, 0.0, 0.0),
                                              child: AutoSizeText(
                                                _model.datePicked1 != null
                                                    ? dateTimeFormat('d/M/y', _model.datePicked1)
                                                    : 'Fecha',
                                                textAlign: TextAlign.start,
                                                maxLines: 1,
                                                minFontSize: 12.0,
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
                                                      fontSize: 16.0,
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
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 18.0, 0.0, 0.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        await showModalBottomSheet<bool>(
                                            context: context,
                                            builder: (context) {
                                              final _datePicked2CupertinoTheme =
                                                  CupertinoTheme.of(context);
                                              return Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    3,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .alternate,
                                                child: CupertinoTheme(
                                                  data:
                                                      _datePicked2CupertinoTheme
                                                          .copyWith(
                                                    textTheme:
                                                        _datePicked2CupertinoTheme
                                                            .textTheme
                                                            .copyWith(
                                                      dateTimePickerTextStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .headlineMedium
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .lexend(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .headlineMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .headlineMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .headlineMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .headlineMedium
                                                                    .fontStyle,
                                                              ),
                                                    ),
                                                  ),
                                                  child: CupertinoDatePicker(
                                                    mode:
                                                        CupertinoDatePickerMode
                                                            .time,
                                                    minimumDate: DateTime(1900),
                                                    initialDateTime:
                                                        getCurrentTimestamp,
                                                    maximumDate: DateTime(2050),
                                                    backgroundColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .alternate,
                                                    use24hFormat: false,
                                                    onDateTimeChanged:
                                                        (newDateTime) =>
                                                            safeSetState(() {
                                                      _model.datePicked2 =
                                                          newDateTime;
                                                    }),
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                1.0,
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.05,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .alternate,
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 1.0, 0.0, 0.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        8.0, 0.0, 0.0, 0.0),
                                                child: Icon(
                                                  Icons.timer_sharp,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  size: 25.0,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        7.0, 0.0, 0.0, 0.0),
                                                child: AutoSizeText(
                                                  _model.datePicked2 != null
                                                      ? dateTimeFormat('Hm', _model.datePicked2)
                                                      : 'Hora',
                                                  textAlign: TextAlign.start,
                                                  maxLines: 1,
                                                  minFontSize: 12.0,
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
                                                        fontSize: 16.0,
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
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  

                                  Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 25.0, 0.0, 0.0),
                                      child: AutoSizeText(
                                        'Escoge tiempo de paseo',
                                        textAlign: TextAlign.start,
                                        maxLines: 2,
                                        minFontSize: 10.0,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.lexend(
                                                fontWeight: FontWeight.normal,
                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                              ),
                                              color: FlutterFlowTheme.of(context).accent1,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.normal,
                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                            ),
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final List<String> options = ['30 min', '60 min', 'Personalizado'];

                                        final double segmentWidth = constraints.maxWidth / 3.0; 

                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(context).alternate,
                                                borderRadius: BorderRadius.circular(20.0), 
                                              ),
                                              padding: const EdgeInsets.all(4.0), 
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: List.generate(options.length, (index) {
                                                  final option = options[index];
                                                  final isSelected = _model.selectedWalkDuration == option;
                                                  final isCustomOption = option == 'Personalizado';
                                                  // Si no es premium Y es la opción Personalizado, está bloqueado.
                                                  final isLocked = !isPremium && isCustomOption; 

                                                  return GestureDetector(
                                                    onTap: () async {
                                                      if (isLocked) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: const Text('¡El tiempo Personalizado requiere el plan Premium!'),
                                                            action: SnackBarAction(
                                                              label: 'Ver Planes',
                                                              onPressed: () {
                                                                context.goNamed(PremiumPlanInfoWidget.routeName);
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                        // Se mantiene la selección anterior o se revierte a 30 min si no había selección válida.
                                                        if (_model.selectedWalkDuration == 'Personalizado' || isLocked) {
                                                          setState(() {
                                                              _model.selectedWalkDuration = '30 min';
                                                          });
                                                        }
                                                        return;
                                                      }
                                                      
                                                      // Acción de Selección Válida
                                                      setState(() {
                                                        _model.selectedWalkDuration = option;
                                                      });
                                                    },
                                                    child: AnimatedContainer(
                                                      duration: const Duration(milliseconds: 200),
                                                      width: segmentWidth - 4.0,
                                                      height: 48.0, 
                                                      decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? FlutterFlowTheme.of(context).primary
                                                            : FlutterFlowTheme.of(context).alternate,
                                                        borderRadius: BorderRadius.circular(16.0),
                                                      ),
                                                      child: Center(
                                                        child: AutoSizeText(
                                                          option,
                                                          maxLines: 1,
                                                          minFontSize: 10.0,
                                                          style: GoogleFonts.lexend(
                                                            fontSize: 14.0,
                                                            color: isSelected
                                                                ? Colors.white
                                                                : isLocked
                                                                    ? Color(0xFF717981) 
                                                                    : FlutterFlowTheme.of(context).primaryText,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ),

                                            // --- CONDITIONAL PREMIUM INPUT FIELD ---
                                            if (isPremium && _model.selectedWalkDuration == 'Personalizado')
                                              Padding(
                                                padding: const EdgeInsets.only(top: 16.0),
                                                child: TextFormField(
                                                  controller: _model.customDurationTextController, 
                                                  focusNode: _model.customDurationFocusNode,
                                                  autofocus: true, 
                                                  textInputAction: TextInputAction.done,
                                                  keyboardType: TextInputType.number,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    filled: true, 
                                                    fillColor: FlutterFlowTheme.of(context).alternate, 
                                                    labelText: 'Minutos personalizados',
                                                    labelStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                                                        fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                      fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                                                      fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                      color: FlutterFlowTheme.of(context).primary
                                                    ),
                                                    alignLabelWithHint: false,
                                                    hintText: 'Ej. 90 minutos (Mínimo 70min)',
                                                    hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight: FontWeight.w500,
                                                        fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                      ),
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      fontSize: 16,
                                                      letterSpacing: 0.0,
                                                      fontWeight: FontWeight.w500,
                                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                    ),
                                                    prefixIcon: Icon(
                                                      Icons.access_time_filled, 
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      size: 25,
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Color(0x00000000),
                                                        width: 1,
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Color(0x00000000),
                                                        width: 1,
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    errorBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: FlutterFlowTheme.of(context).error,
                                                        width: 1,
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    focusedErrorBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: FlutterFlowTheme.of(context).error,
                                                        width: 1,
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                    font: GoogleFonts.lexend(
                                                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                    fontSize: 16,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                  ),
                                                  cursorColor: FlutterFlowTheme.of(context).primaryText,
                                                  
                                                  // LÓGICA (Funcionalidad del primer bloque)
                                                  onChanged: (value) {
                                                    setState(() {
                                                      // Guarda el valor ingresado en la variable de estado
                                                      _model.customWalkDuration = int.tryParse(value) ?? 0;
                                                    });
                                                  },
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),




                                  
                                  Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 25.0, 0.0, 0.0),
                                      child: AutoSizeText(
                                        'Escoge la dirección',
                                        textAlign: TextAlign.start,
                                        maxLines: 2,
                                        minFontSize: 10.0,
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .accent1,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.normal,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ),
        
                                  // ListView Dinamico de las Direcciones
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 10.0, 0.0, 0.0),
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width *
                                          1.0,
                                      height: 110.0,
                                      decoration: BoxDecoration(),
                                      
                                      child: StreamBuilder<List<AddressesRow>>(
                                        stream: _model.addressesListViewSupabaseStream ??=
                                            SupaFlow.client
                                                .from("addresses")
                                                .stream(primaryKey: ['id'])
                                                .eqOrNull('uuid', currentUserUid)
                                                .map((list) => list.map((item) => AddressesRow(item)).toList()),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return Center(
                                              child: SizedBox(
                                                width: 50.0,
                                                height: 50.0,
                                                child: CircularProgressIndicator(
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    FlutterFlowTheme.of(context).primary,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          List<AddressesRow> addressesList = snapshot.data!;

                                          return ListView.separated(
                                            padding: EdgeInsets.zero,
                                            primary: false,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemCount: addressesList.length + 1, // +1 para el botón extra
                                            separatorBuilder: (_, __) => SizedBox(width: 10.0),
                                            itemBuilder: (context, index) {
                                              if (index < addressesList.length) {
                                                final address = addressesList[index];
                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      if (selectedAddressId == address.id) {
                                                        selectedAddressId = null; 
                                                      } else {
                                                        selectedAddressId = address.id; 
                                                      }
                                                    });
                                                  },
                                                  child: AddressCardWidget(
                                                    key: Key('Keyil1_${address.id}'),
                                                    alias: address.alias,
                                                    id: address.id,
                                                    selected: selectedAddressId == address.id,
                                                  ),
                                                );
                                              } else {
                                                // Último elemento: botón para agregar dirección
                                                return InkWell(
                                                  splashColor: Colors.transparent,
                                                  focusColor: Colors.transparent,
                                                  hoverColor: Colors.transparent,
                                                  highlightColor: Colors.transparent,
                                                  onTap: () async {
                                                    context.pushNamed(AddAddressWidget.routeName);
                                                  },
                                                  child: Container(
                                                    width: 100.0,
                                                    height: 110.0,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme.of(context).alternate,
                                                      borderRadius: BorderRadius.circular(20.0),
                                                    ),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: [
                                                        Container(
                                                          width: 100.0,
                                                          height: 70.0,
                                                          decoration: BoxDecoration(),
                                                          child: Icon(
                                                            Icons.add_home_work_rounded,
                                                            color: FlutterFlowTheme.of(context).primary,
                                                            size: 45.0,
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 100.0,
                                                          height: 30.0,
                                                          decoration: BoxDecoration(),
                                                          child: Align(
                                                            alignment: AlignmentDirectional(0.0, 0.0),
                                                            child: AutoSizeText(
                                                              'Agregar dirección',
                                                              textAlign: TextAlign.center,
                                                              maxLines: 1,
                                                              minFontSize: 8.0,
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
                                                                    fontSize: 12.0,
                                                                    letterSpacing: 0.0,
                                                                    fontWeight: FontWeight.w500,
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
                                                );
                                              }
                                            },
                                          );
                                        },
                                      )
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 25.0, 0.0, 0.0),
                                      child: AutoSizeText(
                                        'Selecciona tu mascota',
                                        maxLines: 2,
                                        minFontSize: 10.0,
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .accent1,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.normal,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ),
                                  
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width * 1.0,
                                      height: 110.0,
                                      decoration: BoxDecoration(),
                                      child: StreamBuilder<List<Map<String, dynamic>>>(
                                        stream: SupaFlow.client
                                            .from("pets")
                                            .stream(primaryKey: ['id'])
                                            .eq('uuid', currentUserUid),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return Center(
                                              child: SizedBox(
                                                width: 50.0,
                                                height: 50.0,
                                                child: CircularProgressIndicator(
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    FlutterFlowTheme.of(context).primary,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          final petsList = snapshot.data!;
                                          return ListView.separated(
                                            padding: EdgeInsets.zero,
                                            primary: false,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemCount: petsList.length + 1, // +1 para el botón extra
                                            separatorBuilder: (_, __) => SizedBox(width: 10.0),
                                            itemBuilder: (context, index) {
                                              if (index < petsList.length) {
                                                final pet = petsList[index];
                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      if (selectedPetId == pet['id']) {
                                                        selectedPetId = null; 
                                                      } else {
                                                        selectedPetId = pet['id']; 
                                                      }
                                                    });
                                                  },
                                                  child: PetCardWidget(
                                                    key: Key('PetCard_${pet['id']}'),
                                                    petName: pet['name'],
                                                    id: pet['id'],
                                                    selected: selectedPetId == pet['id'],
                                                  ),
                                                );
                                              } else {
                                                // Último elemento: botón para agregar mascota
                                                return InkWell(
                                                  splashColor: Colors.transparent,
                                                  focusColor: Colors.transparent,
                                                  hoverColor: Colors.transparent,
                                                  highlightColor: Colors.transparent,
                                                  onTap: () async {
                                                    context.pushNamed(AddPetWidget.routeName);
                                                  },
                                                  child: Container(
                                                    width: 100.0,
                                                    height: 110.0,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme.of(context).alternate,
                                                      borderRadius: BorderRadius.circular(20.0),
                                                    ),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: [
                                                        Container(
                                                          width: 100.0,
                                                          height: 70.0,
                                                          decoration: BoxDecoration(),
                                                          child: Icon(
                                                            Icons.add_box,
                                                            color: FlutterFlowTheme.of(context).primary,
                                                            size: 45.0,
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 100.0,
                                                          height: 30.0,
                                                          decoration: BoxDecoration(),
                                                          child: Align(
                                                            alignment: AlignmentDirectional(0.0, 0.0),
                                                            child: AutoSizeText(
                                                              'Agregar mascota',
                                                              textAlign: TextAlign.center,
                                                              maxLines: 1,
                                                              minFontSize: 8.0,
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
                                                                    fontSize: 12.0,
                                                                    letterSpacing: 0.0,
                                                                    fontWeight: FontWeight.w500,
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
                                                );
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),




if(isPremium)
Align(
  alignment: AlignmentDirectional(-1.0, 0.0),
  child: Padding(
    padding: EdgeInsetsDirectional.fromSTEB(0.0, 25.0, 0.0, 0.0),
    child: AutoSizeText(
      'Instrucciones especiales para el paseador',
      textAlign: TextAlign.start,
      maxLines: 2,
      minFontSize: 10.0,
      style: FlutterFlowTheme.of(context)
          .bodyMedium
          .override(
            font: GoogleFonts.lexend(
              fontWeight: FontWeight.normal,
              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
            ),
            color: FlutterFlowTheme.of(context).accent1,
            letterSpacing: 0.0,
            fontWeight: FontWeight.normal,
            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
          ),
    ),
  ),
),

if(isPremium)
Align(
  alignment: AlignmentDirectional(-1.0, 0.0),
  child: Padding(
    padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
    child: TextFormField(
      controller: _model.instructionsTextController,
      focusNode: _model.instructionsFocusNode,
      autofocus: false,
      textInputAction: TextInputAction.done,
      obscureText: false,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: FlutterFlowTheme.of(context).alternate,
        labelText: 'Instrucciones para el paseador',
        labelStyle: FlutterFlowTheme.of(context).bodyLarge.override(
          font: GoogleFonts.lexend(
            fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
            fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
          ),
          letterSpacing: 0.0,
          fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
          fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
          color: FlutterFlowTheme.of(context).primary
        ),
        alignLabelWithHint: false,
        hintText: 'Ej. Ruta preferida, cuidados especiales, etc.',
        hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
          font: GoogleFonts.lexend(
            fontWeight: FontWeight.w500,
            fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
          ),
          color: FlutterFlowTheme.of(context).primary,
          fontSize: 16,
          letterSpacing: 0.0,
          fontWeight: FontWeight.w500,
          fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
        ),
        prefixIcon: Icon(
          Icons.note_alt_outlined,
          color: FlutterFlowTheme.of(context).primary,
          size: 25,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0x00000000),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0x00000000),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: FlutterFlowTheme.of(context).error,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: FlutterFlowTheme.of(context).error,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      style: FlutterFlowTheme.of(context).bodyMedium.override(
        font: GoogleFonts.lexend(
          fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
        ),
        color: FlutterFlowTheme.of(context).secondaryBackground,
        fontSize: 16,
        letterSpacing: 0.0,
        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
      ),
      cursorColor: FlutterFlowTheme.of(context).primaryText,
      maxLines: 4,
      textAlign: TextAlign.start,
    ),
  ),
),



                                  
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 20.0, 0.0, 0.0),
                                    child: FFButtonWidget(
                                      onPressed: () async {
                                        int finalWalkDurationInMinutes;

                                        if (_model.selectedWalkDuration == 'Personalizado') {
                                            finalWalkDurationInMinutes = _model.customWalkDuration >= 70 ? _model.customWalkDuration : 70;
                                        } else if (_model.selectedWalkDuration == '60 min') {
                                            finalWalkDurationInMinutes = 60;
                                        } else {
                                            finalWalkDurationInMinutes = 30;
                                        }

                                        context.pushNamed(
                                          FindDogWalkerWidget.routeName,
                                            queryParameters: {
                                              'date': _model.datePicked1?.toIso8601String(),
                                              'time': _model.datePicked2?.toIso8601String(),
                                              'addressId': selectedAddressId?.toString(),
                                              'petId': selectedPetId?.toString(),
                                              'walkDuration': finalWalkDurationInMinutes.toString(),
                                              'instructions': _model.instructionsTextController?.text ?? ''
                                            },
                                          );
                                      },
                                      text: 'Buscar paseador',
                                      options: FFButtonOptions(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                1.0,
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.045,
                                        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                        iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context).accent1,
                                        textStyle: FlutterFlowTheme.of(context).titleSmall
                                            .override(
                                              font: GoogleFonts.lexend(
                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
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
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
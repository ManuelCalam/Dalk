import 'package:dalk/backend/supabase/database/database.dart';

import '/components/go_back_container/go_back_container_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'exception_day_model.dart';
export 'exception_day_model.dart';

class ExceptionDayWidget extends StatefulWidget {
  const ExceptionDayWidget({super.key});

  static String routeName = 'exceptionDay';
  static String routePath = '/exceptionDay';

  @override
  State<ExceptionDayWidget> createState() => _ExceptionDayWidgetState();
}

class _ExceptionDayWidgetState extends State<ExceptionDayWidget> {
  late ExceptionDayModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ExceptionDayModel());

    _model.wilDogWalkerWorkSwitchValue = true;
    _model.workZoneInputTextController ??= TextEditingController();
    _model.workZoneInputFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Fecha';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Función para formatear la hora
  String _formatTime(DateTime? time) {
    if (time == null) return 'Hora';
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $period';
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
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                  ),
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
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
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
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 15),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.9,
                            decoration: const BoxDecoration(),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AutoSizeText(
                                    'Día con excepción',
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
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                                    child: Icon(
                                      Icons.free_cancellation,
                                      color: FlutterFlowTheme.of(context).primary,
                                      size: 80,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0, 15, 0, 15),
                                    child: AutoSizeText(
                                      'Si necesitas tomar un descanso o tienes compromisos personales, Marca el horarios en los que no estarás disponible. Elige entre todo el día u horas específicas.\nDurante este tiempo no recibirás solicitudes y no aparecerás en búsquedas.',
                                      textAlign: TextAlign.center,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.lexend(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0, 18, 0, 0),
                                    child: Container(
                                      width: 360,
                                      decoration: const BoxDecoration(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Form(
                                            key: _model.formKey,
                                            child: ListView(
                                              padding: EdgeInsets.zero,
                                              primary: false,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              children: [
                                                Align(
                                                  alignment:
                                                      const AlignmentDirectional(
                                                          1, 0),
                                                  child: Container(
                                                    width: MediaQuery.sizeOf(
                                                            context)
                                                        .width,
                                                    decoration: const BoxDecoration(),
                                                    child: Align(
                                                      alignment:
                                                          const AlignmentDirectional(
                                                              0, 0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Align(
                                                            alignment:
                                                                const AlignmentDirectional(
                                                                    1, 0),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0,
                                                                          0,
                                                                          10,
                                                                          0),
                                                              child:
                                                                  AutoSizeText(
                                                                '¿Trabajarás ese día?',
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                maxLines: 2,
                                                                minFontSize: 10,
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .lexend(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                      fontSize:
                                                                          18,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                const AlignmentDirectional(
                                                                    -1, 0),
                                                            child:
                                                                Switch.adaptive(
                                                              value: _model.wilDogWalkerWorkSwitchValue!,
                                                              onChanged:
                                                                  (newValue) async {
                                                                safeSetState(() =>
                                                                    _model.wilDogWalkerWorkSwitchValue =
                                                                        newValue);
                                                              },
                                                              activeColor:
                                                                  Colors.white,
                                                              activeTrackColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                              inactiveTrackColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .alternate,
                                                              inactiveThumbColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(0, 18, 0, 0),
                                                  child: InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    focusColor:
                                                        Colors.transparent,
                                                    hoverColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    onTap: () async {
                                                      final _datePicked1Date =
                                                          await showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            DateTime.now(),
                                                        firstDate:
                                                            DateTime.now(),
                                                        lastDate:
                                                            DateTime(2050),
                                                            locale: const Locale('es', 'ES'),
                                                        builder:
                                                            (context, child) {
                                                          return wrapInMaterialDatePickerTheme(
                                                            context,
                                                            child!,
                                                            headerBackgroundColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                            headerForegroundColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                            headerTextStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .headlineLarge
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .lexend(
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .headlineLarge
                                                                            .fontStyle,
                                                                      ),
                                                                      fontSize:
                                                                          32,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .headlineLarge
                                                                          .fontStyle,
                                                                    ),
                                                            pickerBackgroundColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .alternate,
                                                            pickerForegroundColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                            selectedDateTimeBackgroundColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                            selectedDateTimeForegroundColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                            actionButtonForegroundColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                            iconSize: 24,
                                                          );
                                                        },
                                                      );

                                                      if (_datePicked1Date !=
                                                          null) {
                                                        safeSetState(() {
                                                          _model.datePicked1 =
                                                              DateTime(
                                                            _datePicked1Date
                                                                .year,
                                                            _datePicked1Date
                                                                .month,
                                                            _datePicked1Date
                                                                .day,
                                                          );
                                                        });
                                                      } else if (_model
                                                              .datePicked1 !=
                                                          null) {
                                                        safeSetState(() {
                                                          _model.datePicked1 =
                                                              getCurrentTimestamp;
                                                        });
                                                      }
                                                    } 
                                                    , 
                                                    child: Container(
                                                      width: MediaQuery.sizeOf(
                                                              context)
                                                          .width,
                                                      height: MediaQuery.sizeOf(
                                                                  context)
                                                              .height *
                                                          0.05,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .alternate,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        8,
                                                                        0,
                                                                        0,
                                                                        0),
                                                            child: Icon(
                                                              Icons
                                                                  .calendar_month,
                                                              color: FlutterFlowTheme.of(context).primary,
                                                                  
                                                              size: 25,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        7,
                                                                        0,
                                                                        0,
                                                                        0),
                                                            child: AutoSizeText(
                                                              _formatDate(_model.datePicked1), // Muestra la fecha seleccionada
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              maxLines: 1,
                                                              minFontSize: 12,
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .lexend(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    color:  FlutterFlowTheme.of(context).secondaryBackground,
                                                                        
                                                                    fontSize:
                                                                        16,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
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
                                                ),
                                                
                                                Padding(
                                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                                                  child: Container(
                                                    width: MediaQuery.sizeOf(context).width,
                                                    decoration: const BoxDecoration(),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        // HORA INICIO
                                                        Flexible(
                                                          child: Align(
                                                            alignment: const AlignmentDirectional(-1, 0),
                                                            child: Padding(
                                                              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                                                              child: InkWell(
                                                                splashColor: Colors.transparent,
                                                                focusColor: Colors.transparent,
                                                                hoverColor: Colors.transparent,
                                                                highlightColor: Colors.transparent,
                                                                onTap: _model.wilDogWalkerWorkSwitchValue!
                                                                    ? () async {
                                                                        await showModalBottomSheet<bool>(
                                                                          context: context,
                                                                          builder: (context) {
                                                                            final _datePicked2CupertinoTheme = CupertinoTheme.of(context);
                                                                            DateTime now = DateTime.now();
                                                                            
                                                                            // Verificar si la fecha seleccionada es hoy
                                                                            bool isToday = _model.datePicked1 != null && 
                                                                                          _model.datePicked1!.year == now.year && 
                                                                                          _model.datePicked1!.month == now.month && 
                                                                                          _model.datePicked1!.day == now.day;
                                                                            
                                                                            DateTime selectedTime = _model.datePicked2 ?? now;
                                                                            DateTime minimumDate = isToday ? now : DateTime(1900); 
                                                                            
                                                                            if (isToday && selectedTime.isBefore(now)) {
                                                                              selectedTime = now;
                                                                            }

                                                                            return Container(
                                                                              height: MediaQuery.of(context).size.height / 3 + 60,
                                                                              width: MediaQuery.of(context).size.width,
                                                                              color: FlutterFlowTheme.of(context).alternate,
                                                                              child: Column(
                                                                                children: [
                                                                                  Container(
                                                                                    width: double.infinity,
                                                                                    padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
                                                                                    child: ElevatedButton(
                                                                                      onPressed: () {
                                                                                        context.pop(true);
                                                                                        safeSetState(() {
                                                                                          _model.datePicked2 = selectedTime;
                                                                                          // Si la hora fin es anterior a la nueva hora inicio, resetearla
                                                                                          if (_model.datePicked3 != null && 
                                                                                              _model.datePicked3!.isBefore(selectedTime)) {
                                                                                            _model.datePicked3 = selectedTime.add(const Duration(hours: 1));
                                                                                          }
                                                                                        });
                                                                                      },
                                                                                      style: ElevatedButton.styleFrom(
                                                                                        backgroundColor: FlutterFlowTheme.of(context).primary,
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(20),
                                                                                        ),
                                                                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                                                                      ),
                                                                                      child: Text(
                                                                                        'Aceptar',
                                                                                        style: GoogleFonts.lexend(
                                                                                          color: Colors.white,
                                                                                          fontSize: 18,
                                                                                          fontWeight: FontWeight.w600,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  // Selector de hora
                                                                                  Expanded(
                                                                                    child: CupertinoTheme(
                                                                                      data: _datePicked2CupertinoTheme.copyWith(
                                                                                        textTheme: _datePicked2CupertinoTheme.textTheme.copyWith(
                                                                                          dateTimePickerTextStyle:
                                                                                              FlutterFlowTheme.of(context).headlineMedium.override(
                                                                                                    font: GoogleFonts.lexend(
                                                                                                      fontWeight: FlutterFlowTheme.of(context)
                                                                                                          .headlineMedium
                                                                                                          .fontWeight,
                                                                                                      fontStyle: FlutterFlowTheme.of(context)
                                                                                                          .headlineMedium
                                                                                                          .fontStyle,
                                                                                                    ),
                                                                                                    color: FlutterFlowTheme.of(context).primaryText,
                                                                                                    letterSpacing: 0.0,
                                                                                                  ),
                                                                                        ),
                                                                                      ),
                                                                                      child: CupertinoDatePicker(
                                                                                        mode: CupertinoDatePickerMode.time,
                                                                                        minimumDate: minimumDate,
                                                                                        initialDateTime: selectedTime,
                                                                                        maximumDate: DateTime(2050),
                                                                                        backgroundColor: FlutterFlowTheme.of(context).alternate,
                                                                                        use24hFormat: false,
                                                                                        onDateTimeChanged: (newDateTime) {
                                                                                          selectedTime = newDateTime;
                                                                                        },
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          },
                                                                        );
                                                                      }
                                                                    : null,
                                                                child: Container(
                                                                  width: MediaQuery.sizeOf(context).width * 0.4,
                                                                  height: MediaQuery.sizeOf(context).height * 0.05,
                                                                  decoration: BoxDecoration(
                                                                    color: FlutterFlowTheme.of(context).alternate,
                                                                    borderRadius: BorderRadius.circular(20),
                                                                  ),
                                                                  child: Padding(
                                                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 1, 0, 0),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.max,
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                                                                          child: Icon(
                                                                            Icons.timer_sharp,
                                                                            color: _model.wilDogWalkerWorkSwitchValue!
                                                                                ? FlutterFlowTheme.of(context).primary
                                                                                : FlutterFlowTheme.of(context).secondaryBackground.withOpacity(0.5),
                                                                            size: 25,
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsetsDirectional.fromSTEB(7, 0, 0, 0),
                                                                          child: AutoSizeText(
                                                                            _model.datePicked2 != null
                                                                                ? dateTimeFormat('Hm', _model.datePicked2)
                                                                                : 'Hora',
                                                                            textAlign: TextAlign.start,
                                                                            maxLines: 1,
                                                                            minFontSize: 12,
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  font: GoogleFonts.lexend(
                                                                                    fontWeight: FlutterFlowTheme.of(context)
                                                                                        .bodyMedium
                                                                                        .fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context)
                                                                                        .bodyMedium
                                                                                        .fontStyle,
                                                                                  ),
                                                                                  color: _model.wilDogWalkerWorkSwitchValue!
                                                                                      ? FlutterFlowTheme.of(context).secondaryBackground
                                                                                      : FlutterFlowTheme.of(context).secondaryBackground.withOpacity(0.5),
                                                                                  fontSize: 16,
                                                                                  letterSpacing: 0.0,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                        // TEXTO "A"
                                                        Align(
                                                          alignment: const AlignmentDirectional(0, 0),
                                                          child: Text(
                                                            'A',
                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                  font: GoogleFonts.lexend(
                                                                    fontWeight: FlutterFlowTheme.of(context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: _model.wilDogWalkerWorkSwitchValue!
                                                                      ? FlutterFlowTheme.of(context).secondaryBackground
                                                                      : FlutterFlowTheme.of(context).secondaryBackground.withOpacity(0.5),
                                                                  fontSize: 20,
                                                                  letterSpacing: 0.0,
                                                                ),
                                                          ),
                                                        ),

                                                        // HORA FIN
                                                        Flexible(
                                                          child: Align(
                                                            alignment: const AlignmentDirectional(1, 0),
                                                            child: Padding(
                                                              padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                                                              child: InkWell(
                                                                splashColor: Colors.transparent,
                                                                focusColor: Colors.transparent,
                                                                hoverColor: Colors.transparent,
                                                                highlightColor: Colors.transparent,
                                                                onTap: _model.wilDogWalkerWorkSwitchValue!
                                                                    ? () async {
                                                                        await showModalBottomSheet<bool>(
                                                                          context: context,
                                                                          builder: (context) {
                                                                            final _datePicked3CupertinoTheme = CupertinoTheme.of(context);
                                                                            DateTime now = DateTime.now();
                                                                            
                                                                            // Verificar si la fecha seleccionada es hoy
                                                                            bool isToday = _model.datePicked1 != null && 
                                                                                          _model.datePicked1!.year == now.year && 
                                                                                          _model.datePicked1!.month == now.month && 
                                                                                          _model.datePicked1!.day == now.day;
                                                                            
                                                                            // Hora mínima: si es hoy, usar ahora; si no, usar la hora inicio o mínimo absoluto
                                                                            DateTime minimumDate;
                                                                            if (isToday) {
                                                                              minimumDate = now;
                                                                            } else {
                                                                              minimumDate = _model.datePicked2 ?? DateTime(1900);
                                                                            }
                                                                            
                                                                            // Si hay hora inicio y es mayor que el mínimo, usar la hora inicio
                                                                            if (_model.datePicked2 != null && _model.datePicked2!.isAfter(minimumDate)) {
                                                                              minimumDate = _model.datePicked2!;
                                                                            }
                                                                            
                                                                            DateTime selectedTime = _model.datePicked3 ?? minimumDate.add(const Duration(hours: 1));
                                                                            
                                                                            if (selectedTime.isBefore(minimumDate)) {
                                                                              selectedTime = minimumDate.add(const Duration(hours: 1));
                                                                            }

                                                                            return Container(
                                                                              height: MediaQuery.of(context).size.height / 3 + 60,
                                                                              width: MediaQuery.of(context).size.width,
                                                                              color: FlutterFlowTheme.of(context).alternate,
                                                                              child: Column(
                                                                                children: [
                                                                                  Container(
                                                                                    width: double.infinity,
                                                                                    padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
                                                                                    child: ElevatedButton(
                                                                                      onPressed: () {
                                                                                        context.pop(true);
                                                                                        safeSetState(() {
                                                                                          _model.datePicked3 = selectedTime;
                                                                                        });
                                                                                      },
                                                                                      style: ElevatedButton.styleFrom(
                                                                                        backgroundColor: FlutterFlowTheme.of(context).primary,
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(20),
                                                                                        ),
                                                                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                                                                      ),
                                                                                      child: Text(
                                                                                        'Aceptar',
                                                                                        style: GoogleFonts.lexend(
                                                                                          color: Colors.white,
                                                                                          fontSize: 18,
                                                                                          fontWeight: FontWeight.w600,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  // Selector de hora
                                                                                  Expanded(
                                                                                    child: CupertinoTheme(
                                                                                      data: _datePicked3CupertinoTheme.copyWith(
                                                                                        textTheme: _datePicked3CupertinoTheme.textTheme.copyWith(
                                                                                          dateTimePickerTextStyle:
                                                                                              FlutterFlowTheme.of(context).headlineMedium.override(
                                                                                                    font: GoogleFonts.lexend(
                                                                                                      fontWeight: FlutterFlowTheme.of(context)
                                                                                                          .headlineMedium
                                                                                                          .fontWeight,
                                                                                                      fontStyle: FlutterFlowTheme.of(context)
                                                                                                          .headlineMedium
                                                                                                          .fontStyle,
                                                                                                    ),
                                                                                                    color: FlutterFlowTheme.of(context).primaryText,
                                                                                                    letterSpacing: 0.0,
                                                                                                  ),
                                                                                        ),
                                                                                      ),
                                                                                      child: CupertinoDatePicker(
                                                                                        mode: CupertinoDatePickerMode.time,
                                                                                        minimumDate: minimumDate,
                                                                                        initialDateTime: selectedTime,
                                                                                        maximumDate: DateTime(2050),
                                                                                        backgroundColor: FlutterFlowTheme.of(context).alternate,
                                                                                        use24hFormat: false,
                                                                                        onDateTimeChanged: (newDateTime) {
                                                                                          selectedTime = newDateTime;
                                                                                        },
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          },
                                                                        );
                                                                      }
                                                                    : null,
                                                                child: Container(
                                                                  width: MediaQuery.sizeOf(context).width * 0.4,
                                                                  height: MediaQuery.sizeOf(context).height * 0.05,
                                                                  decoration: BoxDecoration(
                                                                    color: FlutterFlowTheme.of(context).alternate,
                                                                    borderRadius: BorderRadius.circular(20),
                                                                  ),
                                                                  child: Padding(
                                                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 1, 0, 0),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.max,
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                                                                          child: Icon(
                                                                            Icons.timer_sharp,
                                                                            color: _model.wilDogWalkerWorkSwitchValue!
                                                                                ? FlutterFlowTheme.of(context).primary
                                                                                : FlutterFlowTheme.of(context).secondaryBackground.withOpacity(0.5),
                                                                            size: 25,
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsetsDirectional.fromSTEB(7, 0, 0, 0),
                                                                          child: AutoSizeText(
                                                                            _model.datePicked3 != null
                                                                                ? dateTimeFormat('Hm', _model.datePicked3)
                                                                                : 'Hora',
                                                                            textAlign: TextAlign.start,
                                                                            maxLines: 1,
                                                                            minFontSize: 12,
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  font: GoogleFonts.lexend(
                                                                                    fontWeight: FlutterFlowTheme.of(context)
                                                                                        .bodyMedium
                                                                                        .fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context)
                                                                                        .bodyMedium
                                                                                        .fontStyle,
                                                                                  ),
                                                                                  color: _model.wilDogWalkerWorkSwitchValue!
                                                                                      ? FlutterFlowTheme.of(context).secondaryBackground
                                                                                      : FlutterFlowTheme.of(context).secondaryBackground.withOpacity(0.5),
                                                                                  fontSize: 16,
                                                                                  letterSpacing: 0.0,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
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
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(0, 18, 0, 18),
                                                  child: FFButtonWidget(
                                                    onPressed: () async {
                                                      if (_model.datePicked1 == null) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text('Por favor selecciona una fecha')),
                                                        );
                                                        return;
                                                      }

                                                      final currentUser = Supabase.instance.client.auth.currentUser;
                                                      if (currentUser == null) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text('No se pudo identificar al usuario')),
                                                        );
                                                        return;
                                                      }

                                                      try {
                                                        bool isFullDay = !_model.wilDogWalkerWorkSwitchValue!;
                                                        final selectedDate = _model.datePicked1!.toIso8601String().split('T')[0];

                                                        // Verificar si ya existe un registro de excepción para este paseador
                                                        final existing = await Supabase.instance.client
                                                            .from('walker_exception_days')
                                                            .select('id')
                                                            .eq('walker_id', currentUser.id)
                                                            .maybeSingle();

                                                        final Map<String, dynamic> exceptionDayData = {
                                                          'walker_id': currentUser.id,
                                                          'rest_date': selectedDate,
                                                          'is_full_day': isFullDay,
                                                          'created_at': DateTime.now().toIso8601String(),
                                                        };

                                                        if (!isFullDay) {
                                                          if (_model.datePicked2 == null || _model.datePicked3 == null) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(content: Text('Por favor selecciona ambas horas')),
                                                            );
                                                            return;
                                                          }

                                                          if (_model.datePicked3!.isBefore(_model.datePicked2!)) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(content: Text('La hora de fin debe ser después de la hora de inicio')),
                                                            );
                                                            return;
                                                          }

                                                          exceptionDayData['start_time'] =
                                                              '${_model.datePicked2!.hour.toString().padLeft(2, '0')}:${_model.datePicked2!.minute.toString().padLeft(2, '0')}:00';
                                                          exceptionDayData['end_time'] =
                                                              '${_model.datePicked3!.hour.toString().padLeft(2, '0')}:${_model.datePicked3!.minute.toString().padLeft(2, '0')}:00';
                                                        }

                                                        if (existing != null) {
                                                          // Actualizar si ya existe un registro
                                                          await Supabase.instance.client
                                                              .from('walker_exception_days')
                                                              .update(exceptionDayData)
                                                              .eq('id', existing['id']);

                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                isFullDay
                                                                    ? 'Excepción actualizada como día completo'
                                                                    : 'Horario de excepción actualizado correctamente',
                                                              ),
                                                              duration: const Duration(seconds: 3),
                                                            ),
                                                          );
                                                        } else {
                                                          // Insertar nuevo registro si no existe
                                                          await Supabase.instance.client
                                                              .from('walker_exception_days')
                                                              .insert(exceptionDayData);

                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                isFullDay
                                                                    ? 'Día completo guardado como excepción'
                                                                    : 'Horario de excepción guardado correctamente',
                                                              ),
                                                              duration: const Duration(seconds: 3),
                                                            ),
                                                          );
                                                        }

                                                        if (!mounted) return;
                                                        context.push('/walker/home');
                                                      } catch (e) {
                                                        // Manejo elegante del error de duplicado (por si ocurre simultáneamente)
                                                        if (e.toString().contains('duplicate key value')) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(content: Text('Ya existe un registro de excepción, se actualizó automáticamente.')),
                                                          );
                                                        } else {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text('Error al guardar excepción: $e')),
                                                          );
                                                        }
                                                      }
                                                    },

                                                    text: 'Guardar',
                                                    options: FFButtonOptions(
                                                      width: 360,
                                                      height: 40,
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0, 0, 0, 0),
                                                      iconPadding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0, 0, 0, 0),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .accent1,
                                                      textStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmall
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .lexend(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontStyle,
                                                                ),
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                              ),
                                                      elevation: 0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                ),
                                              ],
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
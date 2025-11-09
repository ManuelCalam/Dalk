import '/backend/supabase/supabase.dart';
import '/cards/find_dog_walker_card/find_dog_walker_card_widget.dart';
import '/components/go_back_container/go_back_container_widget.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'find_dog_walker_model.dart';
export 'find_dog_walker_model.dart';
import 'package:http/http.dart' as http;

// String? recommendedWalker;
class FindDogWalkerWidget extends StatefulWidget {
  
  const FindDogWalkerWidget({
    super.key,
    required this.date,
    required this.time,
    required this.addressId,
    required this.petId,
    required this.walkDuration,
    required this.instructions,
    this.recommendedWalkerUUIDs = const [],
    
  });

  final DateTime? date;
  final DateTime? time;
  final int? addressId;
  final int? petId;
  final int walkDuration;
  final String instructions;
  final List<String> recommendedWalkerUUIDs; 
  

  static String routeName = 'findDogWalker';
  static String routePath = '/findDogWalker';

  @override
  State<FindDogWalkerWidget> createState() => _FindDogWalkerWidgetState();
}



class _FindDogWalkerWidgetState extends State<FindDogWalkerWidget> {
  late FindDogWalkerModel _model;
  String? recommendedWalker;
  

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FindDogWalkerModel());
    _model.findDogWalkerInputTextController ??= TextEditingController();
    _model.findDogWalkerInputFocusNode ??= FocusNode();

    //getWalkerRecommendation();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }
  List<Map<String, dynamic>> _sortWalkers(List<Map<String, dynamic>> paseadores) {
    print('DEBUG: _sortWalkers iniciado con ${paseadores.length} paseadores');
    print('DEBUG: recommendedWalkerUUIDs: ${widget.recommendedWalkerUUIDs}');
    
    try {
      // Si no hay recomendaciones, devolver lista normal
      if (widget.recommendedWalkerUUIDs.isEmpty) {
        print('DEBUG: No hay UUIDs recomendados, retornando lista original');
        return paseadores;
      }

      if (paseadores.isEmpty) {
        print('DEBUG: Lista de paseadores vacía');
        return paseadores;
      }

      final List<Map<String, dynamic>> recomendados = [];
      final List<Map<String, dynamic>> noRecomendados = [];

      print('DEBUG: Separando paseadores...');
      
      // Separar recomendados de no recomendados
      for (final paseador in paseadores) {
        try {
          final uuid = paseador['uuid']?.toString();
          print('DEBUG: Procesando paseador: ${paseador['name']}, UUID: $uuid');
          
          if (uuid != null && widget.recommendedWalkerUUIDs.contains(uuid)) {
            recomendados.add(paseador);
            print('DEBUG: Agregado a recomendados: ${paseador['name']}');
          } else {
            noRecomendados.add(paseador);
          }
        } catch (e) {
          print('DEBUG: Error procesando paseador individual: $e');
          noRecomendados.add(paseador); // Agregar a no recomendados por seguridad
        }
      }

      print('DEBUG: Recomendados encontrados: ${recomendados.length}');
      print('DEBUG: No recomendados: ${noRecomendados.length}');

      // Ordenar recomendados según el orden de recommendedWalkerUUIDs
      final recomendadosOrdenados = <Map<String, dynamic>>[];
      
      for (final recommendedUUID in widget.recommendedWalkerUUIDs) {
        try {
          print('DEBUG: Buscando UUID: $recommendedUUID');
          final index = recomendados.indexWhere((p) {
            final pUuid = p['uuid']?.toString();
            final match = pUuid == recommendedUUID;
            print('DEBUG: Comparando $pUuid con $recommendedUUID -> $match');
            return match;
          });
          
          if (index != -1) {
            recomendadosOrdenados.add(recomendados[index]);
            print('DEBUG: Agregado a ordenados: ${recomendados[index]['name']}');
          } else {
            print('DEBUG: UUID $recommendedUUID no encontrado en recomendados');
          }
        } catch (e) {
          print('DEBUG: Error buscando UUID $recommendedUUID: $e');
        }
      }

      final resultado = [...recomendadosOrdenados, ...noRecomendados];
      print('DEBUG: Resultado final: ${resultado.length} paseadores');
      
      return resultado;
      
    } catch (e, stackTrace) {
      print('DEBUG: ERROR CRÍTICO en _sortWalkers: $e');
      print('DEBUG: StackTrace: $stackTrace');
      return paseadores; // Si hay error, devolver lista original
    }
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
                width: MediaQuery.sizeOf(context).width * 1.0,
                height: MediaQuery.sizeOf(context).height * 0.1,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(0.0),
                    bottomRight: Radius.circular(0.0),
                    topLeft: Radius.circular(0.0),
                    topRight: Radius.circular(0.0),
                  ),
                ),
                child: wrapWithModel(
                  model: _model.notificationContainerModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const NotificationContainerWidget(),
                ),
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).tertiary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(0.0),
                      bottomRight: Radius.circular(0.0),
                      topLeft: Radius.circular(50.0),
                      topRight: Radius.circular(50.0),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Align(
                        alignment: const AlignmentDirectional(0.0, 0.0),
                        child: wrapWithModel(
                          model: _model.goBackContainerModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const GoBackContainerWidget(),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
                        child: Text(
                          'Paseadores encontrados',
                          textAlign: TextAlign.center,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.lexend(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 24.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                    color: FlutterFlowTheme.of(context).primary
                                  ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.9,
                          child: TextFormField(
                            controller: _model.findDogWalkerInputTextController,
                            focusNode: _model.findDogWalkerInputFocusNode,
                            autofocus: false,
                            enabled: true,
                            obscureText: false,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              isDense: false,
                              labelText: 'Buscar paseador',
                              labelStyle: FlutterFlowTheme.of(context).titleMedium.override(
                                    font: GoogleFonts.lexend(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context).primary,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                                  ),
                              alignLabelWithHint: false,
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsetsDirectional.fromSTEB(40, 0, 0, 0),
                              prefixIcon: const Icon(
                                Icons.search_outlined,
                                color: Color(0xFF484848),
                                size: 25,
                              ),
                            ),
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.lexend(
                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                  ),
                                  color: Colors.black,
                                  fontSize: 16,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                ),
                            cursorColor: FlutterFlowTheme.of(context).primaryText,
                            enableInteractiveSelection: true,
                            validator: _model.findDogWalkerInputTextControllerValidator
                                .asValidator(context),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 15.0),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.9,
                            height: double.infinity,
                            decoration: const BoxDecoration(),
                            child: FutureBuilder<List<dynamic>>(
                              future: Supabase.instance.client
                                .from('walkers_info')
                                .select()
                                .ilike(
                                  'name',
                                  _model.findDogWalkerInputTextController.text.trim().isEmpty
                                      ? '%'
                                      : '%${_model.findDogWalkerInputTextController.text.trim()}%',
                                ),

                              builder: (context, snapshot) {
                                // print(' Estado del FutureBuilder: ${snapshot.connectionState}');
                                
                                // Manejar estados de carga
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  print(' Cargando paseadores...');
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                // Manejar errores
                                if (snapshot.hasError) {
                                  print(' Error en FutureBuilder: ${snapshot.error}');
                                  print(' StackTrace: ${snapshot.stackTrace}');
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error_outline, color: FlutterFlowTheme.of(context).error, size: 50),
                                        const SizedBox(height: 10),
                                        const Text(
                                          'Error al cargar paseadores',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '${snapshot.error}',
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                if (snapshot.hasError) {
                                  print(' Error en FutureBuilder: ${snapshot.error}');
                                  return Center(child: Text('Error al cargar paseadores.'));
                                }

                                if (!snapshot.hasData) {
                                  return const Center(child: Text('No se encontraron paseadores.'));
                                }
                                  // // VERIFICAR ESTRUCTURA DE DATOS
                                  // print('DEBUG: Verificando estructura de paseadores...');
                                  // for (int i = 0; i < paseadores.length; i++) {
                                  //   final paseador = paseadores[i];
                                  //   print('DEBUG: Paseador $i:');
                                  //   print('DEBUG:   - UUID: ${paseador['uuid']} (tipo: ${paseador['uuid']?.runtimeType})');
                                  //   print('DEBUG:   - Name: ${paseador['name']}');
                                  //   print('DEBUG:   - Tiene UUID?: ${paseador['uuid'] != null}');
                                  // }

                                  // // VERIFICAR UUIDs RECOMENDADOS
                                  // print('DEBUG: UUIDs recomendados recibidos: ${widget.recommendedWalkerUUIDs}');
                                  // for (final uuid in widget.recommendedWalkerUUIDs) {
                                  //   print('DEBUG: UUID recomendado: $uuid (tipo: ${uuid.runtimeType})');
                                  // }

                                try {
                                  final paseadores = List<Map<String, dynamic>>.from(snapshot.data!);


                                  final selectedDate = widget.date!;
                                  final selectedTime = widget.time!;
                                  final selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
                                  final selectedTimeStr = DateFormat('HH:mm:ss').format(selectedTime);

                                  final paseadoresDisponibles = paseadores.where((p) {
                                  final uuid = p['uuid'] ?? 'Desconocido';
                                  final name = p['name'] ?? 'Sin nombre';
                                  String motivo = '';

                                  // --- Datos seleccionados ---
                                  final selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
                                  final selectedTimeStr = DateFormat('HH:mm:ss').format(selectedTime);

                                  // --- Datos del paseador ---
                                  final exceptionDate = p['exception_date'];
                                  final isFullDay = p['exception_full_day'];
                                  final exceptionStart = p['exception_start_time'];
                                  final exceptionEnd = p['exception_end_time'];
                                  final workingDays = (p['working_days'] as List?)?.cast<String>() ?? [];
                                  final startTime = p['start_time'];
                                  final endTime = p['end_time'];

                                  // --- Día actual (en texto) ---
                                  final dayName = DateFormat('EEEE', 'es_ES').format(selectedDate);
                                  final dayCapitalized = toBeginningOfSentenceCase(dayName.toLowerCase()); // lunes → Lunes

                                  // Comentarios para debug
                                  // print('\nEvaluando paseador: $name ($uuid)');
                                  // print('Fecha seleccionada: $selectedDateStr | Hora seleccionada: $selectedTimeStr');
                                  // print('Día de la semana: $dayCapitalized');
                                  // print('Días laborables: $workingDays');
                                  // print('Horario laboral: ${startTime ?? "N/A"} - ${endTime ?? "N/A"}');
                                  // print('Excepciones: $exceptionDate | Día completo: $isFullDay | Rango: $exceptionStart - $exceptionEnd');

                                  // --- Filtro 1: Día de excepción ---
                                  if (exceptionDate == selectedDateStr) {
                                    if (isFullDay == true) {
                                      motivo = 'Día completo de descanso por excepción.';
                                      print('Excluido → $motivo');
                                      return false;
                                    }
                                    if (exceptionStart != null && exceptionEnd != null) {
                                      final t = selectedTimeStr;
                                      final isInside = t.compareTo(exceptionStart) >= 0 && t.compareTo(exceptionEnd) <= 0;
                                      if (isInside) {
                                        motivo = 'Hora seleccionada dentro del rango de excepción ($exceptionStart - $exceptionEnd).';
                                        print('Excluido → $motivo');
                                        return false;
                                      }
                                    }
                                  }

                                  // --- Filtro 2: Día laboral ---
                                  if (!workingDays.contains(dayCapitalized)) {
                                    motivo = 'No trabaja los $dayCapitalized.';
                                    print('Excluido → $motivo');
                                    return false;
                                  }

                                  // --- Filtro 3: Horario laboral ---
                                  if (startTime != null && endTime != null) {
                                    final t = selectedTimeStr;
                                    final isInsideWorkingHours = t.compareTo(startTime) >= 0 && t.compareTo(endTime) <= 0;
                                    if (!isInsideWorkingHours) {
                                      motivo = 'No trabaja en la hora seleccionada ($selectedTimeStr).';
                                      print('Excluido → $motivo');
                                      return false;
                                    }
                                  }

                                  motivo = 'Disponible para la fecha y hora seleccionadas.';
                                  print('Incluido → $motivo');
                                  return true;
                                }).toList();


                                  print(' Paseadores disponibles después de filtrar: ${paseadoresDisponibles.length}');

                                  if (paseadoresDisponibles.isEmpty) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                                        child: Text(
                                          'No se encontraron paseadores disponibles.',
                                          textAlign: TextAlign.center, // Centra el texto horizontalmente
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            height: 1.4, // Espaciado entre líneas, mejora legibilidad
                                          ),
                                        ),
                                      ),
                                    );
                                  }


                                  final paseadoresOrdenados = _sortWalkers(paseadoresDisponibles);

                                  return ListView.builder(
                                    itemCount: paseadoresOrdenados.length,
                                    itemBuilder: (context, index) {
                                      final paseador = paseadoresOrdenados[index];
                                      final uuid = paseador['uuid']?.toString();
                                      final esRecomendado = uuid != null &&
                                          widget.recommendedWalkerUUIDs.contains(uuid);

                                      return FindDogWalkerCardWidget(
                                        nombre: paseador['name'] ?? 'Sin nombre',
                                        precio: paseador['fee']?.toString() ?? '0',
                                        calificacion: paseador['average_rating']?.toString() ?? '0',
                                        fotoUrl: paseador['photo_url'] ??
                                            'https://bsactypehgxluqyaymui.supabase.co/storage/v1/object/public/profile_pics/user.png',
                                        date: widget.date,
                                        time: widget.time,
                                        addressId: widget.addressId,
                                        petId: widget.petId,
                                        uuidPaseador: paseador['uuid'],
                                        recomendado: esRecomendado,
                                        walkDuration: widget.walkDuration,
                                        instructions: widget.instructions,
                                      );
                                    },
                                  );
                                } catch (e, stackTrace) {
                                  print(' ERROR crítico en builder: $e');
                                  print(' StackTrace: $stackTrace');
                                  return Center(child: Text('Error al procesar los paseadores: $e'));
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
      ),
    );
  }
}
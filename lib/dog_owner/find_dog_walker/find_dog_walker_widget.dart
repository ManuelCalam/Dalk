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
    required this.instructions
    
  });

  final DateTime? date;
  final DateTime? time;
  final int? addressId;
  final int? petId;
  final int walkDuration;
  final String instructions;
  

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

    obtenerRecomendacion();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> obtenerRecomendacion() async {
  try {
      final response = await http.post(
        Uri.parse('https://recommendwalker-rtwziiuflq-uc.a.run.app/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "pet_type": "mediano",
          "preferred_time": "tarde",
          "day_of_week": "lunes",
          "zone_id": "Colonia",
          "last_paseador_id": "Daniel",
          "avg_rating_threshold": 5,
          "previous_match_success": true,
          "gender_preference": "hombre",
          "duration_preference": 30
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          recommendedWalker = data["recommended_paseador_id"];
        });
        print(" Paseador recomendado: $recommendedWalker");
      } else {
        print(" Error IA: ${response.statusCode}");
      }
    } catch (e) {
      print("Error obteniendo recomendación: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // final String recommendedWalker = 'Paoo';
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
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 15.0),
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
                                      _model.findDogWalkerInputTextController.text.isEmpty
                                          ? '%' 
                                          : '%${_model.findDogWalkerInputTextController.text}%',
                                    ),
                                    
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}'));
                                  }

                                  if (!snapshot.hasData) {
                                    return const Center(child: CircularProgressIndicator());
                                  }

                                  // Copiamos los datos a una lista mutable
                                  final List<Map<String, dynamic>> paseadores = List<Map<String, dynamic>>.from(snapshot.data!);

                                  if (paseadores.isEmpty) {
                                    return const Center(child: Text('No se encontraron paseadores.'));
                                  }

                                  // Si hay recomendación, mover al inicio
                                  if (recommendedWalker != null) {
                                    final index = paseadores.indexWhere((p) =>
                                        p['name']?.toLowerCase() == recommendedWalker!.toLowerCase());
                                    if (index != -1) {
                                      final recomendado = paseadores.removeAt(index);
                                      paseadores.insert(0, recomendado);
                                    }
                                  }
                                  
                                  return ListView.builder(
                                    itemCount: paseadores.length,
                                    itemBuilder: (context, index) {
                                      final paseador = paseadores[index];
                                      final esRecomendado = paseador['name'] == recommendedWalker;
                                      
                                      return FindDogWalkerCardWidget(
                                        nombre: paseador['name'] ?? 'Sin nombre',
                                        precio: paseador['fee']?.toString() ?? '0',
                                        calificacion: paseador['average_rating']?.toString() ?? '0',
                                        fotoUrl: paseador['photo_url'] ?? 'https://img.freepik.com/vector-gratis/hombre-expresion-facial-seria-chaqueta-marron_1268-15451.jpg?semt=ais_hybrid&w=740&q=80',                                        date: widget.date,
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
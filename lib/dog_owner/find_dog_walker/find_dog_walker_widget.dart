import 'dart:collection';
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

  double? _precioMin;
  double? _precioMax;
  double? _calificacionMin;
  String? _ciudad;
  bool _isLoading = true;


  //Lista donde se guardan los paseadores filtrados
  List<Map<String, dynamic>> _listaPaseadores = [];

  List<String> _ciudades = []; // lista de ciudades de la BD
  FixedExtentScrollController? _wheelController;

  int get filtrosActivos {
    int count = 0;

    if (_precioMin != null || _precioMax != null) count++;
    if (_calificacionMin != null) count++;
    if (_model.findDogWalkerCityInputTextController.text.isNotEmpty) count++;

    return count;
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FindDogWalkerModel());
    _model.findDogWalkerInputTextController ??= TextEditingController();
    _model.findDogWalkerInputFocusNode ??= FocusNode();

    _model.findDogWalkerCityInputTextController ??= TextEditingController();
    _model.findDogWalkerCityInputFocusNode ??= FocusNode();

    getCiudades();  // Cargar ciudades al iniciar    
    
    // Cargar paseadores al iniciar
    getPaseadoresFiltrados().then((paseadores) {
      setState(() {
        _listaPaseadores = paseadores;
        _isLoading = false;
      });
    });

    obtenerRecomendacion();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Widget _precioButton(String label, double min, double max) {
    final bool selected = _precioMin == min && _precioMax == max;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _precioMin = min;
          _precioMax = max;
        });
      },
    );
  }

Widget _calificacionButton(
  String label,
  double min,
  void Function(void Function()) setModalState,
) {
  final bool selected = _calificacionMin == min;
  return ChoiceChip(
    label: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.star_rounded,
          color: Color(0xFFE2B433),
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 14,
            color: selected ? Colors.white : FlutterFlowTheme.of(context).primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
    selected: selected,
    selectedColor: FlutterFlowTheme.of(context).accent1,
    backgroundColor: FlutterFlowTheme.of(context).alternate, 
    onSelected: (_) {
      setModalState(() {
        if (_calificacionMin == min) {
          _calificacionMin = null; 
        } else {
          _calificacionMin = min; 
        }
      });
    },
  );
}



  // Función para obtener paseadores filtrados
  Future<List<Map<String, dynamic>>> getPaseadoresFiltrados({
    double? precioMin,
    double? precioMax,
    double? calificacionMin,
    String? ciudad,
  }) async {
    try {
      final supabase = Supabase.instance.client;

      // 1. Consulta base a la tabla correcta
      var query = supabase.from('walkers_info').select('*');

      // 2. Filtro por ciudad (working_area)
      if (ciudad != null && ciudad.isNotEmpty) {
        query = query.ilike('working_area', '%$ciudad%');
      }

      // 3. Filtro por precio (campo fue)
      if (precioMin != null) {
        query = query.gte('fee', precioMin);
      }
      if (precioMax != null) {
        query = query.lte('fee', precioMax);
      }

      // 4. Filtro por calificación mínima (campo average_rating)
      if (calificacionMin != null) {
        query = query.gte('average_rating', calificacionMin);
      }

      // Ejecutar query
      final paseadores = await query;

      return List<Map<String, dynamic>>.from(paseadores);

    } catch (e) {
      print('Error al obtener paseadores: $e');
      return [];
    }
  }


  Future<void> getCiudades() async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('walkers_info')
          .select('working_area');

      final ciudadesUnicas = LinkedHashSet<String>.from(
        response
            .map((row) => (row['working_area'] as String?)?.trim())
            .where((c) => c != null && c.isNotEmpty),
      ).toList();

      setState(() {
        _ciudades = ciudadesUnicas.toList();

        final initialIndex =
            _ciudad != null ? _ciudades.indexOf(_ciudad!) : 0;

        _wheelController = FixedExtentScrollController(
          initialItem: initialIndex >= 0 ? initialIndex : 0,
        );
      });
    } catch (e) {
      print("Error al obtener ciudades: $e");
    }
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
                            //onChanged: (_) => setState(() {}),

                            onChanged: (_) async {
                              final paseadores = await getPaseadoresFiltrados(
                                precioMin: _precioMin,
                                precioMax: _precioMax,
                                calificacionMin: _calificacionMin,
                                ciudad: _ciudad,
                              );

                              setState(() {
                                _listaPaseadores = paseadores
                                    .where((p) => p['name']
                                        .toString()
                                        .toLowerCase()
                                        .contains(_model.findDogWalkerInputTextController.text.toLowerCase()))
                                    .toList();
                              });
                            },




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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () {
                                final initialIndex = _ciudad != null ? _ciudades.indexOf(_ciudad!) : 0;

                                _wheelController = FixedExtentScrollController(
                                  initialItem: initialIndex >= 0 ? initialIndex : 0,
                            );
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                backgroundColor: FlutterFlowTheme.of(context).tertiary,
                                builder: (context) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Ordenar y filtrar",
                                          style: FlutterFlowTheme.of(context).titleMedium.override(
                                                fontWeight: FontWeight.bold,
                                                color: FlutterFlowTheme.of(context).primary
                                              ),
                                        ),
                                        const SizedBox(height: 12),

                                        StatefulBuilder(
                                          builder: (context, setModalState) {
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Filtrar por calificación",
                                                  style: GoogleFonts.lexend(
                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 8.0),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    _calificacionButton("3+", 3, setModalState),
                                                    const SizedBox(width: 8),
                                                    _calificacionButton("4+", 4, setModalState),
                                                    const SizedBox(width: 8),
                                                    _calificacionButton("5", 5, setModalState),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 12.0),

                                        // Filtro ciudad
                                       Container(
                                          width: MediaQuery.of(context).size.width * 0.7,
                                          height: 53, 
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context).alternate,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded( // evita overflow
                                                child: _ciudades.isEmpty
                                                    ? const Center(child: CircularProgressIndicator())
                                                    : ListWheelScrollView.useDelegate(
                                                  controller: _wheelController, 
                                                  itemExtent: 40,
                                                  perspective: 0.003,
                                                  diameterRatio: 2.0,
                                                  physics: const FixedExtentScrollPhysics(),
                                                  onSelectedItemChanged: (index) {
                                                    setState(() {
                                                      _ciudad = _ciudades[index];
                                                    });
                                                  },
                                                  childDelegate: ListWheelChildBuilderDelegate(
                                                    builder: (context, index) {
                                                      final ciudad = _ciudades[index];
                                                      final selected = ciudad == _ciudad;
                                                      return Center(
                                                        child: Text(
                                                          ciudad,
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                                            color: selected ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).secondaryBackground,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    childCount: _ciudades.length,
                                                  ),
                                                ),

                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(right: 10.0),
                                                child: Icon(
                                                  Icons.swipe_vertical_rounded,
                                                  color: FlutterFlowTheme.of(context).primary,
                                                  size: 28.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),


                                        const SizedBox(height: 20),

                                        // Botón aplicar
                                        ElevatedButton(
                                          onPressed: () async {
                                            Navigator.pop(context);

                                            final paseadores = await getPaseadoresFiltrados(
                                              precioMin: _precioMin,
                                              precioMax: _precioMax,
                                              calificacionMin: _calificacionMin,
                                              ciudad: _ciudad,
                                            );

                                            setState(() {
                                              _listaPaseadores = paseadores; 
                                            });
                                          },
                                            style: ElevatedButton.styleFrom(
                                            backgroundColor: FlutterFlowTheme.of(context).primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text("Aplicar filtros"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primary,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.filter_list, color: Colors.white, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Ordenar y filtrar ($filtrosActivos)",
                                    style: GoogleFonts.lexend(
                                      color: Colors.white,
                                      fontSize: 16, 
                                      fontWeight: FontWeight.w500, 
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : _listaPaseadores.isEmpty
                                  ? const Center(
                                      child: Text('No se encontraron paseadores.'),
                                    )
                                  : ListView.builder(
                                      itemCount: _listaPaseadores.length,
                                      itemBuilder: (context, index) {
                                        final paseador = _listaPaseadores[index];
                                        final esRecomendado =
                                            paseador['name'] == recommendedWalker;

                                        return FindDogWalkerCardWidget(
                                          nombre: paseador['name'] ?? 'Sin nombre',
                                          precio: paseador['fee']?.toString() ?? '0',
                                          calificacion:
                                              paseador['average_rating']?.toString() ?? '0',
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
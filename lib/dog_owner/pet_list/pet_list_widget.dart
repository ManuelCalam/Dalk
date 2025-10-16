import 'package:dalk/backend/supabase/supabase.dart';
import 'package:dalk/cards/pet_list_card/pet_list_card_widget.dart';

import '/components/go_back_container/go_back_container_widget.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pet_list_model.dart';
export 'pet_list_model.dart';

class PetListWidget extends StatefulWidget {
  const PetListWidget({super.key});

  static String routeName = 'petList';
  static String routePath = '/petList';

  @override
  State<PetListWidget> createState() => _PetListWidgetState();
}

class _PetListWidgetState extends State<PetListWidget> {
  late PetListModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pets = [];
  bool loading = true;


  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PetListModel());
    _loadPets(); // 👈 carga las mascotas al iniciar
  }

  Future<void> _loadPets() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() => loading = false);
        return;
      }

      final response = await supabase
          .from('pets')
          .select()
          .eq('uuid', user.id);

      setState(() {
        pets = List<Map<String, dynamic>>.from(response);
        loading = false;
      });
    } catch (e) {
      print('Error al cargar mascotas: $e');
      setState(() => loading = false);
    }
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
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                  ),
                ),
                child: wrapWithModel(
                  model: _model.notificationContainerModel,
                  updateCallback: () => safeSetState(() {}),
                  child: NotificationContainerWidget(),
                ),
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).tertiary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: wrapWithModel(
                          model: _model.goBackContainerModel,
                          updateCallback: () => safeSetState(() {}),
                          child: GoBackContainerWidget(),
                        ),
                      ),
                      AutoSizeText(
                        'Mis Mascotas',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lexend(
                                fontWeight: FontWeight.bold,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).primary,
                              fontSize: 24,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 15),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.9,
                            height: double.infinity,
                            decoration: BoxDecoration(),
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                              child: SingleChildScrollView(
                                primary: false,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    if (loading)
                                      const Center(child: CircularProgressIndicator())
                                    else if (pets.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Text(
                                          'No tienes mascotas registradas 🐾',
                                          style: FlutterFlowTheme.of(context).bodyMedium,
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    else
                                      for (final pet in pets)
                                        PetListCardWidget(
                                        petData: pet,
                                        onPetDeleted: () async {
                                          if (!mounted) return;  // seguridad si el widget fue desmontado
                                          await _loadPets();      // recarga la lista desde Supabase
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Mascota eliminada correctamente 🐾')),
                                          );
                                        },
                                      ),
                                  ],
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
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:dalk/SubscriptionProvider.dart';
import 'package:dalk/backend/supabase/supabase.dart';
import 'package:dalk/cards/pet_list_card/pet_list_card_widget.dart';
import 'package:dalk/dog_owner/banner_add_widget/banner_add_widget.dart';
import 'package:dalk/utils/ads_constants.dart';
import 'package:provider/provider.dart';

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
    _loadPets(); 
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
    final isPremium = context.watch<SubscriptionProvider>().isPremium;
    final screenWidth = MediaQuery.of(context).size.width;

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
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
                        child: AutoSizeText(
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
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 15),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.9,
                            height: double.infinity,
                            decoration: const BoxDecoration(),
                            child: Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                              child: SingleChildScrollView(
                                primary: false,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    if (loading)
                                      const Center(child: CircularProgressIndicator())  
                                    else
                                      for (final pet in pets)
                                        PetListCardWidget(
                                        petData: pet,
                                        onPetDeleted: () async {
                                          if (!mounted) return;  
                                          await _loadPets();     
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Mascota eliminada correctamente.')),
                                          );
                                        },
                                        onPetUpdated: () async {
                                          if (!mounted) return;
                                          await _loadPets();
                                        },
                                      ),

                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                        child: GestureDetector(
                                          onTap: () async {
                                            final shouldReload = await context.push('/owner/addPet');
                                            if (shouldReload == true) {
                                              await _loadPets(); 
                                            }
                                          },                    
                                          child: Container(
                                            width: MediaQuery.sizeOf(context).width,
                                            decoration: BoxDecoration(
                                              color: FlutterFlowTheme.of(context).primary,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(17),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Align(
                                                    alignment: AlignmentDirectional(0, 0),
                                                    child: Icon(
                                                      Icons.pets_rounded,
                                                      color: Color(0XFFFFFFFF),
                                                      size: 35,
                                                    ),
                                                  ),
                                                  AutoSizeText(
                                                    'Agregar mascota',
                                                    textAlign: TextAlign.center,
                                                    style: FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts.lexend(
                                                            fontWeight: FontWeight.w600,
                                                            fontStyle: FlutterFlowTheme.of(context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                          ),
                                                          color: const Color(0XFFFFFFFF),
                                                          fontSize: 19,
                                                          letterSpacing: 0.0,
                                                          fontWeight: FontWeight.w600,
                                                          fontStyle: FlutterFlowTheme.of(context)
                                                              .bodyMedium
                                                              .fontStyle,
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if(!isPremium)
                BannerAdWidget(
                  adUnitId: bannerPetLisId, 
                  maxWidth: screenWidth,
                ),
            ],
          ),
        ),
      ),
    );
  }
}


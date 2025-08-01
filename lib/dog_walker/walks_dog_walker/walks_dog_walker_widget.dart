import 'package:dalk/cards/current_walk_walker_card/current_walk_walker_card_widget.dart';
import 'package:dalk/cards/non_reviewed_dog_card/non_reviewed_dog_card_widget.dart';
import 'package:dalk/cards/requested_walk_walker_card/requested_walk_walker_card_widget.dart';
import 'package:dalk/cards/reviewed_dog_card/reviewed_dog_card_widget.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/go_back_container/go_back_container_widget.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_button_tabbar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'walks_dog_walker_model.dart';
export 'walks_dog_walker_model.dart';

class WalksDogWalkerWidget extends StatefulWidget {
  const WalksDogWalkerWidget({super.key});

  static String routeName = 'walks_dogWalker';
  static String routePath = '/walksDogWalker';

  @override
  State<WalksDogWalkerWidget> createState() => _WalksDogWalkerWidgetState();
}

class _WalksDogWalkerWidgetState extends State<WalksDogWalkerWidget>
    with TickerProviderStateMixin {
  late WalksDogWalkerModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WalksDogWalkerModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 3,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

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
                decoration: BoxDecoration(),
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
                    color: FlutterFlowTheme.of(context).secondary,
                  ),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height,
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
                        wrapWithModel(
                          model: _model.goBackContainerModel,
                          updateCallback: () => safeSetState(() {}),
                          child: GoBackContainerWidget(),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                          child: AutoSizeText(
                            'Paseos',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            minFontSize: 16,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
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
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 0, 0, 15),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.9,
                              decoration: BoxDecoration(),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment(0, 0),
                                    child: FlutterFlowButtonTabBar(
                                      useToggleButtonStyle: true,
                                      labelStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .override(
                                            font: GoogleFonts.lexend(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .titleMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleMedium
                                                      .fontStyle,
                                            ),
                                            fontSize: 16,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontStyle,
                                          ),
                                      unselectedLabelStyle: FlutterFlowTheme.of(
                                              context)
                                          .titleMedium
                                          .override(
                                            font: GoogleFonts.lexend(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .titleMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleMedium
                                                      .fontStyle,
                                            ),
                                            fontSize: 16,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontStyle,
                                          ),
                                      labelColor:
                                          FlutterFlowTheme.of(context).accent1,
                                      unselectedLabelColor: Color(0xFF717981),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context)
                                              .alternate,
                                      unselectedBackgroundColor:
                                          FlutterFlowTheme.of(context)
                                              .alternate,
                                      unselectedBorderColor:
                                          FlutterFlowTheme.of(context)
                                              .alternate,
                                      borderWidth: 0,
                                      borderRadius: 8,
                                      elevation: 0,
                                      labelPadding:
                                          EdgeInsetsDirectional.fromSTEB(
                                              3, 0, 7, 0),
                                      buttonMargin:
                                          EdgeInsetsDirectional.fromSTEB(
                                              8, 0, 8, 0),
                                      tabs: [
                                        Tab(
                                          text: 'Solicitados',
                                        ),
                                        Tab(
                                          text: 'En Curso',
                                        ),
                                        Tab(
                                          text: 'Completados',
                                        ),
                                      ],
                                      controller: _model.tabBarController,
                                      onTap: (i) async {
                                        [
                                          () async {},
                                          () async {},
                                          () async {}
                                        ][i]();
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                      controller: _model.tabBarController,
                                      children: [

                                        // -------- Pestaña de paseos por confirmar ----------
                                        Padding( 
                                          padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                          child: StreamBuilder<List<Map<String, dynamic>>>(
                                            stream: SupaFlow.client
                                                .from('walks')
                                                .stream(primaryKey: ['id'])
                                                .eq('walker_id', currentUserUid),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return Center(child: CircularProgressIndicator());
                                              }

                                              final walksList = snapshot.data!
                                                  .where((walk) =>
                                                      walk['status'] == 'Por confirmar' ||
                                                      walk['status'] == 'Aceptado' ||
                                                      walk['status'] == 'Rechazado' ||
                                                      walk['status'] == 'Cancelado')
                                                  .toList();

                                              if (walksList.isEmpty) {
                                                return Center(child: Text('No hay paseos solicitados.'));
                                              }

                                              return ListView.builder(
                                                padding: EdgeInsets.zero,
                                                shrinkWrap: true,
                                                itemCount: walksList.length,
                                                itemBuilder: (context, index) {
                                                  final walk = walksList[index];

                                                  return FutureBuilder<Map<String, dynamic>?>(
                                                    future: fetchWalkInfoFromView(walk['id']),
                                                    builder: (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return SizedBox(); 
                                                      }

                                                      final fullWalkData = snapshot.data!;
                                                      return RequestedWalkWalkerCardWidget(
                                                        id: fullWalkData['id'],
                                                        petName: fullWalkData['pet_name'] ?? '',
                                                        dogOwner: fullWalkData['owner_name'] ?? '',
                                                        date: fullWalkData['startTime'] != null
                                                            ? DateTime.tryParse(fullWalkData['startTime'])
                                                            : null,
                                                        time: fullWalkData['startTime'] != null
                                                            ? DateTime.tryParse(fullWalkData['startTime'])
                                                            : null,
                                                        status: fullWalkData['status'] ?? '',
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                          )
                                        ),

                                        // -------- Pestaña de paseos en curso ---------
                                        Padding( 
                                          padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                          child: StreamBuilder<List<Map<String, dynamic>>>(
                                            stream: SupaFlow.client
                                              .from('walks')
                                              .stream(primaryKey: ['id'])
                                              .eq('walker_id', currentUserUid),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return Center(child: CircularProgressIndicator());
                                              }
                                              final walksList = snapshot.data!
                                                .where((walk) => walk['status'] == 'En curso')
                                                .toList();

                                              if (walksList.isEmpty) {
                                                return Center(child: Text('No hay paseos en curso.'));
                                              }

                                              return ListView.builder(
                                                padding: EdgeInsets.zero,
                                                shrinkWrap: true,
                                                itemCount: walksList.length,
                                                itemBuilder: (context, index) {
                                                  final walk = walksList[index];

                                                  return FutureBuilder<Map<String, dynamic>?>(
                                                    future: fetchWalkInfoFromView(walk['id']),
                                                    builder: (context, snapshot) {
                                                      if(!snapshot.hasData){
                                                        return SizedBox();
                                                      }

                                                      final fullWalkData = snapshot.data!;
                                                      return CurrentWalkWalkerCardWidget(
                                                        id: fullWalkData['id'],
                                                        petName: fullWalkData['pet_name'] ?? '',
                                                        dogOwner: fullWalkData['owner_name'] ?? '',
                                                        time: fullWalkData['startTime'] != null
                                                            ? DateTime.tryParse(fullWalkData['startTime'])
                                                            : null,
                                                        returnTime: fullWalkData['endTime'] != null
                                                            ? DateTime.tryParse('1970-01-01T${fullWalkData['endTime']}')
                                                            : null,
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),

                                        // -------- Pestaña de paseos finalizados ---------
                                        Padding( 
                                            padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                            child: StreamBuilder<List<Map<String, dynamic>>>(
                                              stream: SupaFlow.client
                                                .from('walks_with_names')
                                                .stream(primaryKey: ['id'])
                                                .eq('walker_id', currentUserUid),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return Center(child: CircularProgressIndicator());
                                                }
                                                final finishedWalks = snapshot.data!
                                                  .where((walk) => walk['status'] == 'Finalizado')
                                                  .toList();

                                                if (finishedWalks.isEmpty) {
                                                  return Center(child: Text('No hay paseos finalizados.'));
                                                }

                                                return ListView.builder(
                                                  padding: EdgeInsets.zero,
                                                  shrinkWrap: true,
                                                  itemCount: finishedWalks.length,
                                                  itemBuilder: (context, index) {
                                                    final walk = finishedWalks[index];
                                                    return FutureBuilder<List<Map<String, dynamic>>>(
                                                      future: SupaFlow.client
                                                        .from('reviews')
                                                        .select()
                                                        .eq('walk_id', walk['id']),
                                                      builder: (context, reviewSnapshot) {
                                                        if (!reviewSnapshot.hasData) {
                                                          return SizedBox();
                                                        }
                                                        final reviews = reviewSnapshot.data!;
                                                        if (reviews.isNotEmpty) {
                                                          final review = reviews.first;
                                                          return ReviewedDogCardWidget(
                                                            dogName: walk['pet_name'] ?? '',
                                                            dogOwner: walk['owner_name'] ?? '',
                                                            time: walk['startTime'] != null
                                                                ? DateTime.tryParse(walk['startTime'])
                                                                : null,
                                                            fee: walk['fee']?.toString() ?? '',
                                                            rate: review['rating']?.toString() ?? '',
                                                          );
                                                        } else {
                                                          return NonReviewedDogCardWidget(
                                                            petName: walk['pet_name'] ?? '',
                                                            dogOwner: walk['owner_name'] ?? '',
                                                            time: walk['startTime'] != null
                                                                ? DateTime.tryParse(walk['startTime'])
                                                                : null,
                                                            fee: walk['fee']?.toString() ?? '',
                                                          );
                                                        }
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        
                                      ],
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

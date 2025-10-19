import 'package:dalk/auth/supabase_auth/auth_util.dart';
import 'package:dalk/backend/supabase/supabase.dart';
import 'package:dalk/cards/non_reviewed_dog_card/non_reviewed_dog_card_widget.dart';
import 'package:dalk/cards/non_reviewed_walk_card/non_reviewed_walk_card_widget.dart';
import 'package:dalk/cards/reviewed_dog_card/reviewed_dog_card_widget.dart';
import 'package:dalk/cards/reviewed_walk_card/reviewed_walk_card_widget.dart';

import '/components/go_back_container/go_back_container_widget.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'walks_record_model.dart';
export 'walks_record_model.dart';

class WalksRecordWidget extends StatefulWidget {
  const WalksRecordWidget({
    super.key,
    required this.userType
    });

    final String userType;

  static String routeName = 'walks_Record';
  static String routePath = '/walksRecord';

  @override
  State<WalksRecordWidget> createState() => _WalksRecordWidgetState();
}

class _WalksRecordWidgetState extends State<WalksRecordWidget> {
  late WalksRecordModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WalksRecordModel());
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
                      Align(
                        alignment: const AlignmentDirectional(0, 0),
                        child: wrapWithModel(
                          model: _model.goBackContainerModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const GoBackContainerWidget(),
                        ),
                      ),
                      AutoSizeText(
                        'Historial',
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
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 15),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.9,
                            height: double.infinity,
                            decoration: const BoxDecoration(),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                              child: SingleChildScrollView(
                                primary: false,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    if(widget.userType == 'Paseador') ...[
                                      Padding( 
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                        child: StreamBuilder<List<Map<String, dynamic>>>(
                                          stream: SupaFlow.client
                                            .from('walks_with_names')
                                            .stream(primaryKey: ['id'])
                                            .eq('walker_id', currentUserUid),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return const Center(child: CircularProgressIndicator());
                                            }
                                            final finishedWalks = snapshot.data!
                                              .where((walk) => walk['status'] == 'Finalizado')
                                              .toList();

                                            if (finishedWalks.isEmpty) {
                                              return const Center(child: Text('No hay paseos finalizados.'));
                                            }

                                            return ListView.builder(
                                              padding: EdgeInsets.zero,
                                              shrinkWrap: true, // ← MANTENER
                                              physics: const ClampingScrollPhysics(), // ← AGREGAR ESTO
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
                                                      return const SizedBox();
                                                    }
                                                    final reviews = reviewSnapshot.data!;
                                                    if (reviews.isNotEmpty) {
                                                      final review = reviews.first;
                                                      return ReviewedDogCardWidget(
                                                        id: walk['id'],
                                                        petName: walk['pet_name'] ?? '',
                                                        dogOwner: walk['owner_name'] ?? '',
                                                        duration: (walk['walk_duration_minutes'] as int?)?.toString() ?? '', 
                                                        fee: (walk['fee'] as int?)?.toString() ?? '', 
                                                        rate: review['rating']?.toString() ?? '',
                                                        photoUrl: walk['dog_photo_url'] ?? '', 
                                                        dogId: walk['dog_id'] ?? 0, 
                                                      );
                                                    } else {
                                                      return NonReviewedDogCardWidget(
                                                        id: walk['id'],
                                                        petName: walk['pet_name'] ?? '',
                                                        dogOwner: walk['owner_name'] ?? '',
                                                        duration: (walk['walk_duration_minutes'] as int?)?.toString() ?? '', 
                                                        fee: (walk['fee'] as int?)?.toString() ?? '', 
                                                        photoUrl: walk['dog_photo_url'] ?? '',
                                                        walkerId: walk['walker_id'] ?? '',
                                                        dogId: walk['dog_id'] ?? 0, 
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
                                    
                                    // Widget de paseos finalizados para usuario "Dueño"
                                    if (widget.userType == 'Dueño') ...[
                                      Padding( 
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                        child: StreamBuilder<List<Map<String, dynamic>>>(
                                          stream: SupaFlow.client
                                            .from('walks_with_names')
                                            .stream(primaryKey: ['id'])
                                            .eq('owner_id', currentUserUid),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return const Center(child: CircularProgressIndicator());
                                            }
                                            final finishedWalks = snapshot.data!
                                              .where((walk) => walk['status'] == 'Finalizado')
                                              .toList();

                                            if (finishedWalks.isEmpty) {
                                              return const Center(child: Text('No hay paseos finalizados.'));
                                            }

                                            return ListView.builder(
                                              padding: EdgeInsets.zero,
                                              shrinkWrap: true, // ← MANTENER
                                              physics: const ClampingScrollPhysics(), // ← AGREGAR ESTO
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
                                                      return const SizedBox();
                                                    }
                                                    final reviews = reviewSnapshot.data!;
                                                    if (reviews.isNotEmpty) {
                                                      final review = reviews.first;
                                                      return ReviewedWalkCardWidget(
                                                        id: walk['id'],
                                                        petName: walk['pet_name'] ?? '',
                                                        dogWalker: walk['walker_name'] ?? '',
                                                        duration: (walk['walk_duration_minutes'] as int?)?.toString() ?? '', 
                                                        fee: (walk['fee'] as int?)?.toString() ?? '', 
                                                        rate: review['rating']?.toString() ?? '',
                                                        photoUrl: walk['dog_photo_url'] ?? '',
                                                        walkerId: walk['walker_id'] ?? '',                     
                                                        dogId: walk['dog_id'] ?? 0, 
                                                      );
                                                    } else {
                                                      return NonReviewedWalkCardWidget(
                                                        id: walk['id'],
                                                        petName: walk['pet_name'] ?? '',
                                                        dogWalker: walk['walker_name'] ?? '',
                                                        duration: (walk['walk_duration_minutes'] as int?)?.toString() ?? '', 
                                                        fee: (walk['fee'] as int?)?.toString() ?? '', 
                                                        photoUrl: walk['dog_photo_url'] ?? '',
                                                        walkerId: walk['walker_id'] ?? '',
                                                        dogId: walk['dog_id'] ?? 0, 
                                                      );
                                                    }
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ]
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

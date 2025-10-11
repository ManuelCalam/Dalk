import 'package:dalk/common/notifications/notifications_widget.dart';
import 'package:dalk/components/not_scheduled_walk_container/not_scheduled_walk_container_widget.dart';
import 'package:dalk/components/scheduled_walk_container/scheduled_walk_container_widget.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/go_back_container/go_back_container_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'current_walk_model.dart';
export 'current_walk_model.dart';

class CurrentWalkWidget extends StatefulWidget {
  const CurrentWalkWidget({super.key});

  static String routeName = 'CurrentWalk';
  static String routePath = '/currentWalk';

  @override
  State<CurrentWalkWidget> createState() => _CurrentWalkWidgetState();
}

class _CurrentWalkWidgetState extends State<CurrentWalkWidget> {
  late CurrentWalkModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? walkId;
  String? userType;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkCurrentWalk();
    _model = createModel(context, () => CurrentWalkModel());


  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> checkCurrentWalk() async {
    // Obtener tipo de usuario
    final userRes = await Supabase.instance.client
        .from('users')
        .select('usertype')
        .eq('uuid', currentUserUid)
        .maybeSingle();

    userType = userRes?['usertype'];

    // Buscar paseo en curso
    final walkRes = await Supabase.instance.client
        .from('walks')
        .select('id')
        .eq(userType == 'Dueño' ? 'owner_id' : 'walker_id', currentUserUid)
        .eq('status', 'En curso')
        .maybeSingle();

    if (walkRes != null) {
      walkId = walkRes['id'].toString();
      print('Walk encontrado: $walkRes');
      print('Tipo de usuario: $userType');
    }

    setState(() {
      isLoading = false;
    });
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
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: Align(
                        alignment: const AlignmentDirectional(1, 0),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 15, 5),
                          child: Container(
                            width: 40,
                            height: 70,
                            decoration: const BoxDecoration(),
                            alignment: const AlignmentDirectional(1, 0),
                            child: FlutterFlowIconButton(
                              borderRadius: 8,
                              buttonSize: 40,
                              icon: Icon(
                                Icons.notifications_sharp,
                                color: FlutterFlowTheme.of(context).alternate,
                                size: 26,
                              ),
                              onPressed: () {
                                context.pushNamed(NotificationsWidget.routeName);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height * 0.9,
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
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                        child: Text(
                          'Paseos',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.lexend(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
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
                            decoration: const BoxDecoration(),
                            child: ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: [
                                isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : ListView(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    children: [
                                      if (walkId != null && userType != null)
                                        ScheduledWalkContainerWidget(
                                          walkId: walkId!,
                                          userType: userType!,
                                        )
                                      else
                                        NotScheduledWalkContainerWidget(userType: '',),
                                    ],
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

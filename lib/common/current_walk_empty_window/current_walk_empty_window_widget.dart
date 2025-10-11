import 'package:dalk/components/not_scheduled_walk_container/not_scheduled_walk_container_widget.dart';
import 'package:dalk/components/scheduled_walk_container/scheduled_walk_container_widget.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'current_walk_empty_window_model.dart';
export 'current_walk_empty_window_model.dart';

class CurrentWalkEmptyWindowWidget extends StatefulWidget {
  const CurrentWalkEmptyWindowWidget({
    super.key,
  });

  static String routeName = 'currentWalk_empyWindow';
  static String routePath = '/currentWalkEmpyWindow';

  @override
  State<CurrentWalkEmptyWindowWidget> createState() =>
      _CurrentWalkEmpyWindowWidgetState();
}

class _CurrentWalkEmpyWindowWidgetState
    extends State<CurrentWalkEmptyWindowWidget> {
  late CurrentWalkEmptyWindowModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? currentWalkId;
  String userType = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CurrentWalkEmptyWindowModel());
    checkCurrentWalk();
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
        .select('current_walk_id')
        .eq(userType == 'Dueño' ? 'owner_id' : 'walker_id', currentUserUid)
        .eq('status', 'En curso')
        .maybeSingle();

    if (walkRes != null) {
      currentWalkId = walkRes['id'].toString();
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
              Expanded(
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).tertiary,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: MediaQuery.sizeOf(context).height * 0.1,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondary,
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 4,
                              color: Color(0xFF162C43),
                              offset: Offset(
                                0,
                                2,
                              ),
                            )
                          ],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Align(
                              alignment: const AlignmentDirectional(-1, 0),
                              child: Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(15, 0, 0, 0),
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
                                    color: FlutterFlowTheme.of(context).secondary,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: const AlignmentDirectional(0, 0),
                                child: Text(
                                  'Paseo en curso',
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
                                        fontSize: 18,
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
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(0, 0, 15, 0),
                              child: Icon(
                                Icons.notifications_sharp,
                                color: FlutterFlowTheme.of(context).accent2,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 15),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            decoration: const BoxDecoration(),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  // Mostrar loading mientras se carga
                                  if (isLoading)
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(0, 50, 0, 0),
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          FlutterFlowTheme.of(context).primary,
                                        ),
                                      ),
                                    )
                                  else
                                    // Mostrar contenido una vez cargado
                                    if (currentWalkId != null)
                                      ScheduledWalkContainerWidget(
                                        walkId: currentWalkId!,
                                        userType: userType,
                                      )
                                    else
                                      NotScheduledWalkContainerWidget(userType: userType),
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
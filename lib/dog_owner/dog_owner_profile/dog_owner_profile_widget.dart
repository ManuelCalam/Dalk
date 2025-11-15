import 'package:dalk/backend/supabase/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import 'dog_owner_profile_model.dart';
export 'dog_owner_profile_model.dart';
import '/user_provider.dart';
import 'package:provider/provider.dart';

class DogOwnerProfileWidget extends StatefulWidget {
  const DogOwnerProfileWidget({super.key});

  static String routeName = 'dogOwnerProfile';
  static String routePath = '/dogOwnerProfile';

  @override
  State<DogOwnerProfileWidget> createState() => _DogOwnerProfileWidgetState();
}

class _DogOwnerProfileWidgetState extends State<DogOwnerProfileWidget> {
  late DogOwnerProfileModel _model;

  //imagen
  // File? _ownerImage;
  // File? _walkerImage;
  // File? _tempImage;
  // final ImagePicker _picker = ImagePicker();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DogOwnerProfileModel());
    context.read<UserProvider>().loadUser(forceRefresh: true);
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    // final isPremium = context.watch<SubscriptionProvider>().isPremium;
    final user = context.watch<UserProvider>().user;
    final nombre = (user?.name?.split(" ").first) ?? "User";
    final photoUrl = user?.photoUrl ?? "";
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
                decoration: const BoxDecoration(
                  color: Color(0xFF162C43),
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

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 35, 0, 15),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.9,
                            decoration: const BoxDecoration(),
                            child: ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: [
                                Align(
                                  alignment: const AlignmentDirectional(0, 0),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                                    child: CircleAvatar(
                                      radius: 60,
                                      //funcion de la imagen
                                      backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                                      child: photoUrl.isEmpty ? const Icon(Icons.person, size: 60) : null,
                                    ),
                                  ),
                                ),
                                AutoSizeText(
                                nombre,
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.lexend(
                                          fontWeight: FontWeight.w800,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        fontSize: 25,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w800,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsetsDirectional.fromSTEB(
                                //       0, 5, 0, 0),
                                //   child: Text(
                                //     'Plan Gratuito',
                                //     // isPremium ? 'Plan Premium' : 'Plan Gratuito',
                                //     style: FlutterFlowTheme.of(context)
                                //         .bodyMedium
                                //         .override(
                                //           font: GoogleFonts.lexend(
                                //             fontWeight: FontWeight.w500,
                                //             fontStyle:
                                //                 FlutterFlowTheme.of(context)
                                //                     .bodyMedium
                                //                     .fontStyle,
                                //           ),
                                //           color: FlutterFlowTheme.of(context)
                                //               .accent1,
                                //           fontSize: 20,
                                //           letterSpacing: 0.0,
                                //           fontWeight: FontWeight.w500,
                                //           fontStyle:
                                //               FlutterFlowTheme.of(context)
                                //                   .bodyMedium
                                //                   .fontStyle,
                                //         ),
                                //   ),
                                // ),
                                // Padding(
                                //   padding: const EdgeInsetsDirectional.fromSTEB(
                                //       0, 5, 0, 0),
                                //   child: InkWell(
                                //     splashColor: Colors.transparent,
                                //     focusColor: Colors.transparent,
                                //     hoverColor: Colors.transparent,
                                //     highlightColor: Colors.transparent,
                                //     onTap: () async {
                                //       context.pushNamed(
                                //           PremiumPlanInfoWidget.routeName);
                                //     },
                                //     child: Container(
                                //       width: MediaQuery.sizeOf(context).width,
                                //       constraints: BoxConstraints(
                                //         minHeight:
                                //             MediaQuery.sizeOf(context).height *
                                //                 0.04,
                                //       ),
                                //       decoration: BoxDecoration(
                                //         color: FlutterFlowTheme.of(context)
                                //             .primary,
                                //         borderRadius: BorderRadius.circular(5),
                                //       ),
                                //       child: Row(
                                //         mainAxisSize: MainAxisSize.max,
                                //         children: [
                                //           Expanded(
                                //             flex: 8,
                                //             child: Align(
                                //               alignment:
                                //                   const AlignmentDirectional(-1, 0),
                                //               child: Padding(
                                //                 padding: const EdgeInsetsDirectional
                                //                     .fromSTEB(5, 0, 0, 0),
                                //                 child: AutoSizeText(
                                //                   //  isPremium ? "Revisa tus beneficios premium!" :
                                //                   //   'Descubre los beneficios del plan premium!' ,
                                //                   'Descubre los beneficios del plan premium!',
                                //                   textAlign: TextAlign.start,
                                //                   minFontSize: 10,
                                //                   style: FlutterFlowTheme.of(
                                //                           context)
                                //                       .bodyMedium
                                //                       .override(
                                //                         font:
                                //                             GoogleFonts.lexend(
                                //                           fontWeight:
                                //                               FlutterFlowTheme.of(
                                //                                       context)
                                //                                   .bodyMedium
                                //                                   .fontWeight,
                                //                           fontStyle:
                                //                               FlutterFlowTheme.of(
                                //                                       context)
                                //                                   .bodyMedium
                                //                                   .fontStyle,
                                //                         ),
                                //                         color: Colors.white,
                                //                         fontSize: 14,
                                //                         letterSpacing: 0.0,
                                //                         fontWeight:
                                //                             FlutterFlowTheme.of(
                                //                                     context)
                                //                                 .bodyMedium
                                //                                 .fontWeight,
                                //                         fontStyle:
                                //                             FlutterFlowTheme.of(
                                //                                     context)
                                //                                 .bodyMedium
                                //                                 .fontStyle,
                                //                       ),
                                //                 ),
                                //               ),
                                //             ),
                                //           ),
                                //           Flexible(
                                //             child: Align(
                                //               alignment:
                                //                   const AlignmentDirectional(1, 0),
                                //               child: Padding(
                                //                 padding: const EdgeInsetsDirectional
                                //                     .fromSTEB(0, 0, 5, 0),
                                //                 child: Icon(
                                //                   Icons.chevron_right_outlined,
                                //                   color: FlutterFlowTheme.of(
                                //                           context)
                                //                       .tertiary,
                                //                   size: 24,
                                //                 ),
                                //               ),
                                //             ),
                                //           ),
                                //         ],
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                Align(
                                  alignment: const AlignmentDirectional(-1, 0),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0, 25, 0, 0),
                                    child: AutoSizeText(
                                      'Información personal',
                                      textAlign: TextAlign.start,
                                      minFontSize: 12,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.lexend(
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .accent1,
                                            fontSize: 16,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      context.push('/owner/updateProfile');
                                    },
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width,
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                              0.055,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(5),
                                          topRight: Radius.circular(5),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Align(
                                            alignment:
                                                const AlignmentDirectional(-1, 0),
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(8, 0, 0, 0),
                                              child: Icon(
                                                Icons.account_circle_sharp,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                size: 25,
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Align(
                                              alignment:
                                                  const AlignmentDirectional(-1, 0),
                                              child: Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(8, 0, 0, 0),
                                                child: Text(
                                                  'Mi perfil',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.lexend(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        fontSize: 16,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                                const AlignmentDirectional(1, 0),
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(0, 0, 15, 0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  context.push('/owner/updateProfile');
                                                },
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  size: 25,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 10, 0, 0),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      context.push('/owner/paymentMethods');
                                    },
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width,
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                              0.055,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(5),
                                          topRight: Radius.circular(5),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    8, 0, 0, 0),
                                            child: Icon(
                                              Icons.wallet_rounded,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              size: 25,
                                            ),
                                          ),
                                          Flexible(
                                            child: Align(
                                              alignment:
                                                  const AlignmentDirectional(-1, 0),
                                              child: Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(8, 0, 0, 0),
                                                child: Text(
                                                  'Métodos de pago',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.lexend(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        fontSize: 16,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                                const AlignmentDirectional(1, 0),
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(0, 0, 15, 0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  context.push('/owner/paymentMethods');
                                                },
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  size: 25,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 10, 0, 0),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      GoRouter.of(context).go('/owner/petList'); 
                                    },
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width,
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                              0.055,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(5),
                                          topRight: Radius.circular(5),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    8, 0, 0, 0),
                                            child: Icon(
                                              Icons.pets_outlined,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              size: 25,
                                            ),
                                          ),
                                          Flexible(
                                            child: Align(
                                              alignment:
                                                  const AlignmentDirectional(-1, 0),
                                              child: Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(8, 0, 0, 0),
                                                child: Text(
                                                  'Mis mascotas',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.lexend(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        fontSize: 16,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                                const AlignmentDirectional(1, 0),
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(0, 0, 15, 0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  GoRouter.of(context).go('/owner/petList');
                                                },
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  size: 25,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 10, 0, 0),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      context.push('/owner/trackerDetails');
                                    },
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width,
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                              0.055,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(5),
                                          topRight: Radius.circular(5),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    8, 0, 0, 0),
                                            child: Icon(
                                              Icons.location_pin,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              size: 25,
                                            ),
                                          ),
                                          Flexible(
                                            child: Align(
                                              alignment:
                                                  const AlignmentDirectional(-1, 0),
                                              child: Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(8, 0, 0, 0),
                                                child: Text(
                                                  'Rastrea a tu perro',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.lexend(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        fontSize: 16,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                                const AlignmentDirectional(1, 0),
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(0, 0, 15, 0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  context.push('/owner/trackerDetails');
                                                },
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  size: 25,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 10, 0, 0),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      context.push('/owner/addTracker');
                                    },
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width,
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                              0.055,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(5),
                                          topRight: Radius.circular(5),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    8, 0, 0, 0),
                                            child: Icon(
                                              Icons.track_changes_rounded,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              size: 25,
                                            ),
                                          ),
                                          Flexible(
                                            child: Align(
                                              alignment:
                                                  const AlignmentDirectional(-1, 0),
                                              child: Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(8, 0, 0, 0),
                                                child: Text(
                                                  '¿Ya recibiste el rastreador?',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.lexend(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        fontSize: 16,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                                const AlignmentDirectional(1, 0),
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(0, 0, 15, 0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  context.push('/owner/addTracker');
                                                },
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  size: 25,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 10, 0, 0),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      context.push('/owner/ownerDebt');
                                    },
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width,
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                              0.055,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(5),
                                          topRight: Radius.circular(5),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    8, 0, 0, 0),
                                            child: Icon(
                                              Icons.attach_money_rounded,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              size: 25,
                                            ),
                                          ),
                                          Flexible(
                                            child: Align(
                                              alignment:
                                                  const AlignmentDirectional(-1, 0),
                                              child: Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(8, 0, 0, 0),
                                                child: Text(
                                                  'Pagar adeudo',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.lexend(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        fontSize: 16,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                                const AlignmentDirectional(1, 0),
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(0, 0, 15, 0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  context.push('/owner/ownerDebt');
                                                },
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  size: 25,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                Align(
                                  alignment: const AlignmentDirectional(-1, 0),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0, 25, 0, 0),
                                    child: AutoSizeText(
                                      'Soporte Técnico',
                                      textAlign: TextAlign.start,
                                      minFontSize: 12,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.lexend(
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .accent1,
                                            fontSize: 16,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 10, 0, 0),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      context.push('/owner/frequentQuestions');
                                    },
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width,
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                              0.055,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(5),
                                          topRight: Radius.circular(5),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    8, 0, 0, 0),
                                            child: Icon(
                                              Icons.question_mark_rounded,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              size: 25,
                                            ),
                                          ),
                                          Flexible(
                                            child: Align(
                                              alignment:
                                                  const AlignmentDirectional(-1, 0),
                                              child: Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(8, 0, 0, 0),
                                                child: Text(
                                                  'Preguntas frecuentes',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.lexend(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        fontSize: 16,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                                const AlignmentDirectional(1, 0),
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(0, 0, 15, 0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  context.push('/owner/frequentQuestions');
                                                },
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  size: 25,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 10, 0, 0),
                                  child: Container(
                                    width: MediaQuery.sizeOf(context).width,
                                    height: MediaQuery.sizeOf(context).height *
                                        0.055,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(5),
                                        bottomRight: Radius.circular(5),
                                        topLeft: Radius.circular(5),
                                        topRight: Radius.circular(5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  8, 0, 0, 0),
                                          child: Icon(
                                            Icons.error_outline,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            size: 25,
                                          ),
                                        ),
                                        Flexible(
                                          child: Align(
                                            alignment: const AlignmentDirectional(-1, 0),
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor: Colors.transparent,
                                                onTap: () {
                                                  context.push(
                                                    '/WebView',
                                                    extra: <String, dynamic>{
                                                      'url': 'https://dalk-legal-git-main-noe-ibarras-projects.vercel.app/?_vercel_share=H06ZuiEgfwHGNcHZ9AdimDz34FNJepDa',
                                                      'title': 'Acerca de Nosotros',
                                                    },
                                                  );                                           
                                                },
                                                child: Text(
                                                  'Acerca de nosotros',
                                                  textAlign: TextAlign.start,
                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                    font: GoogleFonts.lexend(
                                                      fontWeight: FontWeight.w500,
                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                    fontSize: 16,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              const AlignmentDirectional(1, 0),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0, 0, 15, 0),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () {
                                                context.push(
                                                  '/WebView',
                                                  extra: <String, dynamic>{
                                                    'url': 'https://dalk-legal-git-main-noe-ibarras-projects.vercel.app/?_vercel_share=H06ZuiEgfwHGNcHZ9AdimDz34FNJepDa',
                                                    'title': 'Acerca de Nosotros',
                                                  },
                                                );                                           
                                              },
                                              child: Icon(
                                                Icons.arrow_forward_ios,
                                                color: FlutterFlowTheme.of(
                                                        context)
                                                    .primary,
                                                size: 25,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 30, 0, 0),
                                  child: FFButtonWidget(
                                    onPressed: () async {
                                      try {
                                        await Supabase.instance.client.auth.signOut();

                                        // Limpiar cahcé
                                        final prefs = await SharedPreferences.getInstance();
                                        await prefs.clear();

                                        if (context.mounted) {
                                          context.read<UserProvider>().clearUser();
                                        }

                                        if (context.mounted) {
                                          context.go('/login');
                                        }

                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error cerrando sesión: $e')),
                                          );
                                        }
                                      }
                                    },
                                    text: 'Cerrar Sesión',

                                    options: FFButtonOptions(
                                      width: MediaQuery.sizeOf(context).width,
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                              0.05,
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0, 0, 0, 0),
                                      iconAlignment: IconAlignment.end,
                                      iconPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 0, 0, 0),
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.lexend(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                            color: Colors.white,
                                            fontSize: 16,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                      elevation: 0,
                                      borderRadius: BorderRadius.circular(8),
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
            ],
          ),
        ),
      ),
    );
  }
}
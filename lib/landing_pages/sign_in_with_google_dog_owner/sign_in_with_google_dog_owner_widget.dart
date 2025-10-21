import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/go_back_container/go_back_container_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'sign_in_with_google_dog_owner_model.dart';
export 'sign_in_with_google_dog_owner_model.dart';

class SignInWithGoogleDogOwnerWidget extends StatefulWidget {
  const SignInWithGoogleDogOwnerWidget({super.key});

  static String routeName = 'signInWithGoogle_DogOwner';
  static String routePath = '/signInWithGoogleDogOwner';

  @override
  State<SignInWithGoogleDogOwnerWidget> createState() =>
      _SignInWithGoogleDogOwnerWidgetState();
}

class _SignInWithGoogleDogOwnerWidgetState
    extends State<SignInWithGoogleDogOwnerWidget> {
  late SignInWithGoogleDogOwnerModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SignInWithGoogleDogOwnerModel());

    _model.nameInputTextController ??= TextEditingController();
    _model.nameInputFocusNode ??= FocusNode();

    _model.phoneInputTextController ??= TextEditingController();
    _model.phoneInputFocusNode ??= FocusNode();

    _model.neighborhoodInputTextController ??= TextEditingController();
    _model.neighborhoodInputFocusNode ??= FocusNode();
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
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: double.infinity,
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
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 15),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.9,
                            decoration: BoxDecoration(),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                    width: MediaQuery.sizeOf(context).width,
                                    decoration: BoxDecoration(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Align(
                                          alignment: AlignmentDirectional(0, 0),
                                          child: AutoSizeText(
                                            'Dueño',
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            minFontSize: 20,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.lexend(
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  fontSize: 30,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                        Align(
                                          alignment: AlignmentDirectional(0, 0),
                                          child: AutoSizeText(
                                            '!Solo faltan unos datos!',
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            minFontSize: 8,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.lexend(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .accent1,
                                                  fontSize: 14,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(),
                                          child: Icon(
                                            Icons.blind_sharp,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            size: 100,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.sizeOf(context).width,
                                    decoration: BoxDecoration(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Form(
                                          key: _model.formKey,
                                          autovalidateMode:
                                              AutovalidateMode.disabled,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 20, 0, 0),
                                                child: Container(
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                          .width,
                                                  child: TextFormField(
                                                    controller: _model
                                                        .nameInputTextController,
                                                    focusNode: _model
                                                        .nameInputFocusNode,
                                                    autofocus: false,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      labelStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .lexend(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                fontSize: 16,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                              ),
                                                      hintText: 'Nombre',
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .lexend(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                fontSize: 16,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                              ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate,
                                                      prefixIcon: Icon(
                                                        Icons.phone,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        size: 25,
                                                      ),
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .lexend(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
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
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primaryText,
                                                    validator: _model
                                                        .nameInputTextControllerValidator
                                                        .asValidator(context),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 20, 0, 0),
                                                child: Container(
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                          .width,
                                                  child: TextFormField(
                                                    controller: _model
                                                        .phoneInputTextController,
                                                    focusNode: _model
                                                        .phoneInputFocusNode,
                                                    autofocus: false,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      labelStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .lexend(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                fontSize: 16,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                              ),
                                                      hintText: 'Teléfono',
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .lexend(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                fontSize: 16,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                              ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate,
                                                      prefixIcon: Icon(
                                                        Icons.phone,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        size: 25,
                                                      ),
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .lexend(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
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
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                    keyboardType:
                                                        TextInputType.phone,
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primaryText,
                                                    validator: _model
                                                        .phoneInputTextControllerValidator
                                                        .asValidator(context),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .allow(
                                                              RegExp('[0-9]'))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // Padding(
                                              //   padding: EdgeInsetsDirectional
                                              //       .fromSTEB(0, 18, 0, 0),
                                              //   child: Container(
                                              //     width:
                                              //         MediaQuery.sizeOf(context)
                                              //             .width,
                                              //     child: TextFormField(
                                              //       controller: _model
                                              //           .neighborhoodInputTextController,
                                              //       focusNode: _model
                                              //           .neighborhoodInputFocusNode,
                                              //       autofocus: false,
                                              //       obscureText: false,
                                              //       decoration: InputDecoration(
                                              //         isDense: true,
                                              //         labelStyle:
                                              //             FlutterFlowTheme.of(
                                              //                     context)
                                              //                 .labelMedium
                                              //                 .override(
                                              //                   font:
                                              //                       GoogleFonts
                                              //                           .lexend(
                                              //                     fontWeight: FlutterFlowTheme.of(
                                              //                             context)
                                              //                         .labelMedium
                                              //                         .fontWeight,
                                              //                     fontStyle: FlutterFlowTheme.of(
                                              //                             context)
                                              //                         .labelMedium
                                              //                         .fontStyle,
                                              //                   ),
                                              //                   color: FlutterFlowTheme.of(
                                              //                           context)
                                              //                       .primary,
                                              //                   fontSize: 16,
                                              //                   letterSpacing:
                                              //                       0.0,
                                              //                   fontWeight: FlutterFlowTheme.of(
                                              //                           context)
                                              //                       .labelMedium
                                              //                       .fontWeight,
                                              //                   fontStyle: FlutterFlowTheme.of(
                                              //                           context)
                                              //                       .labelMedium
                                              //                       .fontStyle,
                                              //                 ),
                                              //         hintText: 'Colonia',
                                              //         hintStyle:
                                              //             FlutterFlowTheme.of(
                                              //                     context)
                                              //                 .labelMedium
                                              //                 .override(
                                              //                   font:
                                              //                       GoogleFonts
                                              //                           .lexend(
                                              //                     fontWeight: FlutterFlowTheme.of(
                                              //                             context)
                                              //                         .labelMedium
                                              //                         .fontWeight,
                                              //                     fontStyle: FlutterFlowTheme.of(
                                              //                             context)
                                              //                         .labelMedium
                                              //                         .fontStyle,
                                              //                   ),
                                              //                   color: FlutterFlowTheme.of(
                                              //                           context)
                                              //                       .primary,
                                              //                   fontSize: 16,
                                              //                   letterSpacing:
                                              //                       0.0,
                                              //                   fontWeight: FlutterFlowTheme.of(
                                              //                           context)
                                              //                       .labelMedium
                                              //                       .fontWeight,
                                              //                   fontStyle: FlutterFlowTheme.of(
                                              //                           context)
                                              //                       .labelMedium
                                              //                       .fontStyle,
                                              //                 ),
                                              //         enabledBorder:
                                              //             OutlineInputBorder(
                                              //           borderSide: BorderSide(
                                              //             color:
                                              //                 Color(0x00000000),
                                              //             width: 1,
                                              //           ),
                                              //           borderRadius:
                                              //               BorderRadius
                                              //                   .circular(20),
                                              //         ),
                                              //         focusedBorder:
                                              //             OutlineInputBorder(
                                              //           borderSide: BorderSide(
                                              //             color:
                                              //                 Color(0x00000000),
                                              //             width: 1,
                                              //           ),
                                              //           borderRadius:
                                              //               BorderRadius
                                              //                   .circular(20),
                                              //         ),
                                              //         errorBorder:
                                              //             OutlineInputBorder(
                                              //           borderSide: BorderSide(
                                              //             color: FlutterFlowTheme
                                              //                     .of(context)
                                              //                 .error,
                                              //             width: 1,
                                              //           ),
                                              //           borderRadius:
                                              //               BorderRadius
                                              //                   .circular(20),
                                              //         ),
                                              //         focusedErrorBorder:
                                              //             OutlineInputBorder(
                                              //           borderSide: BorderSide(
                                              //             color: FlutterFlowTheme
                                              //                     .of(context)
                                              //                 .error,
                                              //             width: 1,
                                              //           ),
                                              //           borderRadius:
                                              //               BorderRadius
                                              //                   .circular(20),
                                              //         ),
                                              //         filled: true,
                                              //         fillColor:
                                              //             FlutterFlowTheme.of(
                                              //                     context)
                                              //                 .alternate,
                                              //         prefixIcon: Icon(
                                              //           Icons.home_rounded,
                                              //           color:
                                              //               FlutterFlowTheme.of(
                                              //                       context)
                                              //                   .primary,
                                              //           size: 25,
                                              //         ),
                                              //       ),
                                              //       style: FlutterFlowTheme.of(
                                              //               context)
                                              //           .bodyMedium
                                              //           .override(
                                              //             font: GoogleFonts
                                              //                 .lexend(
                                              //               fontWeight:
                                              //                   FlutterFlowTheme.of(
                                              //                           context)
                                              //                       .bodyMedium
                                              //                       .fontWeight,
                                              //               fontStyle:
                                              //                   FlutterFlowTheme.of(
                                              //                           context)
                                              //                       .bodyMedium
                                              //                       .fontStyle,
                                              //             ),
                                              //             color: FlutterFlowTheme
                                              //                     .of(context)
                                              //                 .secondaryBackground,
                                              //             fontSize: 16,
                                              //             letterSpacing: 0.0,
                                              //             fontWeight:
                                              //                 FlutterFlowTheme.of(
                                              //                         context)
                                              //                     .bodyMedium
                                              //                     .fontWeight,
                                              //             fontStyle:
                                              //                 FlutterFlowTheme.of(
                                              //                         context)
                                              //                     .bodyMedium
                                              //                     .fontStyle,
                                              //           ),
                                              //       cursorColor:
                                              //           FlutterFlowTheme.of(
                                              //                   context)
                                              //               .primaryText,
                                              //       validator: _model
                                              //           .neighborhoodInputTextControllerValidator
                                              //           .asValidator(context),
                                              //     ),
                                              //   ),
                                              // ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 18, 0, 0),
                                                child: FFButtonWidget(
                                                   onPressed: () async {
                                                      if (currentUserUid == null) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text('Error: usuario no autenticado')),
                                                        );
                                                        return;
                                                      }
                                                      try {
                                                          final response = await Supabase.instance.client
                                                            .from('users')
                                                            .insert({
                                                              'uuid': currentUserUid,
                                                              'name': _model.nameInputTextController.text,
                                                              'email': currentUserEmail,
                                                              'usertype': 'Dueño',
                                                              'phone': _model.phoneInputTextController.text,
                                                              // 'neighborhood': _model.neighborhoodInputTextController.text,
                                                            });

                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text('¡Registro exitoso!')),
                                                          );
                                                          context.go('/');
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text('Error al registrar usuario: $e')),
                                                          );
                                                        }
                                                    },
                                                  text: 'Registrarse',
                                                  options: FFButtonOptions(
                                                    width: MediaQuery.sizeOf(
                                                            context)
                                                        .width,
                                                    height: MediaQuery.sizeOf(
                                                                context)
                                                            .height *
                                                        0.05,
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                16, 0, 16, 0),
                                                    iconPadding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 0, 0, 0),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .accent1,
                                                    textStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .titleSmall
                                                        .override(
                                                          font: GoogleFonts
                                                              .lexend(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                          ),
                                                          color: Colors.white,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontStyle,
                                                        ),
                                                    elevation: 0,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                              ),
                                            ],
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

import 'package:dalk/auth/supabase_auth/auth_util.dart';
import 'package:dalk/backend/supabase/database/database.dart';
import 'package:dalk/cards/owner_debt_card/owner_debt_card_widget.dart';

import '/components/go_back_container/go_back_container_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'owner_debt_model.dart';
export 'owner_debt_model.dart';

class OwnerDebtWidget extends StatefulWidget {
  const OwnerDebtWidget({super.key});

  static String routeName = 'ownerDebt';
  static String routePath = '/ownerDebt';

  @override
  State<OwnerDebtWidget> createState() => _OwnerDebtWidgetState();
}

class _OwnerDebtWidgetState extends State<OwnerDebtWidget> {
  late OwnerDebtModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OwnerDebtModel());

    _model.nameDogOwnerInputTextController ??=
        TextEditingController(text: 'Cargando...');
    _model.nameDogOwnerInputFocusNode ??= FocusNode();
    
    _fetchUserDebt();
  }

  // Método para obtener la deuda del usuario desde Supabase
  Future<void> _fetchUserDebt() async {
    try {
      
      final response = await Supabase.instance.client
          .from('users')
          .select('total_debt')
          .eq('uuid', currentUserUid)
          .single();
      
      final double totalDebt = (response['total_debt'] ?? 0.0).toDouble();
      
      setState(() {
        _model.nameDogOwnerInputTextController.text = '\$${totalDebt.toStringAsFixed(2)}';
      });
    } catch (e) {
      print('Error al obtener la deuda: $e');
      setState(() {
        _model.nameDogOwnerInputTextController.text = '\$0.00';
      });
    }
  }

  // Método para obtener los datos completos del walk desde el view
  Future<Map<String, dynamic>?> _fetchWalkData(int walkId) async {
    try {
      final response = await Supabase.instance.client
          .from('walks_with_names')
          .select()
          .eq('id', walkId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      print('Error al obtener datos del walk: $e');
      return null;
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
                      wrapWithModel(
                        model: _model.goBackContainerModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const GoBackContainerWidget(),
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
                                AutoSizeText(
                                  'Estado de cuenta',
                                  textAlign: TextAlign.center,
                                  minFontSize: 22,
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
                                            .primary,
                                        fontSize: 32,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                                // const Padding(
                                //   padding: EdgeInsetsDirectional.fromSTEB(
                                //       0, 20, 0, 0),
                                //   child: Icon(
                                //     Icons.pending,
                                //     color: Color(0xFFEAB521),
                                //     size: 100,
                                //   ),
                                // ),
                                // AutoSizeText(
                                //   '[paymentStatus]',
                                //   textAlign: TextAlign.center,
                                //   minFontSize: 22,
                                //   style: FlutterFlowTheme.of(context)
                                //       .bodyMedium
                                //       .override(
                                //         font: GoogleFonts.lexend(
                                //           fontWeight: FontWeight.bold,
                                //           fontStyle:
                                //               FlutterFlowTheme.of(context)
                                //                   .bodyMedium
                                //                   .fontStyle,
                                //         ),
                                //         color: FlutterFlowTheme.of(context)
                                //             .warning,
                                //         fontSize: 20,
                                //         letterSpacing: 0.0,
                                //         fontWeight: FontWeight.bold,
                                //         fontStyle: FlutterFlowTheme.of(context)
                                //             .bodyMedium
                                //             .fontStyle,
                                //       ),
                                // ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 20, 0, 0),
                                  child: Container(
                                    width: MediaQuery.sizeOf(context).width,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                      borderRadius: BorderRadius.circular(12),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Align(
                                          alignment:
                                              const AlignmentDirectional(-1, 0),
                                          child: Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    20, 22, 0, 0),
                                            child: Text(
                                              'Adeudos',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.lexend(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    fontSize: 15,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              const AlignmentDirectional(-1, 0),
                                          child: Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    20, 5, 20, 0),
                                            child: Text(
                                              'Al cancelar un paseo en curso genera una tarifa que se registra como saldo pendiente. Tendrás que cubrirlo desde tu cuenta.',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.lexend(
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
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
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
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  0, 7, 0, 20),
                                          child: Container(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                0.8,
                                            child: TextFormField(
                                              controller: _model
                                                  .nameDogOwnerInputTextController,
                                              focusNode: _model
                                                  .nameDogOwnerInputFocusNode,
                                              autofocus: false,
                                              readOnly: true,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                labelStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyLarge
                                                    .override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyLarge
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyLarge
                                                                .fontStyle,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      fontSize: 16,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .fontStyle,
                                                    ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .tertiary,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0x00000000),
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                filled: true,
                                                fillColor:
                                                    FlutterFlowTheme.of(context)
                                                        .tertiary,
                                                contentPadding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(10, 0, 0, 20),
                                                prefixIcon: Icon(
                                                  Icons.monetization_on,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  size: 25,
                                                ),
                                              ),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.lexend(
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
                                                    color: FlutterFlowTheme.of(
                                                            context)
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
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              validator: _model
                                                  .nameDogOwnerInputTextControllerValidator
                                                  .asValidator(context),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 20, 0, 0),
                                  child: Container(
                                    width: MediaQuery.sizeOf(context).width,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                      borderRadius: BorderRadius.circular(12),
                                      shape: BoxShape.rectangle,
                                    ),
                                  ),
                                ),
                                
                                // StreamBuilder para obtener las deudas pendientes
                                StreamBuilder<List<Map<String, dynamic>>>(
                                  stream: Supabase.instance.client
                                      .from('debts')
                                      .stream(primaryKey: ['id'])
                                      .order('created_at', ascending: false),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Center(
                                        child: Text('Error: ${snapshot.error}'),
                                      );
                                    }

                                    if (!snapshot.hasData) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }

                                    // 🔹 Filtramos manualmente después de obtener todos los datos
                                    final allDebts = snapshot.data!;
                                    final debts = allDebts.where((debt) =>
                                      debt['user_id'] == currentUserUid &&
                                      debt['status'] == 'Pendiente'
                                    ).toList();

                                    if (debts.isEmpty) {
                                      return const Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: Text(
                                          'No tienes adeudos pendientes',
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    }

                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Text(
                                            'Paseos con adeudos pendientes',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: FlutterFlowTheme.of(context).primary,
                                            ),
                                          ),
                                        ),
                                        ...debts.map((debt) => FutureBuilder<Map<String, dynamic>?>(
                                          future: _fetchWalkData(debt['walk_id'] as int),
                                          builder: (context, walkSnapshot) {
                                            if (walkSnapshot.connectionState == ConnectionState.waiting) {
                                              return const CircularProgressIndicator();
                                            }

                                            if (!walkSnapshot.hasData || walkSnapshot.data == null) {
                                              return const ListTile(
                                                title: Text('Información no disponible'),
                                              );
                                            }

                                            final fullWalkData = walkSnapshot.data!;

                                            return OwnerDebtCardWidget(
                                              id: fullWalkData['id'],
                                              status: fullWalkData['status'] ?? '',
                                              petName: fullWalkData['pet_name'] ?? '',
                                              usertype: 'Dueño',
                                              duration: (fullWalkData['walk_duration_minutes'] as int?)?.toString() ?? '',
                                              fee: (fullWalkData['fee'] as int?)?.toString() ?? '',
                                              dogWalker: fullWalkData['walker_name'] ?? '',
                                              photoUrl: fullWalkData['walker_photo_url'],
                                              walkerId: fullWalkData['walker_id'],
                                              dogId: fullWalkData['dog_id'],
                                              onPaymentCompleted: () {
                                                setState(() {});
                                                _fetchUserDebt(); 
                                              },
                                            );
                                          },
                                        )).toList(),
                                      ],
                                    );
                                  },
                                )

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
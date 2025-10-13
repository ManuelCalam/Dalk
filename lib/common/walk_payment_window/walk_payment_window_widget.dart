import 'package:dalk/backend/supabase/supabase.dart';
import 'package:dalk/components/pop_up_add_review/pop_up_add_review_widget.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'walk_payment_window_model.dart';
export 'walk_payment_window_model.dart';

class WalkPaymentWindowWidget extends StatefulWidget {
  const WalkPaymentWindowWidget({
    super.key,
    required this.walkId,
    required this.userType
    });

  final int walkId;
  final String userType;

  static String routeName = 'walkPaymentWindow';
  static String routePath = '/walkPaymentWindow';
  

  @override
  State<WalkPaymentWindowWidget> createState() =>
      _WalkPaymentWindowWidgetState();
}

class _WalkPaymentWindowWidgetState extends State<WalkPaymentWindowWidget> {
  late WalkPaymentWindowModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WalkPaymentWindowModel());

    _model.nameDogOwnerInputTextController1 ??=
        TextEditingController(text: '[duration]');
    _model.nameDogOwnerInputFocusNode1 ??= FocusNode();

    _model.nameDogOwnerInputTextController2 ??=
        TextEditingController(text: '[bill]');
    _model.nameDogOwnerInputFocusNode2 ??= FocusNode();

    _model.nameDogOwnerInputTextController3 ??=
        TextEditingController(text: '[dogName/walkerName]');
    _model.nameDogOwnerInputFocusNode3 ??= FocusNode();

    _model.nameDogOwnerInputTextController4 ??=
        TextEditingController(text: '[bill]');
    _model.nameDogOwnerInputFocusNode4 ??= FocusNode();
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
  void dispose() {
    _model.dispose();

    super.dispose();
  }


    // Posibles valores: 'not_reviewed', 'reviewed'
    String _reviewStatus = 'not_reviewed'; 
    
    // Posibles valores: 'pending', 'paid', 'cash_agreed'
    String _paymentStatus = 'pending'; 

    // Simulación de funciones de acción (solo imprimen para no romper el código)
    void _handleStripePayment() => print('Acción: Abrir Stripe Payment Sheet');
    void _handleCashPayment() => print('Acción: Registrar Pago en Efectivo y redirigir a Home');
    Future<void> _handleReviewAction(Map<String, dynamic> walkData) async {
      await showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: false,
        context: context,
        builder: (context) {
          return Padding(
            padding: MediaQuery.viewInsetsOf(context),
            child: PopUpAddReviewWidget(
              walkId: widget.walkId,
              userTypeName: widget.userType == 'Dueño' ? walkData['walker_name'] : walkData['pet_name'],
              reviewType: widget.userType == 'Dueño' ? 'Paseador' : 'Perro',
            ),
          );
        },
      );
      // Llamar a safeSetState *después* de que el modal se cierra y el await termina.
      safeSetState(() {}); 
    }
    void _goToHome() => print('Acción: Volver al Home');


    Widget _buildActionButton({
    required BuildContext context,
    required String text,
    required Color color,
    required VoidCallback onPressed,
    Widget? iconWidget, // Ahora acepta un Widget (Icon o FaIcon)
    bool isDisabled = false,
    Color? disabledColor,
  }) {
    final theme = FlutterFlowTheme.of(context);
    
    // Determina el color y la función del onPressed
    final resolvedColor = isDisabled ? disabledColor ?? theme.alternate : color;
    final resolvedOnPressed = isDisabled ? null : onPressed;

    final resolvedTextStyle = theme.titleSmall.override(
      font: GoogleFonts.lexend(
        fontWeight: FontWeight.w500, // Usamos un fontWeight específico para que se vea bien
        fontStyle: theme.titleSmall.fontStyle,
      ),
      color: isDisabled ? theme.secondaryText : Colors.white,
      fontSize: 17,
      letterSpacing: 0.0,
      fontWeight: FontWeight.w500,
      fontStyle: theme.titleSmall.fontStyle,
    );

    return Padding(
      // Padding vertical entre botones
      padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0), 
      child: FFButtonWidget(
        onPressed: resolvedOnPressed, 
        text: text,
        icon: iconWidget,
        options: FFButtonOptions(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height * 0.05,
          // Corregimos el padding interno para que no interfiera con el height
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0), 
          iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
          iconAlignment: IconAlignment.end,
          color: resolvedColor, 
          textStyle: resolvedTextStyle,
          elevation: 0,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  List<Widget> _getButtonsBasedOnStatus(
    BuildContext context,
    String? userType,
    Map<String, dynamic> walkData,

  ) {
    final theme = FlutterFlowTheme.of(context);
    final List<Widget> buttons = [];
    final isReviewed = _reviewStatus == 'reviewed';
    final isPaid = _paymentStatus == 'paid' || _paymentStatus == 'cash_agreed';
    
    // --- 1. BOTÓN DE RESEÑA (Común a ambos usuarios) ---
    final reviewButton = _buildActionButton(
      context: context,
      text: isReviewed ? 'Ver Reseña' : 'Agregar Reseña',
      onPressed: () => _handleReviewAction(walkData), // <-- CORREGIDO
      iconWidget: Icon(
        isReviewed ? Icons.rate_review_rounded : Icons.reviews_sharp,
        color: Colors.white,
        size: 23,
      ),
      // Si ya está revisado, cambia el color para indicar que es una acción secundaria
      isDisabled: false, 
      color: isReviewed ? theme.secondaryText : theme.accent1,
    );

    if (userType == 'Dueño') {
      // ------------------------------------
      // BOTONES PARA DUEÑO
      // ------------------------------------

      // 1. Pagar con Tarjeta (Principal)
      buttons.add(_buildActionButton(
        context: context,
        text: isPaid ? 'Pago Confirmado' : 'Pagar con Tarjeta',
        color: theme.primary,
        onPressed: _handleStripePayment,
        iconWidget: const Icon(Icons.credit_card, color: Colors.white, size: 23),
        // Se deshabilita si ya está pagado
        isDisabled: isPaid,
      ));

      // 2. Pagar con Efectivo (Secundario)
      buttons.add(_buildActionButton(
        context: context,
        text: isPaid ? 'Efectivo Acordado' : 'Pagar con Efectivo',
        color: theme.success,
        onPressed: _handleCashPayment,
        iconWidget: const FaIcon(FontAwesomeIcons.moneyBill1, color: Colors.white, size: 23),
        // Se deshabilita si ya está pagado o acordado
        isDisabled: isPaid,
      ));
      
      // 3. Botón de Reseña
      buttons.add(reviewButton);

    } else if (userType == 'Paseador') {
      // ------------------------------------
      // BOTONES PARA PASEADOR
      // ------------------------------------

      // 1. Volver al Home (Depende del pago)
      buttons.add(_buildActionButton(
        context: context,
        text: isPaid ? 'Volver al Home' : 'Esperando Pago...',
        color: theme.secondary,
        onPressed: _goToHome,
        iconWidget: const Icon(Icons.home_rounded, color: Colors.white, size: 23),
        // Está deshabilitado si el pago está pendiente
        isDisabled: !isPaid,
        disabledColor: theme.alternate,
      ));

      // 2. Botón de Reseña
      buttons.add(reviewButton);
    }

    return buttons;
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
        child: FutureBuilder<Map<String, dynamic>?>(
          future: fetchWalkInfoFromView(widget.walkId),
          builder: (context, snapshot) {
            // Mientras carga
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Si hay error
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            // Si no hay datos
            if (!snapshot.hasData) {
              return const Center(
                child: Text('No se encontraron datos'),
              );
            }

            // Datos cargados correctamente
            final walkData = snapshot.data!;

            return Column(
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
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 50, 0, 15),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.9,
                              decoration: const BoxDecoration(),
                              child: ListView(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                children: [
                                  AutoSizeText(
                                    'Resumen y Pago',
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
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0, 20, 0, 0),
                                    child: Icon(
                                      Icons.pending,
                                      color: FlutterFlowTheme.of(context).warning,
                                      size: 100,
                                    ),
                                  ),
                                  AutoSizeText(
                                    '[paymentStatus]',
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
                                              .warning,
                                          fontSize: 20,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
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
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    0, 20, 0, 0),
                                            child: Container(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.8,
                                              child: TextFormField(
                                                controller: _model
                                                    .nameDogOwnerInputTextController1..text = '${walkData['walk_duration_minutes']} minutos', 
                                                focusNode: _model
                                                    .nameDogOwnerInputFocusNode1,
                                                autofocus: false,
                                                readOnly: true,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  labelText: 'Duración del paseo',
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
                                                    Icons.timer,
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
                                                    .nameDogOwnerInputTextController1Validator
                                                    .asValidator(context),
                                              ),
                                            ),
                                          ),
                                          
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    0, 20, 0, 20),
                                            child: Container(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.8,
                                              child: TextFormField(
                                                controller: _model.nameDogOwnerInputTextController3
                                                  ..text = widget.userType == 'Dueño' 
                                                      ? (walkData['walker_name'] ?? '')
                                                      : (walkData['pet_name'] ?? ''),
                                                focusNode: _model
                                                    .nameDogOwnerInputFocusNode3,
                                                autofocus: false,
                                                readOnly: true,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  labelText: widget.userType == 'Dueño' ? 'Paseador' : 'Mascota',
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
                                                    Icons.pets_outlined,
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
                                                    .nameDogOwnerInputTextController3Validator
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
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    20, 20, 20, 0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Paseo',
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
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
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
                                                Text(
                                                  '\$${walkData['fee'].toString()}',
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
                                                        color: FlutterFlowTheme
                                                                .of(context)
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
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    0, 15, 0, 0),
                                            child: Container(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.8,
                                              height: 2,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .tertiary,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    0, 20, 0, 20),
                                            child: Container(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.8,
                                              child: TextFormField(
                                                controller: _model
                                                    .nameDogOwnerInputTextController4..text = '${walkData['fee']}'.toString(),
                                                focusNode: _model
                                                    .nameDogOwnerInputFocusNode4,
                                                autofocus: false,
                                                readOnly: true,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  labelText: 'Monto a pagar',
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
                                                    Icons.monetization_on_rounded,
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
                                                    .nameDogOwnerInputTextController4Validator
                                                    .asValidator(context),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  ..._getButtonsBasedOnStatus(context, widget.userType, walkData),
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
            );
          },
        ),
      ),
    ),
  );
}
}

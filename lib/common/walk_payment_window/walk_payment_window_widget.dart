import 'package:dalk/backend/supabase/supabase.dart';
import 'package:dalk/components/pop_up_add_review/pop_up_add_review_widget.dart';
import 'package:dalk/components/pop_up_review_details/pop_up_review_details_widget.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

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
    _checkReviewStatus();

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

  // Comprobar el status de una posible reseña
  Future<void> _checkReviewStatus() async {
    final review = await SupaFlow.client
        .from('reviews')
        .select('id')
        .eq('walk_id', widget.walkId)
        .limit(1)
        .maybeSingle();

    if (mounted) {
      safeSetState(() {
        _hasReview = review != null;
      });
    }
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


  bool _hasReview = false; 
  String _paymentStatus = 'pending'; 

  Future<void> _handleStripePayment(Map<String, dynamic> walkData) async {
    try {

      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('No hay usuario autenticado.');

      final customerRes = await supabase
          .from('users')
          .select('customer_stripe_id')
          .eq('uuid', userId)
          .maybeSingle();

      final customerStripeId = customerRes?['customer_stripe_id'];
      if (customerStripeId == null) {
        throw Exception('No se encontró el customer_stripe_id del usuario actual.');
      }


      final session = supabase.auth.currentSession;
      final response = await supabase.functions.invoke(
        'pay-walk-intent',
        body: {
          'walk_id': walkData['id'],
          'walker_id': walkData['walker_id'],
          'customer_stripe_id': customerStripeId,
          'fee': double.parse(walkData['fee'].toString()),
        },
        headers: {
          'Authorization': 'Bearer ${session!.accessToken}',
        },
      );

      if (response.data == null) {
        throw Exception('Error al crear el PaymentIntent.');
      }

      final clientSecret = response.data['client_secret'];
      final ephemeralKey = response.data['ephemeralKey'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Dalk',
          paymentIntentClientSecret: clientSecret,
          customerEphemeralKeySecret: ephemeralKey,
          customerId: customerStripeId,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pago completado con éxito.')),
      );

    } on StripeException catch (e) {
      print('Error de Stripe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pago cancelado o fallido.')),
      );
    } catch (e) {
      print('Error general: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar el pago: $e')),
      );
    }
  }

    
    
  Future<void> _handleCashPayment(Map<String, dynamic> walkData) async {
    try {
      final supabase = Supabase.instance.client;

      final walkerId = walkData['walker_id'];
      final walkId = walkData['id'];
      final fee = double.parse(walkData['fee'].toString());

      final updateWalk = await supabase
          .from('walks')
          .update({'payment_status': 'Pagado'})
          .eq('id', walkId)
          .select(); 

      if (updateWalk.isEmpty) {
        throw Exception('Error al actualizar el estado del paseo.');
      }

      final appFee = double.parse((fee * 0.05).toStringAsFixed(2));

      final walkerRes = await supabase
          .from('walker_payments')
          .select('debt')
          .eq('walker_uuid', walkerId)
          .maybeSingle();

      if (walkerRes == null) {
        throw Exception('No se encontró la información del paseador.');
      }

      final currentDebt = double.parse((walkerRes['debt'] ?? 0).toString());
      final newDebt = double.parse((currentDebt + appFee).toStringAsFixed(2));

      await supabase
          .from('walker_payments')
          .update({'debt': newDebt})
          .eq('walker_uuid', walkerId);

      // context.go('/owner/home');
      GoRouter.of(context).go('/owner/home');       

    } catch (e) {
      print('Error en pago en efectivo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo procesar el pago en efectivo: $e')),
      );
    }
  }

    
  Future<void> _handleReviewAction(Map<String, dynamic> walkData) async {
    // Determina el nombre del usuario/mascota para el pop-up
    final reviewedName = widget.userType == 'Dueño' ? walkData['walker_name'] : walkData['pet_name'];

    if (_hasReview) {
      // Acción: VER RESEÑA
      await showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: false,
        context: context,
        builder: (context) {
          return Padding(
            padding: MediaQuery.viewInsetsOf(context),
            child: PopUpReviewDetailsWidget(
              walkId: widget.walkId, 
              reviewedName: reviewedName,
            ),
          );
        },
      );
    } else {
      // Acción: AGREGAR RESEÑA
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
              userTypeName: reviewedName,
              reviewType: widget.userType == 'Dueño' ? 'Paseador' : 'Perro',
            ),
          );
        },
      );
    }
    
    await _checkReviewStatus(); 
  }

  void _goToHome() => print('Acción: Volver al Home');


  Widget _buildActionButton({
    required BuildContext context,
    required String text,
    required Color color,
    required VoidCallback onPressed,
    Widget? iconWidget,
    bool isDisabled = false,
    Color? disabledColor,
  }) {
    final theme = FlutterFlowTheme.of(context);
    
    final resolvedColor = isDisabled ? disabledColor ?? theme.alternate : color;
    final resolvedOnPressed = isDisabled ? null : onPressed;

    final resolvedTextStyle = theme.titleSmall.override(
      font: GoogleFonts.lexend(
        fontWeight: FontWeight.w500, 
        fontStyle: theme.titleSmall.fontStyle,
      ),
      color: isDisabled ? theme.secondaryText : Colors.white,
      fontSize: 17,
      letterSpacing: 0.0,
      fontWeight: FontWeight.w500,
      fontStyle: theme.titleSmall.fontStyle,
    );

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0), 
      child: FFButtonWidget(
        onPressed: resolvedOnPressed, 
        text: text,
        icon: iconWidget,
        options: FFButtonOptions(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height * 0.05,
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
    final hasReview = _hasReview; 
    final isPaid = _paymentStatus == 'paid' || _paymentStatus == 'cash_agreed';
    
    // --- 1. BOTÓN DE RESEÑA (Común a ambos usuarios) ---
    final reviewButton = _buildActionButton(
      context: context,
      text: hasReview ? 'Ver Reseña' : 'Agregar Reseña',
      
      onPressed: () => _handleReviewAction(walkData), 
      
      iconWidget: Icon(
        hasReview ? Icons.rate_review_rounded : Icons.reviews_sharp,
        color: Colors.white,
        size: 23,
      ),
      isDisabled: false, 
      color: hasReview ? theme.accent1 : theme.accent1,
    );

    if (userType == 'Dueño') {
      // ------------------------------------
      // BOTONES PARA DUEÑO
      // ------------------------------------

      // 1. Pagar con Tarjeta 
      if(walkData['payment_status'] != 'Pagado'){
        buttons.add(_buildActionButton(
          context: context,
          text: 'Pagar con Tarjeta',
          color: theme.primary,
          onPressed: () => _handleStripePayment(walkData), 
          iconWidget: const Icon(Icons.home, color: Colors.white, size: 23),
          isDisabled: isPaid,
        ));
      

        // 2. Pagar con Efectivo 
        buttons.add(_buildActionButton(
          context: context,
          text: 'Pagar con Efectivo',
          color: theme.success,
          onPressed: () => _handleCashPayment(walkData),
          iconWidget: const FaIcon(FontAwesomeIcons.moneyBill1, color: Colors.white, size: 23),
          isDisabled: isPaid,
        ));

      } else if (walkData['payment_status'] == 'Pagado') {
          buttons.add(_buildActionButton(
          context: context,
          text: "Menú principal",
          color: theme.primary,
          // onPressed: () => context.go('/owner/home'),
          onPressed: () => GoRouter.of(context).go('/owner/home'),
          iconWidget: const Icon(Icons.credit_card, color: Colors.white, size: 23),
          isDisabled: isPaid,
        ));
      }
      
      // 3. Botón de Reseña
      buttons.add(reviewButton);

    } else if (userType == 'Paseador') {
      // ------------------------------------
      // BOTONES PARA PASEADOR
      // ------------------------------------

      buttons.add(_buildActionButton(
        context: context,
        text: isPaid ? 'Volver al Home' : 'Esperando Pago...',
        color: theme.secondary,
        onPressed: _goToHome,
        iconWidget: const Icon(Icons.home_rounded, color: Colors.white, size: 23),
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
                    final Color statusColor;
                    final String displayStatus;
                    final IconData icon;

                    switch(walkData['payment_status'].toString()){
                      case 'Pendiente': 
                        statusColor = const Color(0xFFEAB521);
                        displayStatus = 'Pendiente';
                        icon = Icons.pending;

                      case 'Pagado': 
                        statusColor = FlutterFlowTheme.of(context).success;
                        displayStatus = 'Pagado';
                        icon = Icons.check_circle;

                      case 'Fallido': 
                        statusColor = FlutterFlowTheme.of(context).error;
                        displayStatus = 'Pagado';
                        icon = Icons.cancel_rounded;

                      default:
                        statusColor = const Color(0xFFEAB521);
                        displayStatus = 'Pendiente';
                        icon = Icons.pending;
                    }
                      


                    return Column(
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
                                      icon,
                                      color: statusColor,
                                      size: 100,
                                    ),
                                  ),
                                  AutoSizeText(
                                    walkData['payment_status'],
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
                                          color: statusColor,
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
                                                    .nameDogOwnerInputTextController4..text = '\$${walkData['fee'].toString()}',
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
                    );
                  },
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

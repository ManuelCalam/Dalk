import 'package:dalk/backend/supabase/database/database.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import '/components/go_back_container/go_back_container_widget.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'premium_plan_info_model.dart';
export 'premium_plan_info_model.dart';

class PremiumPlanInfoWidget extends StatefulWidget {
  const PremiumPlanInfoWidget({super.key});

  static String routeName = 'premiumPlanInfo';
  static String routePath = '/premiumPlanInfo';

  @override
  State<PremiumPlanInfoWidget> createState() => _PremiumPlanInfoWidgetState();
}

class _PremiumPlanInfoWidgetState extends State<PremiumPlanInfoWidget> {
  late PremiumPlanInfoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PremiumPlanInfoModel());

    _model.planValidity = true;
    _model.planValiditySwitchValue = _model.planValidity;
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<String> createCustomerIfNeeded() async {
    final jwt = Supabase.instance.client.auth.currentSession?.accessToken;
    final url = Uri.parse(
      "https://bsactypehgxluqyaymui.supabase.co/functions/v1/create-stripe-customer",
    );

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $jwt",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["customerId"];
    } else {
      throw Exception("Error creando customer: ${response.body}");
    }
  }



  Future<String> createSetupIntent() async {
    final url = Uri.parse(
      "https://bsactypehgxluqyaymui.supabase.co/functions/v1/create-setup-intent",
    );

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer ${Supabase.instance.client.auth.currentSession?.accessToken}",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final clientSecret = body["client_secret"];

      if (clientSecret == null) {
        throw Exception("El SetupIntent no devolvió client_secret. Respuesta: $body");
      }

      return clientSecret as String;
    } else {
      throw Exception("Error creando SetupIntent: ${response.body}");
    }
  }



  Future<void> openSetupPaymentSheet(BuildContext context) async {
    try {

      // 1. Crear SetupIntent en Stripe
      final clientSecret = await createSetupIntent();

      // 2. Inicializar PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: clientSecret,
          merchantDisplayName: "Dalk",
          style: ThemeMode.light,
        ),
      );

      // 3. Mostrar PaymentSheet
      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Método de pago guardado ✅")),
      );


    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        // Usuario canceló el PaymentSheet → no hacemos nada
        debugPrint("Usuario canceló el PaymentSheet");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.error.localizedMessage}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error inesperado: $e")),
      );
    }
  }


  Future<List<Map<String, dynamic>>> fetchPaymentMethods(String customerId) async {
    final url = Uri.parse(
      "https://bsactypehgxluqyaymui.supabase.co/functions/v1/list-payment-methods",
    );

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer ${Supabase.instance.client.auth.currentSession?.accessToken}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"customerId": customerId}),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Error listando métodos: ${response.body}");
    }
  }



  Future<String> generateEphemeralKey(String customerId) async {
    try {
      final jwt = Supabase.instance.client.auth.currentSession?.accessToken;
      
      final url = Uri.parse(
        "https://bsactypehgxluqyaymui.supabase.co/functions/v1/create-ephemeral-key"
      );

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $jwt",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"customerId": customerId}),
      );

      if (response.statusCode != 200) {
        print("Error generating ephemeral key: ${response.body}");
        throw Exception("Error generating ephemeral key: ${response.body}");
      }

      final data = jsonDecode(response.body);
      return data['secret']; 
      
    } catch (e) {
      print("Error en generateEphemeralKey: $e");
      throw Exception("Failed to generate ephemeral key: $e");
    }
  }
    

  Future<void> subscribePlan(BuildContext context, bool monthly, String customerId) async {
    try {
      final jwt = Supabase.instance.client.auth.currentSession?.accessToken;
      final plan = monthly ? "monthly" : "yearly";

      final url = Uri.parse(
        "https://bsactypehgxluqyaymui.supabase.co/functions/v1/create-subscription"
      );

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $jwt",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "plan": plan,
          "customerId": customerId
        }),
      );

      if (response.statusCode != 200) {
        print("Error : ${response.body}");
        throw Exception("Error creando suscripción: ${response.body}");
      }

      final data = jsonDecode(response.body);
      final clientSecret = data["clientSecret"];
      final subscriptionId = data["subscriptionId"];

      final reused = data["reused"] ?? false;

      if (reused) {
        print("Reusing existing incomplete subscription: $subscriptionId");
      }

      if (clientSecret == null) {
        throw Exception("No se recibió clientSecret de Stripe");
      }

      // 1. Generar Ephemeral Key
      final ephemeralKey = await generateEphemeralKey(customerId);

      // 2. Configurar PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          customerId: customerId, 
          customerEphemeralKeySecret: ephemeralKey,
          merchantDisplayName: "Dalk",
          style: ThemeMode.light,
        ),
      );

      // 3. Mostrar el PaymentSheet
      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Suscripción completada!")),
      );

    } catch (e) {
      print("Error en subscribePlan: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
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
              // Header con notificación - FUERA del Expanded
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
                child: wrapWithModel(
                  model: _model.notificationContainerModel,
                  updateCallback: () => setState(() {}),
                  child: NotificationContainerWidget(),
                ),
              ),
              
              // Contenido principal con Expanded
              Expanded(
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
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
                      // GoBackContainer - FUERA del ListView pero dentro del Expanded
                      wrapWithModel(
                        model: _model.goBackContainerModel,
                        updateCallback: () => setState(() {}),
                        child: GoBackContainerWidget(),
                      ),
                      
                      // Título - FUERA del ListView pero dentro del Expanded
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                        child: AutoSizeText(
                          'Membresía Premium',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          minFontSize: 12,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.lexend(
                              fontWeight: FontWeight.w800,
                            ),
                            color: FlutterFlowTheme.of(context).primary,
                            fontSize: 25,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      
                      // Contenedor con ListView - SOLUCIÓN AL ERROR
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 15),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.9,
                            decoration: BoxDecoration(),
                            child: ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: [
                                // Plan Gratuito
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                                  child: Container(
                                    width: MediaQuery.sizeOf(context).width,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context).alternate,
                                      borderRadius: BorderRadius.circular(15),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              AutoSizeText(
                                                'Gratuita',
                                                textAlign: TextAlign.start,
                                                maxLines: 1,
                                                minFontSize: 12,
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.lexend(fontWeight: FontWeight.bold),
                                                  color: FlutterFlowTheme.of(context).accent1,
                                                  fontSize: 23,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Flexible(
                                                child: Align(
                                                  alignment: AlignmentDirectional(1, 0),
                                                  child: Container(
                                                    width: MediaQuery.sizeOf(context).width * 0.21,
                                                    height: MediaQuery.sizeOf(context).height * 0.05,
                                                    constraints: BoxConstraints(
                                                      minWidth: 20,
                                                      minHeight: 5,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme.of(context).tertiary,
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    child: Align(
                                                      alignment: AlignmentDirectional(0, 0),
                                                      child: AutoSizeText(
                                                        'Activa',
                                                        textAlign: TextAlign.center,
                                                        maxLines: 1,
                                                        minFontSize: 8,
                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                          font: GoogleFonts.lexend(fontWeight: FontWeight.w600),
                                                          color: FlutterFlowTheme.of(context).primary,
                                                          fontSize: 16,
                                                          letterSpacing: 0.0,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(0, 6, 0, 0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 2, 0),
                                                  child: Icon(
                                                    Icons.check_sharp,
                                                    color: FlutterFlowTheme.of(context).primary,
                                                    size: 30,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    'Paseos de tiempo fijo',
                                                    textAlign: TextAlign.start,
                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      font: GoogleFonts.lexend(fontWeight: FontWeight.w500),
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      fontSize: 16,
                                                      letterSpacing: 0.0,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Align(
                                            alignment: AlignmentDirectional(-1, 0),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional.fromSTEB(32, 0, 0, 0),
                                              child: Text(
                                                'Paseos ideales para necesidades básicas',
                                                textAlign: TextAlign.start,
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.lexend(),
                                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                                  fontSize: 16,
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(0, 6, 0, 0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 2, 0),
                                                  child: Icon(
                                                    Icons.check_sharp,
                                                    color: FlutterFlowTheme.of(context).primary,
                                                    size: 30,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    'Localización del paseador',
                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      font: GoogleFonts.lexend(fontWeight: FontWeight.w500),
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      fontSize: 16,
                                                      letterSpacing: 0.0,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Align(
                                            alignment: AlignmentDirectional(-1, 0),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional.fromSTEB(32, 0, 0, 0),
                                              child: Text(
                                                'Localización en tiempo real de la posición del paseador',
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.lexend(),
                                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                                  fontSize: 16,
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Plan Premium
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                                  child: Container(
                                    width: MediaQuery.sizeOf(context).width,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context).tertiary,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context).alternate,
                                        width: 10,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Align(
                                                alignment: AlignmentDirectional(1, -1),
                                                child: Text(
                                                  'Premium',
                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                    font: GoogleFonts.lexend(fontWeight: FontWeight.bold),
                                                    color: FlutterFlowTheme.of(context).accent1,
                                                    fontSize: 23,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Align(
                                                  alignment: AlignmentDirectional(1, 0),
                                                  child: Container(
                                                    width: MediaQuery.sizeOf(context).width * 0.21,
                                                    height: MediaQuery.sizeOf(context).height * 0.05,
                                                    constraints: BoxConstraints(
                                                      minWidth: 20,
                                                      minHeight: 5,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme.of(context).alternate,
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    child: Align(
                                                      alignment: AlignmentDirectional(0, 0),
                                                      child: AutoSizeText(
                                                        _model.planValidity == true ? '\$149' : '\$1699',
                                                        maxLines: 1,
                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                          font: GoogleFonts.lexend(fontWeight: FontWeight.w600),
                                                          color: FlutterFlowTheme.of(context).primary,
                                                          fontSize: 16,
                                                          letterSpacing: 0.0,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(0, 6, 0, 0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 2, 0),
                                                  child: Icon(
                                                    Icons.check_sharp,
                                                    color: FlutterFlowTheme.of(context).primary,
                                                    size: 30,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    'Paseos personalizados',
                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      font: GoogleFonts.lexend(fontWeight: FontWeight.w500),
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      fontSize: 16,
                                                      letterSpacing: 0.0,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Align(
                                            alignment: AlignmentDirectional(-1, 0),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional.fromSTEB(32, 0, 0, 0),
                                              child: Text(
                                                'Paseos ideales para necesidades básicas',
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.lexend(),
                                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                                  fontSize: 16,
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(0, 6, 0, 0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 2, 0),
                                                  child: Icon(
                                                    Icons.check_sharp,
                                                    color: FlutterFlowTheme.of(context).primary,
                                                    size: 30,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    'Ofertas exclusivas',
                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      font: GoogleFonts.lexend(fontWeight: FontWeight.w500),
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      fontSize: 16,
                                                      letterSpacing: 0.0,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Align(
                                            alignment: AlignmentDirectional(-1, 0),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional.fromSTEB(32, 0, 0, 0),
                                              child: Text(
                                                'Paseos ideales para necesidades básicas',
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.lexend(),
                                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                                  fontSize: 16,
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(0, 6, 0, 0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Icon(
                                                  Icons.check_sharp,
                                                  color: FlutterFlowTheme.of(context).primary,
                                                  size: 30,
                                                ),
                                                Text(
                                                  'Sin anuncios',
                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                    font: GoogleFonts.lexend(fontWeight: FontWeight.w500),
                                                    color: FlutterFlowTheme.of(context).primary,
                                                    fontSize: 16,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Align(
                                            alignment: AlignmentDirectional(-1, 0),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional.fromSTEB(32, 0, 0, 0),
                                              child: Text(
                                                'Paseos ideales para necesidades básicas',
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.lexend(),
                                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                                  fontSize: 16,
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: AlignmentDirectional(1, 0),
                                            child: Container(
                                              width: MediaQuery.sizeOf(context).width * 0.18,
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(context).alternate,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Align(
                                                    alignment: AlignmentDirectional(0, -1),
                                                    child: Padding(
                                                      padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                                                      child: AutoSizeText(
                                                        _model.planValidity == true ? '1 mes' : '1 año',
                                                        textAlign: TextAlign.center,
                                                        maxLines: 2,
                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                          font: GoogleFonts.lexend(),
                                                          letterSpacing: 0.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment: AlignmentDirectional(0, -1),
                                                    child: Switch.adaptive(
                                                      value: _model.planValiditySwitchValue!,
                                                      onChanged: (newValue) async {
                                                        setState(() {
                                                          _model.planValiditySwitchValue = newValue;
                                                          _model.planValidity = newValue;
                                                        });
                                                      },
                                                      activeColor: Colors.white,
                                                      activeTrackColor: FlutterFlowTheme.of(context).primary,
                                                      inactiveTrackColor: FlutterFlowTheme.of(context).primary,
                                                      inactiveThumbColor: Colors.white,
                                                    ),
                                                  ),
                                                ].addToStart(SizedBox(height: 5)).addToEnd(SizedBox(height: 5)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                  child: FFButtonWidget(
                                  onPressed: () async {
                                    try {
                                      final customerId = await createCustomerIfNeeded();
                                      final methods = await fetchPaymentMethods(customerId);

                                      if (methods.isEmpty) {
                                        // No hay métodos, se abre el SetupIntent
                                        await openSetupPaymentSheet(context);

                                        // Tras agregar método, volver a verificar
                                        final newMethods = await fetchPaymentMethods(customerId);
                                        if (newMethods.isNotEmpty) {
                                          await subscribePlan(context, _model.planValidity, customerId);
                                        }
                                      } else {
                                        // Ya hay métodos, abrir PaymentIntentl
                                        await subscribePlan(context, _model.planValidity, customerId);
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Error: $e")),
                                      );
                                    }
                                  },
                                    text: 'Suscribirme',
                                    options: FFButtonOptions(
                                      width: MediaQuery.sizeOf(context).width,
                                      height: MediaQuery.sizeOf(context).height * 0.05,
                                      padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                                      iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                      color: FlutterFlowTheme.of(context).accent1,
                                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                        font: GoogleFonts.lexend(),
                                        color: Colors.white,
                                        letterSpacing: 0.0,
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
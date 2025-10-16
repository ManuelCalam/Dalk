import 'package:dalk/backend/supabase/database/database.dart';
import 'package:dalk/cards/payment_card/payment_card_widget.dart';
import 'package:dalk/components/pop_up_confirm_dialog/pop_up_confirm_dialog_widget.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import '/components/go_back_container/go_back_container_widget.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'payment_methods_model.dart';
export 'payment_methods_model.dart';

class PaymentMethodsWidget extends StatefulWidget {
  const PaymentMethodsWidget({super.key});

  static String routeName = 'paymentMethods';
  static String routePath = '/paymentMethods';

  @override
  State<PaymentMethodsWidget> createState() => _PaymentMethodsWidgetState();
}

class _PaymentMethodsWidgetState extends State<PaymentMethodsWidget> {
  late PaymentMethodsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Trigger para refrecar la lista de tarjetas
  int refreshTrigger = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaymentMethodsModel());
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
      // 1. Asegurarnos de que existe un customer
      final customerId = await createCustomerIfNeeded();

      // 2. Crear SetupIntent en Stripe
      final clientSecret = await createSetupIntent();

      // 3. Inicializar PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: clientSecret,
          merchantDisplayName: "Dalk",
          style: ThemeMode.light,
        ),
      );

      // 4. Mostrar PaymentSheet
      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Método de pago guardado ✅")),
      );

    setState(() {
        refreshTrigger++;
      });

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
      // Otros errores inesperados
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

  Future<void> detachPaymentMethod(String paymentMethodId) async {
    final url = Uri.parse(
      "https://bsactypehgxluqyaymui.supabase.co/functions/v1/detach-payment-method",
    );

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer ${Supabase.instance.client.auth.currentSession?.accessToken}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"paymentMethodId": paymentMethodId}),
    );

    if (response.statusCode != 200) {
      throw Exception("Error eliminando método: ${response.body}");
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
                                  'Métodos de pago',
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

                                // FutureBuilder para tarjetas
                                FutureBuilder<String>(
                                  future: createCustomerIfNeeded().then((customerId) => customerId),
                                  key: ValueKey(refreshTrigger),
                                  builder: (context, customerSnap) {
                                    if (customerSnap.connectionState == ConnectionState.waiting) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 20),
                                        child: Center(child: CircularProgressIndicator()),
                                      );
                                    }

                                    if (customerSnap.hasError) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        child: Text("Error: ${customerSnap.error}"),
                                      );
                                    }

                                    final customerId = customerSnap.data!;
                                    return FutureBuilder<List<Map<String, dynamic>>>(
                                      future: fetchPaymentMethods(customerId),
                                      builder: (context, snapshot) {
                                        return Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 20),
                                          child: Builder(
                                            builder: (_) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return const Center(child: CircularProgressIndicator());
                                              }
                                              if (snapshot.hasError) {
                                                return Text("Error: ${snapshot.error}");
                                              }

                                              final methods = snapshot.data ?? [];
                                              if (methods.isEmpty) {
                                                return Text(
                                                  "No tienes tarjetas registradas",
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(context).bodyMedium,
                                                );
                                              }

                                              return Column(
                                                children: methods.map((pm) {
                                                  return PaymentCardWidget(
                                                    funding: pm["funding"],
                                                    brand: pm["brand"],
                                                    last4: pm["last4"],
                                                    expMonth: pm["exp_month"],
                                                    expYear: pm["exp_year"],
                                                    onDelete: () async {
                                                      try {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return Dialog(
                                                              backgroundColor: Colors.transparent,
                                                              child: PopUpConfirmDialogWidget(
                                                                title: "Eliminar Tarjeta",
                                                                message: "¿Estás seguro que quieres eliminar la tarjeta?",
                                                                confirmText: "Eliminar Tarjeta",
                                                                cancelText: "Cancelar",
                                                                confirmColor: FlutterFlowTheme.of(context).error,
                                                                cancelColor: FlutterFlowTheme.of(context).primary,
                                                                icon: Icons.delete_forever_rounded,
                                                                iconColor: FlutterFlowTheme.of(context).error,
                                                                onConfirm: () async {
                                                                  await detachPaymentMethod(pm["id"]);
                                                                  setState(() {});
                                                                  Navigator.pop(context); 
                                                                },
                                                                onCancel: () {
                                                                  Navigator.pop(context);
                                                                },
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      } catch (e) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text("Error: $e")),
                                                        );
                                                      }
                                                    },
                                                  );
                                                }).toList(),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),


                                GestureDetector(
                                  onTap: () async {
                                    await openSetupPaymentSheet(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                    child: Container(
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).alternate,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(17),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Align(
                                              alignment: const AlignmentDirectional(0, 0),
                                              child: Icon(
                                                Icons.add_card_rounded,
                                                color: FlutterFlowTheme.of(context).primary,
                                                size: 35,
                                              ),
                                            ),
                                            AutoSizeText(
                                              'Agregar tarjeta',
                                              textAlign: TextAlign.center,
                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                font: GoogleFonts.lexend(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(context).primary,
                                                fontSize: 19,
                                                letterSpacing: 0.0,
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

import 'dart:convert';
import 'package:dalk/backend/supabase/database/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
// Asegúrate de tener el paquete 'http' en tu pubspec.yaml
import 'package:http/http.dart' as http; 

// URL de tu Edge Function (Asegúrate de reemplazar 'bsactypehgxluqyaymui' con tu propio ID de proyecto Supabase)
const String SUPABASE_EDGE_FUNCTION_URL = 'https://bsactypehgxluqyaymui.supabase.co/functions/v1/buy-tracker-intent';

/// Maneja la llamada a la Edge Function, la inicialización del Payment Sheet
/// y el proceso final de pago.
Future<void> handlePaymentFlow(
 BuildContext context,
 int itemCount, 
 double shippingPrice,
 String? customerStripeId,
 String internalOrderId, 
) async {
  final jwt = Supabase.instance.client.auth.currentSession?.accessToken;
  // Mostrar un indicador de carga mientras se llama a la función de Stripe

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Preparando pago...')),
  );

  try { 

    final response = await http.post(
      Uri.parse(SUPABASE_EDGE_FUNCTION_URL),
      headers: <String, String>{
        "Content-Type": "application/json",
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode(<String, dynamic>{
        'itemCount': itemCount,
        'shippingPrice': shippingPrice,
        'customer_stripe_id': customerStripeId,
        'internalOrderId': internalOrderId,
      }),
    );

    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Error al crear Payment Intent: ${errorBody['error']}');
    }

    // 2. EXTRAER LOS SECRETOS
    final responseBody = jsonDecode(response.body);
    final clientSecret = responseBody['client_secret'];
    final ephemeralKey = responseBody['ephemeralKey'];
    
    if (clientSecret == null) {
      throw Exception('Falta el client_secret en la respuesta de Stripe.');
    }

    final hasCustomer = customerStripeId != null && ephemeralKey != null;
    
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret, 
        customerEphemeralKeySecret: hasCustomer ? ephemeralKey : null,
        customerId: hasCustomer ? customerStripeId : null,
        merchantDisplayName: 'Dalk',
        allowsDelayedPaymentMethods: true,
        style: ThemeMode.light,
      ),
    );

    await Stripe.instance.presentPaymentSheet();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pago exitoso! Procesando tu orden.'),
      ),
    );
    
    // context.go('/orderConfirmation');
    
  } on StripeException catch (e) {
    // Manejar errores de Stripe (ej: pago cancelado, tarjeta rechazada)
    String message;
    if (e.error.code == FailureCode.Canceled) {
      message = 'Pago cancelado.';
    } else {
      message = 'Error de pago: ${e.error.message}';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
    print('Stripe Error: ${e.error.message}');
    
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error inesperado: $e. Intenta de nuevo.'),
      ),
    );
    print('General Error: $e');
  }
}

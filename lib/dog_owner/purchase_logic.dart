import 'dart:convert';
import 'package:dalk/backend/supabase/database/database.dart';
import 'package:http/http.dart' as http; 
import 'package:dalk/dog_owner/stripe_checkout_screen/stripe_checkout_screen.dart'; 
import 'package:flutter/material.dart';

const String SUPABASE_EDGE_FUNCTION_URL = 'https://bsactypehgxluqyaymui.supabase.co/functions/v1/stripe_checkout_session';

Future<void> handlePaymentFlow(
  BuildContext context,
  int itemCount, 
  double shippingPrice,
  String? customerStripeId, 
) async {
  
  print('El customerStripeId es: $customerStripeId');

  const String baseUrl = 'https://dalk.com/payment/';
  const String successUrl = '${baseUrl}success';
  const String cancelUrl = '${baseUrl}cancel';
  final jwt = Supabase.instance.client.auth.currentSession?.accessToken;

  String stripeCheckoutUrl = '';
  
  final Map<String, dynamic> requestBody = {
    'itemCount': itemCount,
    'shippingPrice': shippingPrice,
    'customer_stripe_id': customerStripeId, // Envía el ID, que puede ser null
  };

  try {
    final response = await http.post(
      Uri.parse(SUPABASE_EDGE_FUNCTION_URL),
      headers: <String, String>{
        "Authorization": "Bearer $jwt",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      stripeCheckoutUrl = jsonResponse['checkoutUrl'] as String;
      print('URL de Checkout recibida con éxito: $stripeCheckoutUrl');
    } else {
      final errorResponse = jsonDecode(response.body);
      print('ERROR ${response.statusCode}: Fallo al generar la sesión de Stripe.');
      print('Mensaje del servidor: ${errorResponse['error'] ?? response.reasonPhrase}');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en el pago: ${errorResponse['error'] ?? 'No se pudo generar el enlace.'}')),
      );
      return; // Detener el flujo
    }

  } catch (e) {
    print('ERROR DE CONEXIÓN/SERVIDOR: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error de conexión con el servidor de pagos.')),
    );
    return; // Detener el flujo si falla la conexión
  }


  
  if (stripeCheckoutUrl.isEmpty) {
     print('ERROR: URL de Checkout vacía después de la llamada al backend.');
     return;
  }

  final result = await Navigator.of(context).push<bool?>(
    MaterialPageRoute(
      builder: (context) => StripeCheckoutScreen(
        checkoutUrl: stripeCheckoutUrl,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
      ),
    ),
  );


  // MANEJO DEL RESULTADO
  if (result == true) {
    print('-------------------------------------------');
    print('PAGO EXITOSO: El WebView fue cerrado por éxito.');
    print('Aquí deberías: Navigator.pushReplacement(OrderConfirmationScreen())');
    print('-------------------------------------------');
    
  } else if (result == false) {
    print('-------------------------------------------');
    print('PAGO CANCELADO: El WebView fue cerrado por el cliente.');
    print('Aquí deberías: Mostrar un Snackbar de "Cancelado".');
    print('-------------------------------------------');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pago cancelado por el usuario.')),
    );
    
  } else {
    print('-------------------------------------------');
    print('CIERRE MANUAL: El WebView fue cerrado manualmente (resultado nulo).');
    print('Aquí deberías: Mostrar un Snackbar de "Proceso no finalizado".');
    print('-------------------------------------------');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('La ventana de pago fue cerrada sin completar el proceso.')),
    );
  }
}

import '/flutter_flow/flutter_flow_theme.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

export 'payment_card_model.dart';

class PaymentCardWidget extends StatelessWidget {
  final String funding;
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;
  final VoidCallback? onDelete;

  const PaymentCardWidget({
    super.key,
    required this.funding,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    this.onDelete,
  });

  // 🔹 Helper: asignar icono y gradient por brand
  (IconData, List<Color>) _getBrandStyle() {
    switch (brand.toLowerCase()) {
      case "visa":
        return (FontAwesomeIcons.ccVisa, [Color(0xFF1A1F71), Color(0xFF3B79C9)]);
      case "mastercard":
        return (FontAwesomeIcons.ccMastercard, [Color(0xFFF79E1B), Color(0xFFEB001B)]);
      case "amex":
      case "american express":
        return (FontAwesomeIcons.ccAmex, [Color(0xFF2E77BC), Color(0xFF1F5F99)]);
      case "discover":
        return (FontAwesomeIcons.ccDiscover, [Color(0xFFFF6000), Color(0xFFFFA733)]);
      default:
        return (FontAwesomeIcons.creditCard, [Color(0xFF333333), Color(0xFF777777)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, gradient) = _getBrandStyle();

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        height: 200,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x33000000),
              offset: Offset(0, 2),
            )
          ],
          gradient: LinearGradient(
            colors: gradient,
            stops: [0, 1],
            begin: AlignmentDirectional(1, 0.98),
            end: AlignmentDirectional(-1, -0.98),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                children: [
                  Text(
                    funding,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexend(
                            fontWeight: FontWeight.bold,
                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).info,
                        ),
                  ),
                  Spacer(),
                  FaIcon(icon, color: FlutterFlowTheme.of(context).info, size: 50),
                ],
              ),
              SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional(-1, 0),
                child: Text(
                  "•••• $last4",
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.lexend(),
                        color: FlutterFlowTheme.of(context).info,
                      ),
                ),
              ),
              Spacer(),
              Row(
                children: [
                  GestureDetector(
                    onTap: onDelete,
                    child: Text(
                      "Eliminar",
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.lexend(
                              fontWeight: FontWeight.bold,
                            ),
                            color: FlutterFlowTheme.of(context).info,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    "$expMonth/$expYear",
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexend(),
                          color: FlutterFlowTheme.of(context).info,
                        ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

import '/components/pop_up_dog_walker_profile/pop_up_dog_walker_profile_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'find_dog_walker_card_model.dart';
export 'find_dog_walker_card_model.dart';
import '/backend/supabase/supabase.dart';


class FindDogWalkerCardWidget extends StatelessWidget {
  final String nombre;
  final String precio;
  final String calificacion;
  final String fotoUrl;
  final int selectedAddress;
  final int selectedPet;
  final DateTime scheduledDate;
  final DateTime scheduledTime;
  final int duration;
  final String walkerId;

  const FindDogWalkerCardWidget({
    required this.nombre,
    required this.precio,
    required this.calificacion,
    required this.fotoUrl,
    required this.selectedAddress,
    required this.selectedPet,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.duration,
    required this.walkerId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(-1, -1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height * 0.12,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).alternate,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              /// FOTO
              Container(
                width: MediaQuery.sizeOf(context).width * 0.2,
                height: MediaQuery.sizeOf(context).height,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      fotoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person, size: 80),
                    ),
                  ),
                ),
              ),

              /// NOMBRE + PRECIO
              Container(
                width: MediaQuery.sizeOf(context).width * 0.3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Nombre
                    InkWell(
                      onTap: () async {
                        await showModalBottomSheet(
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          enableDrag: false,
                          context: context,
                          builder: (context) {
                            return Padding(
                              padding: MediaQuery.viewInsetsOf(context),
                              child: PopUpDogWalkerProfileWidget(),
                            );
                          },
                        );
                      },
                      child: AutoSizeText(
                        nombre,
                        maxLines: 2,
                        minFontSize: 12,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lexend(
                                fontWeight: FontWeight.w600,
                              ),
                              color: FlutterFlowTheme.of(context).primary,
                              fontSize: 18,
                              decoration: TextDecoration.underline,
                            ),
                      ),
                    ),

                    /// Precio
                    const SizedBox(height: 4),
                    AutoSizeText(
                      '\$$precio MXN',
                      maxLines: 1,
                      minFontSize: 11,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.lexend(
                              fontWeight: FontWeight.w500,
                            ),
                            color:
                                FlutterFlowTheme.of(context).secondaryBackground,
                            fontSize: 16,
                          ),
                    ),
                  ],
                ),
              ),

              /// CALIFICACIÓN (ESTRELLA + VALOR)
              Container(
                width: MediaQuery.sizeOf(context).width * 0.17,
                height: 100,
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFE2B433), size: 24),
                    const SizedBox(width: 4),
                    AutoSizeText(
                      calificacion,
                      maxLines: 1,
                      minFontSize: 10,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.lexend(
                              fontWeight: FontWeight.w500,
                            ),
                            color:
                                FlutterFlowTheme.of(context).secondaryBackground,
                            fontSize: 20,
                          ),
                    ),
                  ],
                ),
              ),

              /// BOTÓN "SOLICITAR"
              Container(
                width: MediaQuery.sizeOf(context).width * 0.23,
                height: MediaQuery.sizeOf(context).height,
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: FFButtonWidget(
                      onPressed: () async {
                        final startDateTime = DateTime(
                        scheduledDate.year,
                        scheduledDate.month,
                        scheduledDate.day,
                        scheduledTime.hour,
                        scheduledTime.minute,
                      );

                      final endDateTime = startDateTime.add(Duration(minutes: duration));

                      final result = await Supabase.instance.client.from('walks').insert({
                        'dog_id': selectedPet,
                        'walker_id': walkerId,
                        'owner_id': Supabase.instance.client.auth.currentUser?.id, // o pásalo como prop si no estás logueado
                        'address_id': selectedAddress,
                        'startTime': '2025-07-17 10:30:00',
                        'endTime': '11:00:00',
                        'status': 'pendiente', // o el que uses por defecto
                        'notes': '', // si tienes campo de notas
                      });

                        // Opcional: feedback al usuario
                        if (result != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('¡Paseo agendado con éxito!')),
                          );
                          Navigator.pop(context);
                        }
                      },
                      text: 'Solicitar',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: MediaQuery.sizeOf(context).height * 0.05,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        color: FlutterFlowTheme.of(context).accent1,
                        textStyle: FlutterFlowTheme.of(context)
                            .titleSmall
                            .override(
                              font: GoogleFonts.lexend(),
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                        elevation: 0,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
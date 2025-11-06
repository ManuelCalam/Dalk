import 'package:dalk/auth/supabase_auth/auth_util.dart';
import 'package:dalk/backend/supabase/supabase.dart';
import 'package:dalk/cards/tracker_card/tracker_card_widget.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pop_up_current_walk_options_model.dart';
export 'pop_up_current_walk_options_model.dart';

class PopUpCurrentWalkOptionsWidget extends StatefulWidget {
  const PopUpCurrentWalkOptionsWidget({
        required this.walkId,
        super.key,
    });

  final int walkId;
  @override
  State<PopUpCurrentWalkOptionsWidget> createState() =>
      _PopUpCurrentWalkOptionsWidgetState();
}

class _PopUpCurrentWalkOptionsWidgetState
    extends State<PopUpCurrentWalkOptionsWidget> {
  late PopUpCurrentWalkOptionsModel _model;

  // Lista para almacenar los IDs seleccionados
  List<String> selectedTrackers = [];
  // Variable para almacenar los trackers una vez cargados
  List<Map<String, dynamic>>? _trackers;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PopUpCurrentWalkOptionsModel());
    // Cargar los trackers al inicializar
    _loadTrackers();
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  // Método para cargar los rastreadores
  Future<void> _loadTrackers() async {
    try {
      final response = await Supabase.instance.client 
          .from('orders')
          .select()
          .eq('user_id', currentUserUid)
          .eq('status', 'Pagada');

      if (mounted) {
        setState(() {
          _trackers = (response as List<dynamic>).cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      print('Error fetching trackers: $e');
      if (mounted) {
        setState(() {
          _trackers = [];
        });
      }
    }
  }

  // Método para guardar los rastreadores seleccionados
  Future<void> _saveSelectedTrackers() async {
    if (selectedTrackers.isEmpty) return;
    
    try {
      final response = await Supabase.instance.client
          .from('users')
          .update({'pet_trackers': selectedTrackers})
          .eq('uuid', currentUserUid);
      if (response.error != null) throw response.error!;
      
      print('Rastreadores guardados exitosamente');
    } catch (e) {
      print('Error saving trackers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0, 0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.85,
        height: MediaQuery.sizeOf(context).height * 0.5,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).tertiary,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
        ),
        child: Column( 
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(15, 20, 10, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Align(
                      alignment: const AlignmentDirectional(1, 0),
                      child: FlutterFlowIconButton(
                        borderRadius: 8,
                        icon: Icon(
                          Icons.cancel,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 30,
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Contenido principal
            Expanded(
              child: Container(
                width: MediaQuery.sizeOf(context).width * 0.65,
                child: Form(
                  key: _model.formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start, 
                    children: [
                      const SizedBox(height: 10), 
                      AutoSizeText(
                        'Paseo iniciado',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                              font: GoogleFonts.lexend(
                                fontWeight: FontWeight.w600,
                              ),
                              color: FlutterFlowTheme.of(context).primary,
                              fontSize: 20,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0), 
                        child: Text(
                          'Agrega rastreadores a tu paseo (opcional)',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.lexend(
                                  fontWeight: FontWeight.w500,
                                ),
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      const SizedBox(height: 10), // ← Reducí espacio
                      // Contenedor para los rastreadores
                      Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildTrackersList(),
                      ),
                      // Botón
                      Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: MediaQuery.sizeOf(context).height * 0.07,
                        decoration: const BoxDecoration(),
                        child: Padding( 
                          padding: const EdgeInsets.only(top: 20), 
                          child: FFButtonWidget(
                            onPressed: () async {
                            final currentUserId = SupaFlow.client.auth.currentUser?.id;
                            try {

                              await SupaFlow.client
                                .from('users') 
                                .update({'current_walk_id': widget.walkId}) 
                                .eq('uuid', currentUserId!) 
                                .maybeSingle();
                            } catch (e) {
                              print("Error al actualizar current_walk_id en Supabase: $e");
                            }

                              await _saveSelectedTrackers();
                              context.pop();
                              if (context.mounted) {
                                GoRouter.of(context).go('/owner/currentWalk');
                              }                                  
                            },
                            text: 'Abrir Mapa',
                            icon: const FaIcon(
                              FontAwesomeIcons.mapLocation,
                              size: 20,
                            ),
                            options: FFButtonOptions(
                              width: MediaQuery.sizeOf(context).width * 0.6,
                              height: MediaQuery.sizeOf(context).height * 0.045,
                              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                              iconAlignment: IconAlignment.end,
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                              color: FlutterFlowTheme.of(context).accent1,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.lexend(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                              elevation: 0,
                              borderRadius: BorderRadius.circular(8),
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
    );
  }

  // Widget separado para construir la lista de rastreadores
  Widget _buildTrackersList() {
    // Si aún no se han cargado los trackers
    if (_trackers == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Si hay error o no hay trackers
    if (_trackers!.isEmpty) {
      return Center(
        child: Text(
          'No hay rastreadores para mascota registrados.',
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context)
              .bodyMedium
              .override(
                font: GoogleFonts.lexend(
                  fontWeight: FontWeight.w500,
                ),
                color: FlutterFlowTheme.of(context).secondaryBackground,
              ),
        ),
      );
    }

    // Lista de rastreadores cargados
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: _trackers!.length,
      itemBuilder: (context, index) {
        final tracker = _trackers![index];
        final trackerId = tracker['tracker_id']?.toString() ?? '';
        final isSelected = selectedTrackers.contains(trackerId);
        
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedTrackers.remove(trackerId);
                } else {
                  selectedTrackers.add(trackerId);
                }
              });
            },
            child: TrackerCardWidget(
              alias: tracker['tracker_alias']?.toString() ?? 'Rastreador',
              id: trackerId,
              selected: isSelected,
            ),
          ),
        );
      },
    );
  }
}
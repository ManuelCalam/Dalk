import 'package:dalk/backend/supabase/supabase.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pet_list_card_model.dart';
export 'pet_list_card_model.dart';

class PetListCardWidget extends StatefulWidget {
  final Map<String, dynamic> petData; // info de la mascota
  final VoidCallback? onPetDeleted;
  final VoidCallback? onPetUpdated;

  const PetListCardWidget({
    super.key,
    required this.petData, // requerido
    this.onPetDeleted,
    this.onPetUpdated,       
  });

  @override
  State<PetListCardWidget> createState() => _PetListCardWidgetState();
}

class _PetListCardWidgetState extends State<PetListCardWidget> {
  late PetListCardModel _model;

  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pets = [];
  bool loading = true;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('pets')
        .select()
        .eq('uuid', user.id); // todas las mascotas de este usuario

    setState(() {
      pets = List<Map<String, dynamic>>.from(response);
      loading = false;
    });
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.petData;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height * 0.12,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).alternate,
          boxShadow: const [
            BoxShadow(
              blurRadius: 1,
              color: Color(0x33000000),
              offset: Offset(
                0,
                1,
              ),
            )
          ],
          borderRadius: BorderRadius.circular(10),
          shape: BoxShape.rectangle,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(15, 15, 10, 15),
              child: Container(
                width: MediaQuery.sizeOf(context).width * 0.18,
                height: MediaQuery.sizeOf(context).height,
                child: ClipOval(
                  child: Image.network(
                    pet['photo_url'] ?? 'https://bsactypehgxluqyaymui.supabase.co/storage/v1/object/public/profile_pics/dog.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: MediaQuery.sizeOf(context).height,
                decoration: const BoxDecoration(),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        pet['name'] ?? 'Sin nombre',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        minFontSize: 12,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lexend(
                                fontWeight: FontWeight.bold,
                              ),
                              color: FlutterFlowTheme.of(context).primary,
                              fontSize: 19,
                          ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(-1, -1),
                        child: AutoSizeText(
                          pet['gender'] ?? '',
                          textAlign: TextAlign.start,
                          minFontSize: 10,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                          ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(-1, -1),
                        child: AutoSizeText(
                          pet['bree'] ?? '',
                          maxLines: 1,
                          minFontSize: 10,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(0, 0),
              child: Container(
                height: MediaQuery.sizeOf(context).height,
                decoration: const BoxDecoration(),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: const AlignmentDirectional(0, 0),
                        child: FlutterFlowIconButton(
                          borderRadius: 8,
                          icon: Icon(
                            Icons.delete_forever,
                            color: FlutterFlowTheme.of(context).error,
                            size: 30,
                          ),
                         onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Eliminar mascota'),
                                content: const Text('¿Estás segura de que deseas eliminar esta mascota?'),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancelar'),
                                    onPressed: () => Navigator.pop(ctx, false),
                                  ),
                                  TextButton(
                                    child: const Text('Eliminar'),
                                    onPressed: () => Navigator.pop(ctx, true),
                                  ),
                                ],
                              ),
                            );

                            if (confirm != true) return;

                            final user = supabase.auth.currentUser;
                            final petId = widget.petData['id'];

                            try {
                              final deleted = await supabase
                                  .from('pets')
                                  .delete()
                                  .eq('id', petId)
                                  .eq('uuid', user?.id as Object)
                                  .select();

                              if (deleted.isEmpty) {
                                return;
                              }

                              widget.onPetDeleted?.call();  
                            } catch (e) {
                              widget.onPetDeleted?.call();  
                            }
                          },
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0, 0),
                        child: FlutterFlowIconButton(
                          borderRadius: 8,
                          icon: Icon(
                            FontAwesomeIcons.solidPenToSquare,
                            color: FlutterFlowTheme.of(context).primary,
                            size: 30,
                          ),
                          onPressed: () async {
                            final shouldReload = await context.push(
                              '/owner/updatePet',
                              extra: <String, dynamic>{
                                'petData': widget.petData,
                              },
                            );

                            if (shouldReload == true) {
                              widget.onPetUpdated?.call();
                            }
                          },

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
}


import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'pet_card_model.dart';
export 'pet_card_model.dart';

class PetCardWidget extends StatefulWidget {
  const PetCardWidget({
    super.key,
    required this.petName,
    required this.id,
    bool? selected,
  }) : this.selected = selected ?? false;

  final String? petName;
  final int? id;
  final bool selected;

  @override
  State<PetCardWidget> createState() => _PetCardWidgetState();
}

class _PetCardWidgetState extends State<PetCardWidget> {
  late PetCardModel _model;
  String? _photoUrl;
  bool _isLoading = true;
  final supabase = Supabase.instance.client;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PetCardModel());
    _fetchPetPhoto();
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  Future<void> _fetchPetPhoto() async {
    try {
      if (widget.id == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await supabase
          .from('pets')
          .select('photo_url')
          .eq('id', widget.id!)
          .maybeSingle();

      if (response != null && response['photo_url'] != null) {
        setState(() {
          _photoUrl = response['photo_url'] as String;
        });
      }
    } catch (e) {
      print('Error al obtener la foto del perro: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 110,
      decoration: BoxDecoration(
        color: widget!.selected == true
            ? FlutterFlowTheme.of(context).primary
            : FlutterFlowTheme.of(context).alternate,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Align(
            alignment: AlignmentDirectional(0, 0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Align(
      alignment: const AlignmentDirectional(0, 0),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(7, 7, 7, 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(200),
          child: _isLoading
              ? const SizedBox(
                  width: 70,
                  height: 70,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : (_photoUrl != null && _photoUrl!.isNotEmpty)
                  ? Image.network(
                      _photoUrl!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/golden.jpg',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/golden.jpg',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
        ),
      ),
    ),
              ),
            ),
          ),
          Container(
            width: 100,
            height: 30,
            decoration: BoxDecoration(),
            child: Align(
              alignment: AlignmentDirectional(0, 0),
              child: AutoSizeText(
                valueOrDefault<String>(
                  widget!.petName,
                  'Mascota',
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                minFontSize: 8,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.lexend(
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      fontSize: 12,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
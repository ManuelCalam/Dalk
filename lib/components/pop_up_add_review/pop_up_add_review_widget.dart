import 'package:dalk/auth/supabase_auth/auth_util.dart';
import 'package:dalk/backend/supabase/supabase.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pop_up_add_review_model.dart';
export 'pop_up_add_review_model.dart';

class PopUpAddReviewWidget extends StatefulWidget {
  final int walkId;
  final String userTypeName;
  final String reviewType;
  

  const PopUpAddReviewWidget({
    super.key,
    required this.walkId,
    required this.userTypeName,
    required this.reviewType,
  });

  @override
  State<PopUpAddReviewWidget> createState() => _PopUpAddReviewWidgetState();
}

class _PopUpAddReviewWidgetState extends State<PopUpAddReviewWidget> {
  late PopUpAddReviewModel _model;

  

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PopUpAddReviewModel());
    _model.dogWalkerInfoInputTextController ??= TextEditingController();
    _model.dogWalkerInfoInputFocusNode ??= FocusNode();
    _model.ratingBarValue = 1.0;
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  Future<int?> getWalkerId(int walkId) async {
    final response = await SupaFlow.client
        .from('walks_with_names')
        .select('walker_id')
        .eq('id', walkId)
        .maybeSingle();
    return response?['walker_id'];
  }

  @override
  Widget build(BuildContext context) {

    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 1.0,
        height: MediaQuery.sizeOf(context).height * 0.45,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).tertiary,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(50.0),
            bottomRight: Radius.circular(50.0),
            topLeft: Radius.circular(50.0),
            topRight: Radius.circular(50.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(15.0, 20.0, 10.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Align(
                      alignment: const AlignmentDirectional(1.0, 0.0),
                      child: FlutterFlowIconButton(
                        borderRadius: 8.0,
                        buttonSize: 40.0,
                        icon: FaIcon(
                          FontAwesomeIcons.angleDown,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 24.0,
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
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 25.0),
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 0.9,
                  height: 100.0,
                  decoration: const BoxDecoration(),
                  child: Form(
                    key: _model.formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AutoSizeText(
                              'Califica a ',
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.lexend(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 20.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                            AutoSizeText(
                              widget.userTypeName,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.lexend(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 20.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 18.0, 0.0, 0.0),
                          child: RatingBar.builder(
                            onRatingUpdate: (newValue) => safeSetState(
                                () => _model.ratingBarValue = newValue),
                            itemBuilder: (context, index) => Icon(
                              Icons.star_rounded,
                              color: FlutterFlowTheme.of(context).accent1,
                            ),
                            direction: Axis.horizontal,
                            initialRating: _model.ratingBarValue ??= 0.0,
                            unratedColor:
                                FlutterFlowTheme.of(context).alternate,
                            itemCount: 5,
                            itemSize: 55.0,
                            glowColor: FlutterFlowTheme.of(context).accent1,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 18.0, 0.0, 0.0),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              child: TextFormField(
                                controller:
                                    _model.dogWalkerInfoInputTextController,
                                focusNode: _model.dogWalkerInfoInputFocusNode,
                                autofocus: false,
                                obscureText: false,
                                decoration: InputDecoration(
                                  isDense: true,
                                  labelText: 'Más detalles',
                                  labelStyle: FlutterFlowTheme.of(context)
                                      .bodyLarge
                                      .override(
                                        font: GoogleFonts.lexend(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyLarge
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyLarge
                                                  .fontStyle,
                                        ),
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .fontStyle,
                                      ),
                                  alignLabelWithHint: true,
                                  hintStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.lexend(
                                          fontWeight: FontWeight.normal,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  filled: true,
                                  fillColor:
                                      FlutterFlowTheme.of(context).alternate,
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.lexend(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                maxLines: null,
                                minLines: 5,
                                keyboardType: TextInputType.multiline,
                                cursorColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                validator: _model
                                    .dogWalkerInfoInputTextControllerValidator
                                    .asValidator(context),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 18.0, 0.0, 0.0),
                          child: FFButtonWidget(
                              onPressed: () async {
                                final rating = _model.ratingBarValue ?? 1.0;
                                if (rating < 1) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Debes colocar al menos 1 estrella.')),
                                  );
                                  return;
                                }

                                if(_model.dogWalkerInfoInputTextController.text.trim() == '' 
                                  || _model.dogWalkerInfoInputTextController.text.length < 10
                                  || _model.dogWalkerInfoInputTextController.text.length > 150) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Mínimo 10 caractéres y máximo 150 caractéres.')),
                                    );
                                    return;
                                  }

                                final response = await SupaFlow.client
                                    .from('users')
                                    .select('photo_url')
                                    .eq('uuid', currentUserUid)
                                    .single();
                                  
                                String photoUrl = response['photo_url'] as String;

                                String? reviewedUserId;
                                int? reviewedDogId;

                                if (widget.reviewType == 'Paseador') {
                                    final response = await SupaFlow.client
                                        .from('walks_with_names')
                                        .select('walker_id')
                                        .eq('id', widget.walkId)
                                        .maybeSingle();
                                        
                                    reviewedUserId = response?['walker_id'] as String?; 

                                } else if (widget.reviewType == 'Perro') {
                                    final response = await SupaFlow.client
                                        .from('walks_with_names')
                                        .select('dog_id')
                                        .eq('id', widget.walkId)
                                        .maybeSingle();

                                    reviewedDogId = response?['dog_id'] as int?; 
                                }

                                if (reviewedUserId == null && reviewedDogId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('No se encontró el objetivo a calificar.')),
                                    );
                                    return;
                                }

                                await Supabase.instance.client
                                    .from('reviews')
                                    .insert({
                                        'reviewType': widget.reviewType,
                                        'walk_id': widget.walkId,
                                        'rating': rating.toInt(),
                                        'comments': _model.dogWalkerInfoInputTextController.text,
                                        'author_id': currentUserUid,
                                        'reviewer_photo': photoUrl,
                                        'reviewed_user_id': reviewedUserId, 
                                        'reviewed_dog_id': reviewedDogId,
                                    });

                                context.pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('¡Reseña guardada!')),
                                );
                              },
                              text: 'Guardar reseña',
                            options: FFButtonOptions(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: MediaQuery.sizeOf(context).height * 0.045,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context).accent1,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.lexend(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
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
    );
  }
}

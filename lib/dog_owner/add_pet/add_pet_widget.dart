import 'package:dalk/backend/supabase/supabase.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/components/go_back_container/go_back_container_widget.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/components/pop_up_confirm_dialog/pop_up_confirm_dialog_widget.dart';
import '/utils/validation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'add_pet_model.dart';
export 'add_pet_model.dart';

class AddPetWidget extends StatefulWidget {
  const AddPetWidget({super.key});

  static String routeName = 'addPet';
  static String routePath = '/addPet';

  @override
  State<AddPetWidget> createState() => _AddPetWidgetState();
}

class _AddPetWidgetState extends State<AddPetWidget> {
  late AddPetModel _model;
  File? _ownerImage;
  File? _walkerImage;
  File? _petImage;
  final ImagePicker _picker = ImagePicker();

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isRegistering = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddPetModel());

    _model.nameInputTextController ??= TextEditingController();
    _model.nameInputFocusNode ??= FocusNode();

    _model.ageInputTextController ??= TextEditingController();
    _model.ageInputFocusNode ??= FocusNode();

    _model.breeInputTextController ??= TextEditingController();
    _model.breeInputFocusNode ??= FocusNode();

    _model.dogInfoInputTextController ??= TextEditingController();
    _model.dogInfoInputFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }
  bool validarCamposObligatorios() {
    return _model.nameInputTextController.text.isNotEmpty &&
          _model.genderDogOwnerMenuValue != null &&
          _model.ageInputTextController.text.isNotEmpty &&
          _model.breeInputTextController.text.isNotEmpty &&
          _model.dogInfoInputTextController.text.isNotEmpty &&
          _model.behaviourChipsValueController != null &&
          _model.dogSizeMenuValue != null;
  }

  Future<String?> _uploadOwnerImage(String userId, File imageFile, {int? petId}) async {
    try {
      final storage = Supabase.instance.client.storage;
      final supabase = Supabase.instance.client;

      final filePath = petId != null
          ? 'owners/$userId/pets/$petId/profile.jpg'
          : 'owners/$userId/profile.jpg';

      await storage.from('profile_pics').upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = storage.from('profile_pics').getPublicUrl(filePath);

      if (petId != null) {
        await supabase.from('pets').update({'photo_url': imageUrl}).eq('id', petId);
      }

      return imageUrl;
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  //funcion para seleccionar imagen
    Future<void> _pickImage(bool isOwner, ImageSource source, {int? petId}) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isOwner) {
          _ownerImage = File(pickedFile.path);
        } else {
          _walkerImage = File(pickedFile.path);
        }
      });

      // Subir imagen si es de perro
      if (petId != null) {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          await _uploadOwnerImage(userId, File(pickedFile.path), petId: petId);
        }
      }
    }
  }

  void _showImagePickerOptions(BuildContext context, bool isOwner, int? petId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(isOwner, ImageSource.camera, petId: petId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de la galería'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(isOwner, ImageSource.gallery, petId: petId);
              },
            ),
          ],
        ),
      ),
    );
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
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                  ),
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
                      AutoSizeText(
                        'Nueva mascota',
                        textAlign: TextAlign.center,
                        minFontSize: 22,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lexend(
                                fontWeight: FontWeight.bold,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).primary,
                              fontSize: 32,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                      AutoSizeText(
                        '!Registra a tu mascota!',
                        textAlign: TextAlign.center,
                        minFontSize: 10,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lexend(
                                fontWeight: FontWeight.w500,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).accent1,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 15),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.9,
                            height: double.infinity,
                            decoration: const BoxDecoration(),
                            child: Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Align(
  alignment: const AlignmentDirectional(0, 0),
  child: Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
    child: GestureDetector(
      onTap: () => _showImagePickerOptions(context, true, 2), 
      child: CircleAvatar(
        radius: 60,
        backgroundImage: _ownerImage != null
            ? FileImage(_ownerImage!)
            : const NetworkImage(
                'https://static.vecteezy.com/system/resources/previews/007/407/996/non_2x/user-icon-person-icon-client-symbol-login-head-sign-icon-design-vector.jpg',
              ) as ImageProvider,
      ),
    ),
  ),
),

                                    ),
                                    Text('Presiona para elegir una foto', style: FlutterFlowTheme.of(context).bodyMedium.override()),
                                    Align(
                                      alignment: const AlignmentDirectional(-1, -1),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            0, 18, 0, 0),
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width,
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.05,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                            borderRadius:
                                                BorderRadius.circular(35),
                                          ),
                                          child: Container(
                                            width: double.infinity,
                                            child: TextFormField(
                                              controller: _model
                                                  .nameInputTextController,
                                              focusNode:
                                                  _model.nameInputFocusNode,
                                              autofocus: false,
                                              textInputAction:
                                                  TextInputAction.next,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                labelText: 'Nombre',
                                                labelStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyLarge
                                                    .override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyLarge
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyLarge
                                                                .fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .fontStyle,
                                                    ),
                                                alignLabelWithHint: false,
                                                hintStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .labelMedium
                                                    .override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      fontSize: 16,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .fontStyle,
                                                    ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0x00000000),
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0x00000000),
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.person,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  size: 25,
                                                ),
                                              ),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.lexend(
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    fontSize: 16,
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                              cursorColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              //validar el nombre como requerido
  validator: (value) => Validators.requiredField(value, fieldName: 'Nombre'),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: const AlignmentDirectional(-1, -1),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            0, 18, 0, 0),
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width,
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.05,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                            borderRadius:
                                                BorderRadius.circular(35),
                                          ),
                                          child: Container(
                                            width: double.infinity,
                                            child: TextFormField(
                                              controller:
                                                  _model.ageInputTextController,
                                              focusNode:
                                                  _model.ageInputFocusNode,
                                              autofocus: false,
                                              textInputAction:
                                                  TextInputAction.next,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                labelText: 'Edad',
                                                labelStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyLarge
                                                    .override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyLarge
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyLarge
                                                                .fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .fontStyle,
                                                    ),
                                                hintStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .labelMedium
                                                    .override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      fontSize: 16,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .fontStyle,
                                                    ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0x00000000),
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0x00000000),
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                prefixIcon: Icon(
                                                  Icons
                                                      .perm_contact_cal_outlined,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  size: 25,
                                                ),
                                              ),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.lexend(
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    fontSize: 16,
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                              keyboardType:
                                                  TextInputType.number,
                                              cursorColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              //validar el edad como requerido
  validator: (value) => Validators.requiredField(value, fieldName: 'Edad'),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: const AlignmentDirectional(-1, -1),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            0, 18, 0, 0),
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width,
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.05,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                            borderRadius:
                                                BorderRadius.circular(35),
                                          ),
                                          child: FlutterFlowDropDown<String>(
                                            controller: _model
                                                    .genderDogOwnerMenuValueController ??=
                                                FormFieldController<String>(
                                              _model.genderDogOwnerMenuValue ??=
                                                  '',
                                                  
                                            ),
                                            options: List<String>.from(
                                                ['Macho', 'Hembra'],),
                                            optionLabels: ['Macho', 'Hembra'],
                                            onChanged: (val) => safeSetState(() =>
                                                _model.genderDogOwnerMenuValue =
                                                    val),
                                            width: MediaQuery.sizeOf(context)
                                                .width,
                                            height: MediaQuery.sizeOf(context)
                                                    .height *
                                                0.05,
                                            textStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      fontSize: 16,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                              
                                                    ),
                                            hintText: 'Género',
                                            icon: Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              size: 25,
                                            ),
                                            fillColor:
                                                FlutterFlowTheme.of(context)
                                                    .alternate,
                                            elevation: 2,
                                            borderColor: Colors.transparent,
                                            borderWidth: 0,
                                            borderRadius: 8,
                                            margin:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    12, 0, 12, 0),
                                            hidesUnderline: true,
                                            isOverButton: false,
                                            isSearchable: false,
                                            isMultiSelect: false,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: const AlignmentDirectional(-1, -1),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            0, 18, 0, 0),
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width,
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.05,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                            borderRadius:
                                                BorderRadius.circular(35),
                                          ),
                                          child: Container(
                                            width: double.infinity,
                                            child: TextFormField(
                                              controller: _model
                                                  .breeInputTextController,
                                              focusNode:
                                                  _model.breeInputFocusNode,
                                              autofocus: false,
                                              textInputAction:
                                                  TextInputAction.next,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                labelText: 'Raza',
                                                labelStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyLarge
                                                    .override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyLarge
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyLarge
                                                                .fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .fontStyle,
                                                    ),
                                                hintStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      fontSize: 16,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0x00000000),
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0x00000000),
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.pets_outlined,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  size: 25,
                                                ),
                                              ),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.lexend(
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    fontSize: 16,
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                              cursorColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              //validar el Raza como requerido
                                              validator: (value) => Validators.requiredField(value, fieldName: 'Raza'),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0, 18, 0, 0),
                                      child: FlutterFlowDropDown<String>(
                                        controller: _model
                                                .dogSizeMenuValueController ??=
                                            FormFieldController<String>(
                                          _model.dogSizeMenuValue ??= '',
                                        ),
                                        options: List<String>.from(
                                            ['Chico', 'Mediano', 'Grande']),
                                        optionLabels: const [
                                          'Chico',
                                          'Mediano',
                                          'Grande'
                                        ],
                                        onChanged: (val) => safeSetState(() =>
                                            _model.dogSizeMenuValue = val),
                                        width: MediaQuery.sizeOf(context).width,
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.05,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.lexend(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              fontSize: 16,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                        hintText: 'Tamaño',
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 25,
                                        ),
                                        fillColor: FlutterFlowTheme.of(context)
                                            .alternate,
                                        elevation: 2,
                                        borderColor: Colors.transparent,
                                        borderWidth: 0,
                                        borderRadius: 8,
                                        margin: const EdgeInsetsDirectional.fromSTEB(
                                            12, 0, 12, 0),
                                        hidesUnderline: true,
                                        isOverButton: false,
                                        isSearchable: false,
                                        isMultiSelect: false,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            0, 18, 0, 0),
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width,
                                          decoration: const BoxDecoration(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Align(
                                                alignment:
                                                    const AlignmentDirectional(-1, 0),
                                                child: Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(0, 0, 0, 5),
                                                  child: AutoSizeText(
                                                    'Comportamiento',
                                                    maxLines: 1,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .lexend(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .accent1,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    const AlignmentDirectional(0, 0),
                                                child: FlutterFlowChoiceChips(
                                                  options: const [
                                                    ChipData(
                                                        'Sociable con otros perros'),
                                                    ChipData('Nervioso'),
                                                    ChipData('Tranquilo'),
                                                    ChipData('Obediente'),
                                                    ChipData('Energético'),
                                                    ChipData(
                                                        'Tira de la correa'),
                                                    ChipData(
                                                        'No se lleva con otros perros'),
                                                    ChipData(
                                                        'Amigable con personas')
                                                  ],
                                                  onChanged: (val) =>
                                                      safeSetState(() => _model
                                                              .behaviourChipsValues =
                                                          val),
                                                  selectedChipStyle: ChipStyle(
                                                    backgroundColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    textStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .override(
                                                              font: GoogleFonts
                                                                  .lexend(
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .info,
                                                              fontSize: 16,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                            ),
                                                    iconColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .info,
                                                    iconSize: 16,
                                                    labelPadding:
                                                        const EdgeInsets.all(5),
                                                    elevation: 0,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  unselectedChipStyle:
                                                      ChipStyle(
                                                    backgroundColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .alternate,
                                                    textStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .override(
                                                              font: GoogleFonts
                                                                  .lexend(
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              fontSize: 16,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                            ),
                                                    iconColor: FlutterFlowTheme
                                                            .of(context)
                                                        .secondaryBackground,
                                                    iconSize: 16,
                                                    labelPadding:
                                                        const EdgeInsets.all(5),
                                                    elevation: 0,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  chipSpacing: 2,
                                                  rowSpacing: 5,
                                                  multiselect: true,
                                                  initialized: _model
                                                          .behaviourChipsValues !=
                                                      null,
                                                  alignment:
                                                      WrapAlignment.center,
                                                  controller: _model
                                                          .behaviourChipsValueController ??=
                                                      FormFieldController<
                                                          List<String>>(
                                                    [],
                                                  ),
                                                  wrapped: true,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: const AlignmentDirectional(-1, -1),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            0, 18, 0, 0),
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                            borderRadius:
                                                BorderRadius.circular(35),
                                          ),
                                          child: Container(
                                            width: MediaQuery.sizeOf(context).width,
                                            child: TextFormField(
                                              controller: _model.dogInfoInputTextController,
                                              focusNode: _model.dogInfoInputFocusNode,
                                              autofocus: false,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                labelText: 'Acerca de tu perro',
                                                labelStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                                                        fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                      ),
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      fontSize: 16,
                                                      letterSpacing: 0.0,
                                                      fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                                                      fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                    ),
                                                hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight: FontWeight.bold,
                                                        fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                      ),
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      fontSize: 16,
                                                      letterSpacing: 0.0,
                                                      fontWeight: FontWeight.bold,
                                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                    ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(context).alternate,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0x00000000),
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(context).error,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                focusedErrorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(context).error,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                filled: true,
                                                fillColor: FlutterFlowTheme.of(context).alternate,
                                                prefixIcon: Icon(
                                                  Icons.person,
                                                  color: FlutterFlowTheme.of(context).primary,
                                                  size: 25,
                                                ),
                                              ),
                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                    font: GoogleFonts.lexend(
                                                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                    fontSize: 16,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                  ),
                                              maxLines: null,
                                              minLines: 5,
                                              keyboardType: TextInputType.multiline,
                                              cursorColor: FlutterFlowTheme.of(context).primaryText,
                                              //validar el Acerca de tu perro como requerido
                                              validator: (value) => Validators.requiredField(value, fieldName: ''),
                                            ),
                                          )

                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            0, 18, 0, 0),
                                        child: FFButtonWidget(
                                          onPressed: () async {
  if (!validarCamposObligatorios()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Completa todos los campos')),
    );
    return;
  }

  try {
    final supabase = Supabase.instance.client;
    final userId = Supabase.instance.client.auth.currentUser?.id;

    // 1️⃣ Insertar la mascota (sin imagen todavía)
    final response = await supabase
        .from('pets')
        .insert({
          'uuid': userId,
          'name': _model.nameInputTextController.text,
          'age': _model.ageInputTextController.text,
          'gender': _model.genderDogOwnerMenuValue,
          'bree': _model.breeInputTextController.text,
          'size': _model.dogSizeMenuValue,
          'behaviour': _model.behaviourChipsValueController?.value ?? [],
          'aboutme': _model.dogInfoInputTextController.text,
        })
        .select(); // 👈 muy importante para obtener el ID insertado

    // 2️⃣ Obtener el id del nuevo perro
    final petData = response.first;
    final petId = petData['id'] as int;

    // 3️⃣ Subir imagen si el usuario eligió una
    if (_ownerImage != null && userId != null) {
      await _uploadOwnerImage(userId, _ownerImage!, petId: petId);
    }

    // 4️⃣ Mostrar confirmación
    showDialog(
      context: context,
      builder: (_) => PopUpConfirmDialogWidget(
        title: "Mascota registrada",
        message: "¡Mascota ya forma parte de tu familia en la app!",
        confirmText: "Agregar otra mascota",
        cancelText: "Menú principal",
        confirmColor: FlutterFlowTheme.of(context).accent1,
        cancelColor: FlutterFlowTheme.of(context).primary,
        icon: Icons.check_circle,
        iconColor: FlutterFlowTheme.of(context).success,
        onConfirm: () => context.goNamed(AddPetWidget.routeName),
        onCancel: () => context.go('/'),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al registrar la mascota: $e')),
    );
  }
},
                                          text: 'Agregar Mascota',
                                          options: FFButtonOptions(
                                            width: MediaQuery.sizeOf(context)
                                                .width,
                                            height: MediaQuery.sizeOf(context)
                                                    .height *
                                                0.05,
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    0, 0, 0, 0),
                                            iconPadding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    0, 0, 0, 0),
                                            color: FlutterFlowTheme.of(context)
                                                .accent1,
                                            textStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .fontStyle,
                                                      ),
                                                      color: Colors.white,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmall
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmall
                                                              .fontStyle,
                                                    ),
                                            elevation: 0,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
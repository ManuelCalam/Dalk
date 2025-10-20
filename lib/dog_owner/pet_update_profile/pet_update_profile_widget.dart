import 'package:dalk/backend/supabase/database/database.dart';

import '/components/go_back_container/go_back_container_widget.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


import 'pet_update_profile_model.dart';
export 'pet_update_profile_model.dart';

class PetUpdateProfileWidget extends StatefulWidget {
  final Map<String, dynamic>? petData;

  //const PetUpdateProfileWidget({super.key, required Map<String, dynamic> petData, this.petData});
  const PetUpdateProfileWidget({Key? key, this.petData}) : super(key: key);

  static String routeName = 'petUpdateProfile';
  static String routePath = '/petUpdateProfile';

  @override
  State<PetUpdateProfileWidget> createState() => _PetUpdateProfileWidgetState();
}

class _PetUpdateProfileWidgetState extends State<PetUpdateProfileWidget> {
  late PetUpdateProfileModel _model;
  File? _ownerImage;
  File? _petImage;
  final ImagePicker _picker = ImagePicker();

  // Valores posibles (ajusta si tus etiquetas son otras)
    final List<String> behaviourOptions = [
      'Sociable con otros perros',
      'Nervioso',
      'Tranquilo',
      'Obediente',
      'Energético',
      'Tira de la correa',
      'No se lleva con otros perros',
      'Amigable con personas',
    ];

    // Estado local para chips / dropdowns
    Set<String> selectedBehaviours = {};
    String? selectedGender;
    String? selectedSize;


  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSaving = false;
  final supabase = Supabase.instance.client;


  Future<String?> _uploadPetImage(String userId, File imageFile, {int? petId}) async {
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

  Future<void> _pickImage(bool isOwner, ImageSource source, {int? petId}) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isOwner) {
          _ownerImage = File(pickedFile.path);
        } else {
          _petImage = File(pickedFile.path);
        }
      });

      if (petId != null) {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          await _uploadPetImage(userId, File(pickedFile.path), petId: petId);
        } else {
          print(' No hay usuario autenticado');
        }
      } else {
        print(' petId es null, no se puede subir');
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
  void initState() {
    super.initState();

    // Asegúrate de crear el modelo primero
    _model = createModel(context, () => PetUpdateProfileModel());

    final pet = widget.petData ?? {};

    // ---- Text controllers ----
    _model.nameInputTextController ??=
        TextEditingController(text: pet['name'] ?? '');
    _model.nameInputFocusNode ??= FocusNode();

    _model.ageInputTextController ??=
        TextEditingController(text: pet['age']?.toString() ?? '');
    _model.ageInputFocusNode ??= FocusNode();

    _model.raceInputTextController ??=
        TextEditingController(text: pet['bree'] ?? '');
    _model.raceInputFocusNode ??= FocusNode();

    _model.dogInfoInputTextController ??=
        TextEditingController(text: pet['aboutme'] ?? '');
    _model.dogInfoInputFocusNode ??= FocusNode();
    
    // ---- Campos seleccionables (gender, behaviour, etc.) ----

    final genderVal = pet['gender']?.toString() ??
    pet['sexo']?.toString() ??
    pet['genero']?.toString();

    if (genderVal != null && genderVal.isNotEmpty) {
      _model.genderDogOwnerMenuValue = genderVal;

      // Si el controlador ya existe, actualiza el valor.
      if (_model.genderDogOwnerMenuValueController != null) {
        _model.genderDogOwnerMenuValueController!.value = genderVal;
      } else {
        _model.genderDogOwnerMenuValueController =
            FormFieldController<String>(genderVal);
      }
    }

    final dynamic behaviourRaw =
        pet['behavior'] ?? pet['behaviour'] ?? pet['characteristics'];

    if (behaviourRaw != null) {
      if (behaviourRaw is List) {
        selectedBehaviours = behaviourRaw.map((e) => e.toString()).toSet();
      } else if (behaviourRaw is String) {
        selectedBehaviours = behaviourRaw
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toSet();
      } else {
        selectedBehaviours = {behaviourRaw.toString()};
      }
    }

    // TAMAÑO (Size)
    final sizeVal = pet['size']?.toString() ?? pet['tamaño']?.toString();
    if (sizeVal != null && sizeVal.isNotEmpty) {
      _model.dogSizeMenuValue = sizeVal;
      _model.dogSizeMenuValueController =
          FormFieldController<String>(sizeVal);
    }

    _model.onUpdate();
  }


  Future<void> _saveChanges() async {
    final petId = widget.petData?['id'];

    if (petId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró el ID de la mascota')),
      );
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró el usuario actual')),
      );
      return;
    }

    // --- obtener los valores de los campos ---
    final name = _model.nameInputTextController?.text ?? '';
    final age = int.tryParse(_model.ageInputTextController?.text ?? '');
    final race = _model.raceInputTextController?.text ?? '';
    final about = _model.dogInfoInputTextController?.text ?? '';

    final sizeValue =
        _model.dogSizeMenuValue ?? _model.dogSizeMenuValueController?.value;
    final genderValue = _model.genderDogOwnerMenuValue ??
        _model.genderDogOwnerMenuValueController?.value;

    List<String> behaviourList = [];
    if (_model.behaviourChipsValues != null) {
      behaviourList = List<String>.from(_model.behaviourChipsValues!);
    } else if (_model.behaviourChipsValueController?.value != null) {
      behaviourList =
          List<String>.from(_model.behaviourChipsValueController!.value ?? []);
    }

    final payload = <String, dynamic>{
      'name': name,
      if (age != null) 'age': age,
      'bree': race,
      'aboutme': about,
      'size': sizeValue,
      'gender': genderValue,
      'behaviour': behaviourList,
    };

    try {
      setState(() => _isSaving = true);

      // 🔹 Si hay una imagen nueva seleccionada, súbela primero
      String? imageUrl;
      if (_petImage  != null) {
        imageUrl = await _uploadPetImage(userId, _petImage !, petId: petId);
        if (imageUrl != null && imageUrl.isNotEmpty) {
          payload['photo_url'] = imageUrl;
        }
      }

      print('🔹 Enviando actualización para ID: $petId');
      print('🔹 Payload: $payload');

      final response = await supabase
          .from('pets')
          .update(payload)
          .eq('id', petId)
          .select();

      print('🔹 Supabase response: $response');

      if (response is List && response.isNotEmpty) {
        final updated = Map<String, dynamic>.from(response.first);

        widget.petData?.addAll(updated);

        setState(() {
          _isSaving = false;
          _model.nameInputTextController?.text = updated['name'] ?? '';
          _model.ageInputTextController?.text = updated['age']?.toString() ?? '';
          _model.raceInputTextController?.text = updated['bree'] ?? '';
          _model.dogInfoInputTextController?.text = updated['aboutme'] ?? '';
          _model.dogSizeMenuValue = updated['size'];
          _model.dogSizeMenuValueController?.value = updated['size'];
          _model.genderDogOwnerMenuValue = updated['gender'];
          _model.genderDogOwnerMenuValueController?.value = updated['gender'];
          if (updated['photo_url'] != null) {
            widget.petData?['photo_url'] = updated['photo_url'];
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(' Datos actualizados correctamente')),
        );
      } else {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(' No se pudo actualizar la mascota (sin coincidencias)')),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' Error al actualizar: $e')),
      );
    }
  }





  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                  ),
                ),
                child: wrapWithModel(
                  model: _model.notificationContainerModel,
                  updateCallback: () => safeSetState(() {}),
                  child: NotificationContainerWidget(),
                ),
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).tertiary,
                    borderRadius: BorderRadius.only(
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
                        child: GoBackContainerWidget(),
                      ),
                      AutoSizeText(
                        'Editar datos',
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
                        '¡Edita los datos de tu mascota!',
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
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 15),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.9,
                            height: double.infinity,
                            decoration: BoxDecoration(),
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Align(
                                        alignment: AlignmentDirectional(0, 0),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                                          child: GestureDetector(
                                            onTap: () => _showImagePickerOptions(context, false, widget.petData?['id']),
                                            child: CircleAvatar(
                                              radius: 60,
                                              backgroundImage: _petImage != null
                                                  ? FileImage(_petImage!) // Imagen nueva seleccionada
                                                  : (widget.petData?['photo_url'] != null &&
                                                          (widget.petData?['photo_url'] as String).isNotEmpty)
                                                      ? NetworkImage(widget.petData!['photo_url'])
                                                      : const NetworkImage(
                                                          'https://static.vecteezy.com/system/resources/previews/007/407/996/non_2x/user-icon-person-icon-client-symbol-login-head-sign-icon-design-vector.jpg',
                                                        ) as ImageProvider,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: AlignmentDirectional(-1, -1),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
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
                                                  borderSide: BorderSide(
                                                    color: Color(0x00000000),
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
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
                                              validator: _model
                                                  .nameInputTextControllerValidator
                                                  .asValidator(context),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: AlignmentDirectional(-1, -1),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
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
                                                  borderSide: BorderSide(
                                                    color: Color(0x00000000),
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
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
                                              validator: _model
                                                  .ageInputTextControllerValidator
                                                  .asValidator(context),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: AlignmentDirectional(-1, -1),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
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
                                                ['Macho', 'Hembra']),
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
                                                EdgeInsetsDirectional.fromSTEB(
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
                                      alignment: AlignmentDirectional(-1, -1),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
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
                                                  .raceInputTextController,
                                              focusNode:
                                                  _model.raceInputFocusNode,
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
                                                  borderSide: BorderSide(
                                                    color: Color(0x00000000),
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
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
                                              validator: _model
                                                  .raceInputTextControllerValidator
                                                  .asValidator(context),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 18, 0, 0),
                                      child: FlutterFlowDropDown<String>(
                                        controller: _model
                                                .dogSizeMenuValueController ??=
                                            FormFieldController<String>(
                                          _model.dogSizeMenuValue ??= '',
                                        ),
                                        options: List<String>.from(
                                            ['Chico', 'Mediano', 'Grande']),
                                        optionLabels: [
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
                                        margin: EdgeInsetsDirectional.fromSTEB(
                                            12, 0, 12, 0),
                                        hidesUnderline: true,
                                        isOverButton: false,
                                        isSearchable: false,
                                        isMultiSelect: false,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 18, 0, 0),
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width,
                                          decoration: BoxDecoration(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Align(
                                                alignment:
                                                    AlignmentDirectional(-1, 0),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
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
                                                alignment: AlignmentDirectional(0, 0),
                                                child: FlutterFlowChoiceChips(
                                                  options: [
                                                    ChipData('Sociable con otros perros'),
                                                    ChipData('Nervioso'),
                                                    ChipData('Tranquilo'),
                                                    ChipData('Obediente'),
                                                    ChipData('Energético'),
                                                    ChipData('Tira de la correa'),
                                                    ChipData('No se lleva con otros perros'),
                                                    ChipData('Amigable con personas'),
                                                  ],

                                                  // ✅ Solo un controller
                                                  controller: _model.behaviourChipsValueController ??=
                                                      FormFieldController<List<String>>(
                                                        selectedBehaviours?.toList() ?? [],
                                                      ),

                                                  // ✅ Solo un multiselect
                                                  multiselect: true,

                                                  onChanged: (val) {
                                                    setState(() => selectedBehaviours = val?.toSet() ?? {});
                                                  },
                                                  selectedChipStyle: ChipStyle(
                                                    backgroundColor: FlutterFlowTheme.of(context).primary,
                                                    textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                          font: GoogleFonts.lexend(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme.of(context).info,
                                                          letterSpacing: 0.0,
                                                        ),
                                                    iconColor: FlutterFlowTheme.of(context).info,
                                                    iconSize: 16,
                                                    labelPadding: EdgeInsets.all(5),
                                                    elevation: 0,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  unselectedChipStyle: ChipStyle(
                                                    backgroundColor: FlutterFlowTheme.of(context).alternate,
                                                    textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                          font: GoogleFonts.lexend(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                          ),
                                                          color:
                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                          fontSize: 16,
                                                          letterSpacing: 0.0,
                                                        ),
                                                    iconColor:
                                                        FlutterFlowTheme.of(context).secondaryBackground,
                                                    iconSize: 16,
                                                    labelPadding: EdgeInsets.all(5),
                                                    elevation: 0,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  chipSpacing: 2,
                                                  rowSpacing: 5,
                                                  initialized: _model.behaviourChipsValues != null,
                                                  alignment: WrapAlignment.center,
                                                  wrapped: true,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 18, 0, 0),
                                      child: Container(
                                        width: MediaQuery.sizeOf(context).width,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .alternate,
                                          borderRadius:
                                              BorderRadius.circular(35),
                                        ),
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width,
                                          child: TextFormField(
                                            controller: _model
                                                .dogInfoInputTextController,
                                            focusNode:
                                                _model.dogInfoInputFocusNode,
                                            autofocus: false,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              labelText: 'Acerca de tu perro',
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
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    fontSize: 16,
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
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    fontSize: 16,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium
                                                            .fontStyle,
                                                  ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .alternate,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
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
                                                    BorderRadius.circular(30),
                                              ),
                                              filled: true,
                                              fillColor:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              prefixIcon: Icon(
                                                Icons.person,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                size: 25,
                                              ),
                                            ),
                                            style: FlutterFlowTheme.of(context)
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
                                            maxLines: null,
                                            minLines: 5,
                                            keyboardType:
                                                TextInputType.multiline,
                                            cursorColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            validator: _model
                                                .dogInfoInputTextControllerValidator
                                                .asValidator(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 18, 0, 0),
                                        child: FFButtonWidget(
                                          onPressed: () async {
                                            await _saveChanges();
                                          },
                                          //text: 'Guardar cambios',
                                          text: _isSaving ? 'Guardando...' : 'Guardar',
                                          options: FFButtonOptions(
                                            width: MediaQuery.sizeOf(context)
                                                .width,
                                            height: MediaQuery.sizeOf(context)
                                                    .height *
                                                0.05,
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0, 0, 0, 0),
                                            iconPadding:
                                                EdgeInsetsDirectional.fromSTEB(
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


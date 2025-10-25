import 'package:dalk/backend/supabase/supabase.dart';
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
import '/utils/validation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isRegistering = false;

  bool _showGenderError = false;
  bool _showSizeError = false;
  bool _showBehaviourError = false;
  bool _formSubmitted = false;

  // Variables para controlar la validación individual de cada campo
  bool _nameTouched = false;
  bool _ageTouched = false;
  bool _breeTouched = false;
  bool _descriptionTouched = false;

  AutovalidateMode _nameValidateMode = AutovalidateMode.disabled;
  AutovalidateMode _ageValidateMode = AutovalidateMode.disabled;
  AutovalidateMode _breedValidateMode = AutovalidateMode.disabled;
  AutovalidateMode _descriptionValidateMode = AutovalidateMode.disabled;

  @override
void initState() {
  super.initState();
  _model = createModel(context, () => AddPetModel());

  _model.nameInputTextController ??= TextEditingController();
  _model.nameInputFocusNode ??= FocusNode()
    ..addListener(() {
      if (_model.nameInputFocusNode != null && !_model.nameInputFocusNode!.hasFocus) {
        setState(() {
          _nameTouched = true;
        });
      }
    });

  _model.ageInputTextController ??= TextEditingController();
  _model.ageInputFocusNode ??= FocusNode()
    ..addListener(() {
      if (_model.ageInputFocusNode != null && !_model.ageInputFocusNode!.hasFocus) {
        setState(() {
          _ageTouched = true;
        });
      }
    });

  _model.breeInputTextController ??= TextEditingController();
  _model.breeInputFocusNode ??= FocusNode()
    ..addListener(() {
      if (_model.breeInputFocusNode != null && !_model.breeInputFocusNode!.hasFocus) {
        setState(() {
          _breeTouched = true;
        });
      }
    });

  _model.dogInfoInputTextController ??= TextEditingController();
  _model.dogInfoInputFocusNode ??= FocusNode()
    ..addListener(() {
      if (_model.dogInfoInputFocusNode != null && !_model.dogInfoInputFocusNode!.hasFocus) {
        setState(() {
          _descriptionTouched = true;
        });
      }
    });
}
  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Edad es requerida';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Ingrese una edad válida';
    }
    if (age <= 0) {
      return 'La edad debe ser mayor a 0';
    }
    if (age > 30) {
      return 'La edad debe ser menor a 30';
    }
    return null;
  }

  String? _validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Género es requerido';
    }
    return null;
  }

  String? _validateSize(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tamaño es requerido';
    }
    return null;
  }

  String? _validateBehaviour(List<String>? values) {
    if (values == null || values.isEmpty) {
      return 'Selecciona al menos un comportamiento';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Descripción es requerida';
    }
    if (value.trim().length < 10) {
      return 'La descripción debe tener al menos 10 caracteres';
    }
    if (value.length > 300) {
      return 'La descripción no debe exceder 300 caracteres';
    }
    return null;
  }

  // Validaciones condicionales que solo se activan cuando el campo ha sido tocado o el formulario enviado
  String? _validateName(String? value) {
    if (!_nameTouched && !_formSubmitted) return null;
    return Validators.requiredField(value, fieldName: 'Nombre');
  }

  String? _validateAgeConditional(String? value) {
    if (!_ageTouched && !_formSubmitted) return null;
    return _validateAge(value);
  }

  String? _validateBreeConditional(String? value) {
    if (!_breeTouched && !_formSubmitted) return null;
    return _validateRequired(value, 'Raza');
  }

  String? _validateDescriptionConditional(String? value) {
    if (!_descriptionTouched && !_formSubmitted) return null;
    return _validateDescription(value);
  }

  bool validarCamposObligatorios() {
    return _model.nameInputTextController.text.isNotEmpty &&
          _model.genderDogOwnerMenuValue != null &&
          _model.ageInputTextController.text.isNotEmpty &&
          _model.breeInputTextController.text.isNotEmpty &&
          _model.dogInfoInputTextController.text.isNotEmpty &&
          _model.behaviourChipsValues != null &&
          _model.behaviourChipsValues!.isNotEmpty &&
          _model.dogSizeMenuValue != null;
  }

// Subir imagen de la mascota a Supabase Storage
Future<String?> _uploadPetImage(
  BuildContext context,
  String userId,
  File imageFile, {
  int? petId,
}) async {
  try {
    final fileSize = await imageFile.length();
    const maxSize = 5 * 1024 * 1024; // 5 MB

    if (fileSize > maxSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La imagen supera el tamaño máximo permitido (5 MB).'),
        ),
      );
      return null;
    }

    final storage = Supabase.instance.client.storage;
    final supabase = Supabase.instance.client;
    final filePath = 'owners/$userId/pets/$petId/profile.jpg';

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error al subir imagen. Vuelve a intentarlo.')),
    );
    return null;
  }
}

// Seleccionar imagen
Future<void> _pickImage(BuildContext context, ImageSource source, {int? petId}) async {
  final pickedFile = await _picker.pickImage(source: source);

  if (pickedFile != null) {
    setState(() {
      _ownerImage = File(pickedFile.path);
    });

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null && petId != null) {
      await _uploadPetImage(context, userId, File(pickedFile.path), petId: petId);
    }
  }
}

// Mostrar opciones de imagen
void _showImagePickerOptions(BuildContext context, {int? petId}) {
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
              _pickImage(context, ImageSource.camera, petId: petId);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Elegir de la galería'),
            onTap: () {
              Navigator.of(context).pop();
              _pickImage(context, ImageSource.gallery, petId: petId);
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
                                child: Form(
                                  key: _formKey,
                                  //autovalidateMode: AutovalidateMode.disabled,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Align(
                                        alignment: const AlignmentDirectional(0, 0),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                                          child: GestureDetector(
                                            onTap: () => _showImagePickerOptions(context),
                                            child: CircleAvatar(
                                              radius: 60,
                                              backgroundImage: _ownerImage != null
                                                  ? FileImage(_ownerImage!)
                                                  : const NetworkImage(
                                                      'https://bsactypehgxluqyaymui.supabase.co/storage/v1/object/public/profile_pics/dog.png',
                                                    ) as ImageProvider,
                                            ),
                                          ),
                                        ),
                                      )),
                                      Text('Presiona para elegir una foto', style: FlutterFlowTheme.of(context).bodyMedium.override()),
                                      Align(
                                        alignment: const AlignmentDirectional(-1, -1),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                          child: Container(
                                            width: MediaQuery.sizeOf(context).width,
                                            child: TextFormField(
                                              controller: _model.nameInputTextController,
                                              focusNode: _model.nameInputFocusNode,
                                              autofocus: false,
                                              textInputAction: TextInputAction.next,
                                              obscureText: false,
                                              onChanged: (value) {
                                                if (_nameValidateMode == AutovalidateMode.disabled) {
                                                  setState(() {
                                                    _nameValidateMode = AutovalidateMode.always;
                                                  });
                                                }
                                              },
                                              decoration: InputDecoration(
                                                isDense: true,
                                                labelText: 'Nombre',
                                                labelStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                                                        fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                      fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                                                      fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                    ),
                                                alignLabelWithHint: false,
                                                hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight: FontWeight.w500,
                                                        fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                      ),
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      fontSize: 16,
                                                      letterSpacing: 0.0,
                                                      fontWeight: FontWeight.w500,
                                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                    ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(context).alternate,
                                                    width: 2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0x00000000),
                                                    width: 2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(context).error,
                                                    width: 2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                focusedErrorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(context).error,
                                                    width: 2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                filled: true,
                                                fillColor: FlutterFlowTheme.of(context).alternate,
                                                contentPadding: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 20),
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
                                              cursorColor: FlutterFlowTheme.of(context).primaryText,
                                              validator: (value) => Validators.requiredField(value, fieldName: 'Nombre'),
                                              autovalidateMode: _nameValidateMode,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: const AlignmentDirectional(-1, -1),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                          child: Container(
                                            width: MediaQuery.sizeOf(context).width,
                                            child: TextFormField(
                                              controller: _model.ageInputTextController,
                                              focusNode: _model.ageInputFocusNode,
                                              autofocus: false,
                                              textInputAction: TextInputAction.next,
                                              obscureText: false,
                                              onChanged: (value) {
                                                if (_ageValidateMode == AutovalidateMode.disabled) {
                                                  setState(() {
                                                    _ageValidateMode = AutovalidateMode.always;
                                                  });
                                                }
                                              },
                                              decoration: InputDecoration(
                                                isDense: true,
                                                labelText: 'Edad',
                                                labelStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                                                        fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                      fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                                                      fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                    ),
                                                hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight: FontWeight.w500,
                                                        fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                      ),
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      fontSize: 16,
                                                      letterSpacing: 0.0,
                                                      fontWeight: FontWeight.w500,
                                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                    ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(context).alternate,
                                                    width: 2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0x00000000),
                                                    width: 2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(context).error,
                                                    width: 2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                focusedErrorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(context).error,
                                                    width: 2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                filled: true,
                                                fillColor: FlutterFlowTheme.of(context).alternate,
                                                contentPadding: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 20),
                                                prefixIcon: Icon(
                                                  Icons.perm_contact_cal_outlined,
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
                                              keyboardType: TextInputType.number,
                                              cursorColor: FlutterFlowTheme.of(context).primaryText,
                                              validator: _validateAge,
                                              autovalidateMode: _ageValidateMode,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: const AlignmentDirectional(-1, -1),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: MediaQuery.sizeOf(context).width,
                                                height: MediaQuery.sizeOf(context).height * 0.05,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(context).alternate,
                                                  borderRadius: BorderRadius.circular(35),
                                                  border: Border.all(
                                                    color: (_showGenderError && _formSubmitted)
                                                        ? FlutterFlowTheme.of(context).error
                                                        : Colors.transparent,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: FlutterFlowDropDown<String>(
                                                  controller: _model.genderDogOwnerMenuValueController ??=
                                                      FormFieldController<String>(
                                                    _model.genderDogOwnerMenuValue ?? '',
                                                  ),
                                                  options: const ['Macho', 'Hembra'],
                                                  optionLabels: const ['Macho', 'Hembra'],
                                                  onChanged: (val) {
                                                    safeSetState(() {
                                                      _model.genderDogOwnerMenuValue = val;
                                                      _showGenderError = false; // Oculta el error cuando se selecciona
                                                    });
                                                  },
                                                  width: MediaQuery.sizeOf(context).width,
                                                  height: MediaQuery.sizeOf(context).height * 0.05,
                                                  textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                        font: GoogleFonts.lexend(
                                                          fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                        ),
                                                        color: FlutterFlowTheme.of(context).primary,
                                                        fontSize: 16,
                                                        letterSpacing: 0.0,
                                                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                      ),
                                                  hintText: 'Género',
                                                  icon: Icon(
                                                    Icons.keyboard_arrow_down_rounded,
                                                    color: FlutterFlowTheme.of(context).primary,
                                                    size: 25,
                                                  ),
                                                  fillColor: FlutterFlowTheme.of(context).alternate,
                                                  elevation: 2,
                                                  borderColor: Colors.transparent,
                                                  borderWidth: 0,
                                                  borderRadius: 35,
                                                  margin: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                                                  hidesUnderline: true,
                                                  isOverButton: false,
                                                  isSearchable: false,
                                                  isMultiSelect: false, validator: (String? value) {  },
                                                ),
                                              ),
                                              if (_showGenderError && _formSubmitted)
                                                Padding(
                                                  padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 0, 0),
                                                  child: Text(
                                                    'Género es requerido',
                                                    style: TextStyle(
                                                      color: FlutterFlowTheme.of(context).error,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: const AlignmentDirectional(-1, -1),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                          child: Container(
                                            width: MediaQuery.sizeOf(context).width,
                                            child: TextFormField(
                                              controller: _model.breeInputTextController,
                                              focusNode: _model.breeInputFocusNode,
                                              autofocus: false,
                                              textInputAction: TextInputAction.next,
                                              obscureText: false,
                                              onChanged: (value) {
                                                if (_breedValidateMode == AutovalidateMode.disabled) {
                                                  setState(() {
                                                    _breedValidateMode = AutovalidateMode.always;
                                                  });
                                                }
                                              },
                                              decoration: InputDecoration(
                                                isDense: true,
                                                labelText: 'Raza',
                                                labelStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                                                        fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                      fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                                                      fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                    ),
                                                hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                      ),
                                                      fontSize: 16,
                                                      letterSpacing: 0.0,
                                                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                    ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(context).alternate,
                                                    width: 2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0x00000000),
                                                    width: 2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(context).error,
                                                    width: 2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                focusedErrorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(context).error,
                                                    width: 2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                filled: true,
                                                fillColor: FlutterFlowTheme.of(context).alternate,
                                                contentPadding: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 20),
                                                prefixIcon: Icon(
                                                  Icons.pets_outlined,
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
                                              cursorColor: FlutterFlowTheme.of(context).primaryText,
                                              validator: (value) => _validateRequired(value, 'Raza'),
                                              autovalidateMode: _breedValidateMode,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: MediaQuery.sizeOf(context).width,
                                              height: MediaQuery.sizeOf(context).height * 0.05,
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(context).alternate,
                                                borderRadius: BorderRadius.circular(35),
                                                border: Border.all(
                                                  color: (_showSizeError && _formSubmitted)
                                                      ? FlutterFlowTheme.of(context).error
                                                      : Colors.transparent,
                                                  width: 2,
                                                ),
                                              ),
                                              child: FlutterFlowDropDown<String>(
                                                controller: _model.dogSizeMenuValueController ??=
                                                    FormFieldController<String>(
                                                  _model.dogSizeMenuValue ?? '',
                                                ),
                                                options: const ['Chico', 'Mediano', 'Grande'],
                                                optionLabels: const ['Chico', 'Mediano', 'Grande'],
                                                onChanged: (val) {
                                                  safeSetState(() {
                                                    _model.dogSizeMenuValue = val;
                                                    _showSizeError = false; // Oculta el error cuando se selecciona
                                                  });
                                                },
                                                width: MediaQuery.sizeOf(context).width,
                                                height: MediaQuery.sizeOf(context).height * 0.05,
                                                textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                      ),
                                                      fontSize: 16,
                                                      letterSpacing: 0.0,
                                                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                    ),
                                                hintText: 'Tamaño',
                                                icon: Icon(
                                                  Icons.keyboard_arrow_down_rounded,
                                                  color: FlutterFlowTheme.of(context).primary,
                                                  size: 25,
                                                ),
                                                fillColor: FlutterFlowTheme.of(context).alternate,
                                                elevation: 2,
                                                borderColor: Colors.transparent,
                                                borderWidth: 0,
                                                borderRadius: 35,
                                                margin: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                                                hidesUnderline: true,
                                                isOverButton: false,
                                                isSearchable: false,
                                                isMultiSelect: false, validator: (String? value) {  },
                                              ),
                                            ),
                                            if (_showSizeError && _formSubmitted)
                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 0, 0),
                                                child: Text(
                                                  'Tamaño es requerido',
                                                  style: TextStyle(
                                                    color: FlutterFlowTheme.of(context).error,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                          ],
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
                                                if (_showBehaviourError && _formSubmitted)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 4.0),
                                                    child: Text(
                                                      'Selecciona al menos un comportamiento',
                                                      style: TextStyle(
                                                        color: FlutterFlowTheme.of(context).error,
                                                        fontSize: 12,
                                                      ),
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
                                          padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                          child: Container(
                                            width: MediaQuery.sizeOf(context).width,
                                            child: TextFormField(
                                              controller: _model.dogInfoInputTextController,
                                              focusNode: _model.dogInfoInputFocusNode,
                                              autofocus: false,
                                              obscureText: false,
                                              onChanged: (value) {
                                                if (_descriptionValidateMode == AutovalidateMode.disabled) {
                                                  setState(() {
                                                    _descriptionValidateMode = AutovalidateMode.always;
                                                  });
                                                }
                                              },
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
                                                    width: 2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0x00000000),
                                                    width: 2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(context).error,
                                                    width: 2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                focusedErrorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(context).error,
                                                    width: 2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                filled: true,
                                                fillColor: FlutterFlowTheme.of(context).alternate,
                                                contentPadding: const EdgeInsetsDirectional.fromSTEB(10, 20, 10, 20),
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
                                              validator: _validateDescription,
                                              autovalidateMode: _descriptionValidateMode,
                                            ),
                                          ),
                                        ),
                                      ),

                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                          child: FFButtonWidget(
                                            onPressed: () async {
                                              // Marcar que el formulario ha sido enviado y todos los campos como tocados
                                              setState(() {
                                                _formSubmitted = true;
                                                _nameTouched = true;
                                                _ageTouched = true;
                                                _breeTouched = true;
                                                _descriptionTouched = true;
                                              });
                                              
                                              // Validar campos de dropdown y choice chips
                                              final genderValid = _model.genderDogOwnerMenuValue != null && 
                                                                _model.genderDogOwnerMenuValue!.isNotEmpty;
                                              final sizeValid = _model.dogSizeMenuValue != null && 
                                                              _model.dogSizeMenuValue!.isNotEmpty;
                                              final behaviourValid = _model.behaviourChipsValues != null && 
                                                                    _model.behaviourChipsValues!.isNotEmpty;

                                              setState(() {
                                                _showGenderError = !genderValid;
                                                _showSizeError = !sizeValid;
                                                _showBehaviourError = !behaviourValid;
                                              });

                                              // Validar el formulario completo
                                              if (_formKey.currentState!.validate() && genderValid && sizeValid && behaviourValid) {
                                                try {
                                                  final supabase = Supabase.instance.client;
                                                  final userId = supabase.auth.currentUser?.id;

                                                  if (userId == null) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Usuario no autenticado')),
                                                    );
                                                    return;
                                                  }

                                                  final response = await supabase
                                                      .from('pets')
                                                      .insert({
                                                        'uuid': userId,
                                                        'name': _model.nameInputTextController.text.trim(),
                                                        'age': int.parse(_model.ageInputTextController.text),
                                                        'gender': _model.genderDogOwnerMenuValue,
                                                        'bree': _model.breeInputTextController.text.trim(),
                                                        'size': _model.dogSizeMenuValue,
                                                        'behaviour': _model.behaviourChipsValues,
                                                        'aboutme': _model.dogInfoInputTextController.text.trim(),
                                                      })
                                                      .select();

                                                  final petData = response.first;
                                                  final petId = petData['id'] as int;

                                                  String imageUrl =
                                                      'https://bsactypehgxluqyaymui.supabase.co/storage/v1/object/public/profile_pics/dog.png';

                                                  if (_ownerImage != null && userId != null) {
                                                    final uploadedUrl = await _uploadPetImage(context, userId, _ownerImage!, petId: petId);
                                                    if (uploadedUrl != null) imageUrl = uploadedUrl;
                                                  }

                                                  await supabase.from('pets').update({'photo_url': imageUrl}).eq('id', petId);

                                                  Navigator.pop(context);
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Error al registrar la mascota. Intenta de nuevo.')),
                                                  );
                                                }
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Por favor completa todos los campos correctamente')),
                                                );
                                              }
                                            },
                                            text: 'Agregar Mascota',
                                            options: FFButtonOptions(
                                              width: MediaQuery.sizeOf(context).width,
                                              height: MediaQuery.sizeOf(context).height * 0.05,
                                              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                              iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                              color: FlutterFlowTheme.of(context).accent1,
                                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                    font: GoogleFonts.lexend(
                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                    ),
                                                    color: Colors.white,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                    fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
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
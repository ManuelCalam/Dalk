import 'package:dalk/backend/supabase/database/database.dart';
import 'package:flutter/services.dart';

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
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '/utils/validation.dart';


import 'pet_update_profile_model.dart';
export 'pet_update_profile_model.dart';

class PetUpdateProfileWidget extends StatefulWidget {
  final Map<String, dynamic>? petData;

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  // Variables para controlar la validación individual de cada campo
  bool _nameTouched = false;
  bool _ageTouched = false;
  bool _raceTouched = false;
  bool _descriptionTouched = false;

  AutovalidateMode _nameValidateMode = AutovalidateMode.disabled;
  AutovalidateMode _ageValidateMode = AutovalidateMode.disabled;
  AutovalidateMode _breedValidateMode = AutovalidateMode.disabled;
  AutovalidateMode _descriptionValidateMode = AutovalidateMode.disabled;

  bool _showGenderError = false;
  bool _showSizeError = false;
  bool _showBehaviourError = false;
  bool _formSubmitted = false;

  // Funciones de validación
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

  String? _validateRaceConditional(String? value) {
    if (!_raceTouched && !_formSubmitted) return null;
    return _validateRequired(value, 'Raza');
  }

  String? _validateDescriptionConditional(String? value) {
    if (!_descriptionTouched && !_formSubmitted) return null;
    return _validateDescription(value);
  }

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

    // ---- Text controllers con listeners de focus ----
    _model.nameInputTextController ??=
        TextEditingController(text: pet['name'] ?? '');
    _model.nameInputFocusNode ??= FocusNode()
      ..addListener(() {
        if (_model.nameInputFocusNode != null && !_model.nameInputFocusNode!.hasFocus) {
          setState(() {
            _nameTouched = true;
          });
        }
      });

    _model.ageInputTextController ??=
        TextEditingController(text: pet['age']?.toString() ?? '');
    _model.ageInputFocusNode ??= FocusNode()
      ..addListener(() {
        if (_model.ageInputFocusNode != null && !_model.ageInputFocusNode!.hasFocus) {
          setState(() {
            _ageTouched = true;
          });
        }
      });

    _model.raceInputTextController ??=
        TextEditingController(text: pet['bree'] ?? '');
    _model.raceInputFocusNode ??= FocusNode()
      ..addListener(() {
        if (_model.raceInputFocusNode != null && !_model.raceInputFocusNode!.hasFocus) {
          setState(() {
            _raceTouched = true;
          });
        }
      });

    _model.dogInfoInputTextController ??=
        TextEditingController(text: pet['aboutme'] ?? '');
    _model.dogInfoInputFocusNode ??= FocusNode()
      ..addListener(() {
        if (_model.dogInfoInputFocusNode != null && !_model.dogInfoInputFocusNode!.hasFocus) {
          setState(() {
            _descriptionTouched = true;
          });
        }
      });
    
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
    setState(() {
      _formSubmitted = true;
      _nameTouched = true;
      _ageTouched = true;
      _raceTouched = true;
      _descriptionTouched = true;
    });
    
    // Validar campos de dropdown y choice chips
    final genderValid = _model.genderDogOwnerMenuValue != null && 
                      _model.genderDogOwnerMenuValue!.isNotEmpty;
    final sizeValid = _model.dogSizeMenuValue != null && 
                    _model.dogSizeMenuValue!.isNotEmpty;
    final behaviourValid = _model.behaviourChipsValues != null && 
                        _model.behaviourChipsValues!.isNotEmpty;
    
    // Validar imagen: debe existir una imagen previa O una nueva imagen seleccionada
    final imageValid = (_petImage != null) || 
                      (widget.petData?['photo_url'] != null && 
                      (widget.petData?['photo_url'] as String).isNotEmpty &&
                      widget.petData?['photo_url'] != 'https://static.vecteezy.com/system/resources/previews/007/407/996/non_2x/user-icon-person-icon-client-symbol-login-head-sign-icon-design-vector.jpg');

    setState(() {
      _showGenderError = !genderValid;
      _showSizeError = !sizeValid;
      _showBehaviourError = !behaviourValid;
    });

    // Validar el formulario completo
    if (_formKey.currentState!.validate() && genderValid && sizeValid && behaviourValid) {
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

        String? imageUrl;
        if (_petImage  != null) {
          imageUrl = await _uploadPetImage(userId, _petImage !, petId: petId);
          if (imageUrl != null && imageUrl.isNotEmpty) {
            payload['photo_url'] = imageUrl;
          }
        }

        print(' Enviando actualización para ID: $petId');
        print(' Payload: $payload');

        final response = await supabase
            .from('pets')
            .update(payload)
            .eq('id', petId)
            .select();

        print('Supabase response: $response');

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
            const SnackBar(content: Text('Datos actualizados correctamente')),
          );
        } else {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No se pudo actualizar la mascota (sin coincidencias)')),
          );
        }
      } catch (e) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos correctamente')),
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
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Align(
                                          alignment: const AlignmentDirectional(0, 0),
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
                                                      color: FlutterFlowTheme.of(context).primary
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
                                                  validator: (value) {
                                                    final required = Validators.requiredField(value, fieldName: 'Nombre');
                                                    if (required != null) return required;
                                                    final min = Validators.minLength(value, 3, fieldName: 'Nombre');
                                                    if (min != null) return min;
                                                    return Validators.maxLength(value, 30, fieldName: 'Nombre');
                                                  },                                                  
                                                  inputFormatters: [
                                                    LengthLimitingTextInputFormatter(30),
                                                  ],                                              
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
                                                      color: FlutterFlowTheme.of(context).primary
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
                                              keyboardType: TextInputType.number,  // Cambiado a number
                                              cursorColor: FlutterFlowTheme.of(context).primaryText,
                                              validator: _validateAge,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly,  // Solo permite dígitos
                                                LengthLimitingTextInputFormatter(2),  // Máximo 2 dígitos
                                              ],   
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
                                                      _showGenderError = false; 
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
                                                  isMultiSelect: false,
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
                                              controller: _model.raceInputTextController,
                                              focusNode: _model.raceInputFocusNode,
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
                                                      color: FlutterFlowTheme.of(context).primary
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
                                              validator: (value) {
                                                final required = Validators.requiredField(value, fieldName: 'Raza');
                                                  if (required != null) return required;
                                                  final min = Validators.minLength(value, 3, fieldName: 'Raza');
                                                  if (min != null) return min;
                                                  return Validators.maxLength(value, 20, fieldName: 'Raza');
                                                },                                                  
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(20),
                                                ],   
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
                                                isMultiSelect: false,
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
                                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: (_showBehaviourError && _formSubmitted)
                                                          ? FlutterFlowTheme.of(context).error
                                                          : Colors.transparent,
                                                      width: 2,
                                                    ),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Align(
                                                    alignment: const AlignmentDirectional(0, 0),
                                                    child: FlutterFlowChoiceChips(
                                                      options: [
                                                        const ChipData('Sociable con otros perros'),
                                                        const ChipData('Nervioso'),
                                                        const ChipData('Tranquilo'),
                                                        const ChipData('Obediente'),
                                                        const ChipData('Energético'),
                                                        const ChipData('Tira de la correa'),
                                                        const ChipData('No se lleva con otros perros'),
                                                        const ChipData('Amigable con personas'),
                                                      ],

                                                      //  Solo un controller
                                                      controller: _model.behaviourChipsValueController ??=
                                                          FormFieldController<List<String>>(
                                                            selectedBehaviours?.toList() ?? [],
                                                          ),

                                                      //  Solo un multiselect
                                                      multiselect: true,

                                                      onChanged: (val) {
                                                        setState(() {
                                                          selectedBehaviours = val?.toSet() ?? {};
                                                          _showBehaviourError = false; // Oculta el error cuando se selecciona
                                                        });
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
                                                        labelPadding: const EdgeInsets.all(5),
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
                                                        labelPadding: const EdgeInsets.all(5),
                                                        elevation: 0,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      chipSpacing: 2,
                                                      rowSpacing: 5,
                                                      initialized: _model.behaviourChipsValues != null,
                                                      alignment: WrapAlignment.center,
                                                      wrapped: true,
                                                    ),
                                                  ),
                                                ),
                                                if (_showBehaviourError && _formSubmitted)
                                                  Padding(
                                                    padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 0, 0),
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
                                      Padding(
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
                                              validator: (value) {
                                                final required = Validators.requiredField(value, fieldName: 'Acerca de');
                                                  if (required != null) return required;
                                                  final min = Validators.minLength(value, 10, fieldName: 'Acerca de');
                                                  if (min != null) return min;
                                                  return Validators.maxLength(value, 150, fieldName: 'Acerca de');
                                                },                                                  
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(150),
                                                ],                                              
                                                autovalidateMode: _descriptionValidateMode,
                                            ),
                                          ),
                                        ),
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(
                                              0, 18, 0, 0),
                                          child: FFButtonWidget(
                                            onPressed: () async {
                                              await _saveChanges();
                                            },
                                            text: _isSaving ? 'Guardando...' : 'Guardar',
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
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/go_back_container/go_back_container_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '/utils/validation.dart';
import 'sing_in_dog_walker_model.dart';
export 'sing_in_dog_walker_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dalk/services/zipCode_service.dart';
import 'package:dalk/services/image_permission_service.dart';
import 'dart:io';

class SingInDogWalkerWidget extends StatefulWidget {
  const SingInDogWalkerWidget({
    required this.registerMethod,
    super.key
    });

  final String registerMethod;

  static String routeName = 'singInDogWalker';
  static String routePath = '/singInDogWalker';

  @override
  State<SingInDogWalkerWidget> createState() => _SingInDogWalkerWidgetState();
}

class _SingInDogWalkerWidgetState extends State<SingInDogWalkerWidget> {
  late SingInDogWalkerModel _model;
  File? _ownerImage;
  File? _walkerImage;
  final ImagePicker _picker = ImagePicker();
  final ImagePermissionService _permissionService = ImagePermissionService();

  List<String> _availableNeighborhoods = [];
  bool _isLoadingPostalCode = false;
  String? _selectedNeighborhood;
  bool _postalCodeValidated = false;
  bool _showCustomNeighborhoodInput = false;
  bool _showGenderError = false;

  bool validarCamposObligatorios() {
    return _model.emailDogWalkerInputTextController.text.trim().isNotEmpty &&
          _model.passDogWalkerInputTextController.text.trim().isNotEmpty &&
          _model.nameDogWalkerInputTextController.text.trim().isNotEmpty &&
          _model.phoneDogWalkerInputTextController.text.trim().isNotEmpty &&
          _model.genderDogWalkerMenuValue != null &&
          _model.streetDogWalkerInputTextController.text.trim().isNotEmpty &&
          _model.exteriorNumberDogWalkerTextController.text.trim().isNotEmpty &&
          _model.zipCodeDogWalkerInputTextController.text.trim().isNotEmpty &&
          _postalCodeValidated && 
          _selectedNeighborhood != null && 
          _model.cityDogWalkerInputTextController.text.trim().isNotEmpty;
  }

  String? _validateGender(String? value) {
  if (value == null || value.isEmpty) {
    return 'Selecciona tu género';
  }
  return null;
}

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isRegistering = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SingInDogWalkerModel());

    _model.nameDogWalkerInputTextController ??= TextEditingController();
    _model.nameDogWalkerInputFocusNode ??= FocusNode();

    _model.emailDogWalkerInputTextController ??= TextEditingController();
    _model.emailDogWalkerInputFocusNode ??= FocusNode();

    _model.phoneDogWalkerInputTextController ??= TextEditingController();
    _model.phoneDogWalkerInputFocusNode ??= FocusNode();

    _model.streetDogWalkerInputTextController ??= TextEditingController();
    _model.streetDogWalkerInputFocusNode ??= FocusNode();

    _model.interiorNumberDogWalkerInputTextController ??= TextEditingController();
    _model.interiorNumberDogWalkerInputFocusNode ??= FocusNode();

    _model.exteriorNumberDogWalkerTextController ??= TextEditingController();
    _model.exteriorNumberDogWalkerFocusNode ??= FocusNode();

    _model.zipCodeDogWalkerInputTextController ??= TextEditingController();
    _model.zipCodeDogWalkerInputFocusNode ??= FocusNode();
    _model.zipCodeDogWalkerInputTextController!.addListener(_onPostalCodeChanged);

    _model.neighborhoodDogWalkerInputTextController ??= TextEditingController();
    _model.neighborhoodDogWalkerInputFocusNode ??= FocusNode();

    _model.cityDogWalkerInputTextController ??= TextEditingController();
    _model.cityDogWalkerInputFocusNode ??= FocusNode();

    _model.passDogWalkerInputTextController ??= TextEditingController();
    _model.passDogWalkerInputFocusNode ??= FocusNode();

    _model.confirmPassDogWalkerInputTextController ??= TextEditingController();
    _model.confirmPassDogWalkerInputFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.zipCodeDogWalkerInputTextController?.removeListener(_onPostalCodeChanged);
    _model.dispose();
    super.dispose();
  }

Future<void> registerDogWalker(BuildContext context, String windowOrigin) async {
  final supabase = Supabase.instance.client;

  try {
    String? userId;
    String? userEmail;

    if (windowOrigin == 'email') {
      final user = await authManager.createAccountWithEmail(
        context,
        _model.emailDogWalkerInputTextController.text.trim(),
        _model.passDogWalkerInputTextController.text.trim(),
      );
      if (user == null) throw Exception('No se pudo crear el usuario.');
      userId = user.uid;
      userEmail = _model.emailDogWalkerInputTextController.text.trim();
    }

    else if (windowOrigin == 'google') {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No se encontró sesión de Google.');
      userId = user.id;
      userEmail = user.email;
    } else {
      throw Exception('Origen de registro no válido: $windowOrigin');
    }

    if (userId == null || userEmail == null) {
      throw Exception('Error: datos de usuario incompletos.');
    }

    if (windowOrigin == 'email') {
      await supabase.from('users').insert({
        'uuid': userId,
        'name': _model.nameDogWalkerInputTextController.text.trim(),
        'email': userEmail,
        'phone': _model.phoneDogWalkerInputTextController.text.trim(),
        'birthdate': supaSerialize<DateTime>(_model.datePicked),
        'gender': _model.genderDogWalkerMenuValue,
        'address': _model.streetDogWalkerInputTextController.text.trim(),
        'ext_number': _model.exteriorNumberDogWalkerTextController.text.trim(),
        'int_number': _model.interiorNumberDogWalkerInputTextController.text.trim(),
        'zipCode': _model.zipCodeDogWalkerInputTextController.text.trim(),
        'neighborhood': _model.neighborhoodDogWalkerInputTextController.text.trim(),
        'city': _model.cityDogWalkerInputTextController.text.trim(),
        'usertype': 'Paseador',
      });
    } else if (windowOrigin == 'google') {
      await supabase.from('users').update({
        'name': _model.nameDogWalkerInputTextController.text.trim(),
        'phone': _model.phoneDogWalkerInputTextController.text.trim(),
        'birthdate': supaSerialize<DateTime>(_model.datePicked),
        'gender': _model.genderDogWalkerMenuValue,
        'address': _model.streetDogWalkerInputTextController.text.trim(),
        'ext_number': _model.exteriorNumberDogWalkerTextController.text.trim(),
        'int_number': _model.interiorNumberDogWalkerInputTextController.text.trim(),
        'zipCode': _model.zipCodeDogWalkerInputTextController.text.trim(),
        'neighborhood': _model.neighborhoodDogWalkerInputTextController.text.trim(),
        'city': _model.cityDogWalkerInputTextController.text.trim(),
        'usertype': 'Paseador',
      }).eq('uuid', userId);
    }

    await supabase.from('addresses').insert({
      'uuid': userId,
      'alias': 'Mi Dirección',
      'address': _model.streetDogWalkerInputTextController.text.trim(),
      'ext_number': _model.exteriorNumberDogWalkerTextController.text.trim(),
      'int_number': _model.interiorNumberDogWalkerInputTextController.text.trim(),
      'zipCode': _model.zipCodeDogWalkerInputTextController.text.trim(),
      'neighborhood': _model.neighborhoodDogWalkerInputTextController.text.trim(),
      'city': _model.cityDogWalkerInputTextController.text.trim(),
    });

    String imageUrl;
    if (_ownerImage != null) {
      final uploadedUrl = await _uploadOwnerImage(userId!, _ownerImage!);
      imageUrl = uploadedUrl ??
          supabase.storage.from('profile_pics').getPublicUrl('user.png');
    } else {
      imageUrl = supabase.storage.from('profile_pics').getPublicUrl('user.png');
    }

    await supabase.from('users').update({'photo_url': imageUrl}).eq('uuid', userId!);

    final verify = await supabase
        .from('users')
        .select('uuid')
        .eq('uuid', userId)
        .maybeSingle();

    if (verify == null) throw Exception('Error al verificar registro.');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Registro completado correctamente!')),
    );

    context.pushReplacement('/');

  } on AuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error de autenticación: ${e.message}')),
    );
  } on PostgrestException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error en base de datos: ${e.message}')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error durante el registro: $e')),
    );
  }
}

// NUEVA FUNCIÓN PARA VALIDAR CP AUTOMÁTICAMENTE
  void _onPostalCodeChanged() async {
    final postalCode = _model.zipCodeDogWalkerInputTextController!.text.trim();

    if (postalCode.length != 5) {
      if (_postalCodeValidated) {
        setState(() {
          _postalCodeValidated = false;
          _availableNeighborhoods = [];
          _selectedNeighborhood = null;
          _showCustomNeighborhoodInput = false;
          _model.neighborhoodDogWalkerInputTextController?.clear();
          _model.cityDogWalkerInputTextController?.clear();
        });
      }
      return;
    }

    setState(() => _isLoadingPostalCode = true);

    try {
      final geoService = ZipCodeService();
      final postalInfo = await geoService.getPostalCodeInfo(postalCode);

      if (!mounted) return;

      if (postalInfo.isValid) {
        setState(() {
          _postalCodeValidated = true;
          // Agregar "Otra" al final de las opciones
          _availableNeighborhoods = [...postalInfo.neighborhoods, 'Otra'];
          _selectedNeighborhood = null;
          _showCustomNeighborhoodInput = false;
          
          // Auto-completar ciudad (pero ahora será editable)
          _model.cityDogWalkerInputTextController?.text = postalInfo.city;
          
          // Limpiar colonia anterior
          _model.neighborhoodDogWalkerInputTextController?.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Código postal válido. ${postalInfo.neighborhoods.length} colonia(s) encontrada(s).'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          _postalCodeValidated = false;
          _availableNeighborhoods = [];
          _selectedNeighborhood = null;
          _showCustomNeighborhoodInput = false;
          _model.neighborhoodDogWalkerInputTextController?.clear();
          _model.cityDogWalkerInputTextController?.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código postal no válido o no pertenece a Jalisco.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error validando código postal: $e');
      if (mounted) {
        setState(() {
          _postalCodeValidated = false;
          _availableNeighborhoods = [];
          _showCustomNeighborhoodInput = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingPostalCode = false);
      }
    }
  }


  Future<String?> _uploadOwnerImage(String userId, File imageFile) async {
    try {
      final fileSize = await imageFile.length();
      const maxSize = 5 * 1024 * 1024;

      if (fileSize > maxSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La imagen supera el tamaño máximo permitido (5 MB).'),
          ),
        );
        return null;
      }


      final filePath = 'owners/$userId/profile.jpg';
      final storage = Supabase.instance.client.storage;

      // Subir la imagen, si existe reemplazar
      await storage.from('profile_pics').upload(
        filePath,
        imageFile,
        fileOptions: const FileOptions(upsert: true),
      );

      // Obtener URL pública
      final imageUrl = storage.from('profile_pics').getPublicUrl(filePath);
      print('Imagen subida: $imageUrl');
      return imageUrl; // ahora es un String
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  //funcion para seleccionar imagen
  Future<void> _pickImage(bool isOwner, ImageSource source) async {
    XFile? pickedFile;
    
    if (source == ImageSource.camera) {
      pickedFile = await _permissionService.pickImageFromCamera(context);
    } else {
      pickedFile = await _permissionService.pickImageFromGallery(context);
    }
    
    if (pickedFile != null) {
      setState(() {
        if (isOwner) {
          _ownerImage = File(pickedFile!.path);
        } else {
          _walkerImage = File(pickedFile!.path);
        }
      });
    }
  }

  void _showImagePickerOptions(BuildContext context, bool isOwner) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador visual
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Título
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Selecciona una opción',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
              // Opción de cámara
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                ),
                title: const Text('Tomar foto'),
                subtitle: const Text('Usa la cámara de tu dispositivo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(isOwner, ImageSource.camera);
                },
              ),
              const Divider(height: 1),
              // Opción de galería
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                ),
                title: const Text('Elegir de la galería'),
                subtitle: const Text('Selecciona una foto existente'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(isOwner, ImageSource.gallery);
                },
              ),
              const Divider(height: 1),
              // Opción de cancelar
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.cancel,
                    color: Colors.grey,
                  ),
                ),
                title: const Text('Cancelar'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
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
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: MediaQuery.sizeOf(context).height * 0.1,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0),
                  topLeft: Radius.circular(0.0),
                  topRight: Radius.circular(0.0),
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.sizeOf(context).width * 1.0,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).tertiary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(0.0),
                    bottomRight: Radius.circular(0.0),
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
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
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 15.0),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.9,
                          decoration: const BoxDecoration(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                decoration: const BoxDecoration(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Paseador',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.lexend(
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            fontSize: 32.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 5.0, 0.0, 0.0),
                                      child: Text(
                                        '¡Registrate como paseador',
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context)
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .accent1,
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
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                              alignment: const AlignmentDirectional(0, 0),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                                child: GestureDetector(
                                  onTap: () => _showImagePickerOptions(context, true), // true = dueño
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundImage: _ownerImage != null
                                    ? FileImage(_ownerImage!)
                                    : const AssetImage('assets/images/user.png') as ImageProvider,
                                  ),
                                ),
                              ),
                            ),
                            Text('Presiona para elegir una foto', style: FlutterFlowTheme.of(context).bodyMedium.override()),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                  child: Container(
                                    width: MediaQuery.sizeOf(context).width,
                                    decoration: const BoxDecoration(),
                                    child: Container(
                                      width:
                                          MediaQuery.sizeOf(context).width * 0.6,
                                      child: Form(
                                        key: _model.formKey,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 7, 0, 0),
                                                child: Container(
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                          .width,
                                                  child: TextFormField(
                                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                                    controller: _model
                                                        .nameDogWalkerInputTextController,
                                                    focusNode: _model
                                                        .nameDogWalkerInputFocusNode,
                                                    autofocus: false,
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      labelText: 'Nombre',
                                                      labelStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .override(
                                                                font: GoogleFonts
                                                                    .lexend(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyLarge
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyLarge
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme
                                                                        .of(context)
                                                                    .primary,
                                                                fontSize: 16,
                                                                letterSpacing:
                                                                    0.0,
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
                                                      hintStyle: FlutterFlowTheme
                                                              .of(context)
                                                          .labelMedium
                                                          .override(
                                                            font: GoogleFonts
                                                                .lexend(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                            ),
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            fontSize: 16,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .alternate,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: const BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .error,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .error,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate,
                                                      contentPadding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  10, 0, 0, 20),
                                                      prefixIcon: Icon(
                                                        Icons.person,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        size: 25,
                                                      ),
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.lexend(
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
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primaryText,
                                                    validator: (value) {
                                                      final required = Validators.requiredField(value, fieldName: 'Nombre');
                                                      if (required != null) return required;
                                                      final min = Validators.minLength(value, 3, fieldName: 'Nombre');
                                                      if (min != null) return min;
                                                      return Validators.maxLength(value, 50, fieldName: 'Nombre');
                                                    },                                                  
                                                    inputFormatters: [
                                                      LengthLimitingTextInputFormatter(50),
                                                    ],                                                
                                                  ),
                                                ),
                                              ),
                                              if(widget.registerMethod == 'email')
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 18, 0, 0),
                                                child: Container(
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                          .width,
                                                  child: TextFormField(
                                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                                    controller: _model
                                                        .emailDogWalkerInputTextController,
                                                    focusNode: _model
                                                        .emailDogWalkerInputFocusNode,
                                                    autofocus: false,
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      labelText: 'Correo',
                                                      labelStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .override(
                                                                font: GoogleFonts
                                                                    .lexend(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyLarge
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyLarge
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme
                                                                        .of(context)
                                                                    .primary,
                                                                fontSize: 16,
                                                                letterSpacing:
                                                                    0.0,
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
                                                      hintStyle: FlutterFlowTheme
                                                              .of(context)
                                                          .labelMedium
                                                          .override(
                                                            font: GoogleFonts
                                                                .lexend(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                            ),
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            fontSize: 16,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .alternate,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: const BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .error,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .error,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate,
                                                      contentPadding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  10, 0, 0, 20),
                                                      prefixIcon: Icon(
                                                        Icons.alternate_email,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        size: 25,
                                                      ),
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.lexend(
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
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primaryText,
                                                    validator: (value) {
                                                        final required = Validators.requiredField(value, fieldName: 'Correo');
                                                        if (required != null) return required;
                                                        final min = Validators.minLength(value, 5, fieldName: 'Correo');
                                                        if (min != null) return min;
                                                        final max = Validators.maxLength(value, 100, fieldName: 'Correo');
                                                        if (max != null) return max;
                                                        return Validators.email(value);
                                                      },                                                
                                                    ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 18, 0, 0),
                                                child: Container(
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                          .width,
                                                  child: TextFormField(
                                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                                    controller: _model
                                                        .phoneDogWalkerInputTextController,
                                                    focusNode: _model
                                                        .phoneDogWalkerInputFocusNode,
                                                    autofocus: false,
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      labelText: 'Telefono',
                                                      labelStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .override(
                                                                font: GoogleFonts
                                                                    .lexend(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyLarge
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyLarge
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme
                                                                        .of(context)
                                                                    .primary,
                                                                fontSize: 16,
                                                                letterSpacing:
                                                                    0.0,
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
                                                      hintStyle: FlutterFlowTheme
                                                              .of(context)
                                                          .labelMedium
                                                          .override(
                                                            font: GoogleFonts
                                                                .lexend(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                            ),
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            fontSize: 16,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .alternate,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: const BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .error,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .error,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate,
                                                      contentPadding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0, 0, 0, 20),
                                                      prefixIcon: Icon(
                                                        Icons.phone,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        size: 25,
                                                      ),
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.lexend(
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
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primaryText,
                                                    validator: (value) => Validators.phone(value),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .allow(RegExp(
                                                              '[0-9]'))
                                                    ],
                                                    keyboardType:
                                                        TextInputType.phone,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 18, 0, 0),
                                                child: InkWell(
                                                  splashColor: Colors.transparent,
                                                  focusColor: Colors.transparent,
                                                  hoverColor: Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    final now = DateTime.now();
                                                    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);

                                                    final _datePickedDate =
                                                      await showDatePicker( context: context,
                                                      initialDate: eighteenYearsAgo, 
                                                      firstDate: DateTime(1900), 
                                                      lastDate: eighteenYearsAgo, 
                                                      locale: const Locale('es', 'ES'),
                                                      builder: (context, child) {
                                                        return wrapInMaterialDatePickerTheme(
                                                          context,
                                                          child!,
                                                          headerBackgroundColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                          headerForegroundColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .info,
                                                          headerTextStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .headlineLarge
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .lexend(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .headlineLarge
                                                                          .fontStyle,
                                                                    ),
                                                                    fontSize: 32,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .headlineLarge
                                                                        .fontStyle,
                                                                  ),
                                                          pickerBackgroundColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .alternate,
                                                          pickerForegroundColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primaryText,
                                                          selectedDateTimeBackgroundColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                          selectedDateTimeForegroundColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .info,
                                                          actionButtonForegroundColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primaryText,
                                                          iconSize: 24,
                                                        );
                                                      },
                                                    );

                                                    if (_datePickedDate != null) {
                                                      safeSetState(() {
                                                        _model.datePicked =
                                                            DateTime(
                                                          _datePickedDate.year,
                                                          _datePickedDate.month,
                                                          _datePickedDate.day,
                                                        );
                                                      });
                                                    } else if (_model
                                                            .datePicked !=
                                                        null) {
                                                      safeSetState(() {
                                                        _model.datePicked =
                                                            getCurrentTimestamp;
                                                      });
                                                    }
                                                  },
                                                  child: Container(
                                                    width:
                                                        MediaQuery.sizeOf(context)
                                                            .width,
                                                    height:
                                                        MediaQuery.sizeOf(context)
                                                                .height *
                                                            0.05,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme.of(
                                                              context)
                                                          .alternate,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      8, 0, 0, 0),
                                                          child: Icon(
                                                            Icons.calendar_month,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            size: 25,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      7, 0, 0, 0),
                                                          child: AutoSizeText(
                                                            _model.datePicked == null
                                                            ? 'Fecha de nacimiento\n'
                                                            : '${_model.datePicked!.day}/${_model.datePicked!.month}/${_model.datePicked!.year}',
                                                            textAlign:
                                                                TextAlign.start,
                                                            maxLines: 1,
                                                            minFontSize: 12,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font:
                                                                      GoogleFonts
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
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  fontSize: 16,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
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
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(30),
                                                        border: _showGenderError
                                                            ? Border.all(
                                                                color: FlutterFlowTheme.of(context).error,
                                                                width: 2,
                                                              )
                                                            : null,
                                                      ),
                                                      child: FlutterFlowDropDown<String>(
                                                        controller: _model.genderDogWalkerMenuValueController ??=
                                                            FormFieldController<String>(
                                                          _model.genderDogWalkerMenuValue ?? '',
                                                        ),
                                                        options: List<String>.from(['Hombre', 'Mujer', 'Otro']),
                                                        optionLabels: ['Hombre', 'Mujer', 'Otro'],
                                                        onChanged: (val) {
                                                          safeSetState(() {
                                                            _model.genderDogWalkerMenuValue = val;
                                                            _showGenderError = false; // 🔑 Ocultar error al seleccionar
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
                                                        borderRadius: 30,
                                                        margin: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                                                        hidesUnderline: true,
                                                        isOverButton: false,
                                                        isSearchable: false,
                                                        isMultiSelect: false,
                                                      ),
                                                    ),
                                                    if (_showGenderError)
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                                                        child: Text(
                                                          'Selecciona tu género',
                                                          style: TextStyle(
                                                            color: FlutterFlowTheme.of(context).error,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 18, 0, 0),
                                                child: Container(
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                          .width,
                                                  child: TextFormField(
                                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                                    controller: _model
                                                        .streetDogWalkerInputTextController,
                                                    focusNode: _model
                                                        .streetDogWalkerInputFocusNode,
                                                    autofocus: false,
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      labelText: 'Calle',
                                                      labelStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .override(
                                                                font: GoogleFonts
                                                                    .lexend(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyLarge
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyLarge
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme
                                                                        .of(context)
                                                                    .primary,
                                                                fontSize: 16,
                                                                letterSpacing:
                                                                    0.0,
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
                                                      hintStyle: FlutterFlowTheme
                                                              .of(context)
                                                          .labelMedium
                                                          .override(
                                                            font: GoogleFonts
                                                                .lexend(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                            ),
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            fontSize: 16,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .alternate,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: const BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .error,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .error,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                30),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate,
                                                      contentPadding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0, 0, 0, 20),
                                                      prefixIcon: Icon(
                                                        Icons.home_rounded,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        size: 25,
                                                      ),
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.lexend(
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
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primaryText,
                                                    validator: (value) {
                                                      final required = Validators.requiredField(value, fieldName: 'Calle');
                                                      if (required != null) return required;
                                                      final min = Validators.minLength(value, 5, fieldName: 'Calle');
                                                      if (min != null) return min;
                                                      return Validators.maxLength(value, 50, fieldName: 'Calle');
                                                    },                                                  
                                                    inputFormatters: [
                                                      LengthLimitingTextInputFormatter(50),
                                                    ],  
                                                  ),
                                                ),
                                              ),

                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                                child: Container(
                                                  width: MediaQuery.sizeOf(context).width,
                                                  child: TextFormField(
                                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                                    controller: _model.zipCodeDogWalkerInputTextController,
                                                    focusNode: _model.zipCodeDogWalkerInputFocusNode,
                                                    autofocus: false,
                                                    textInputAction: TextInputAction.next,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      labelText: 'Código postal',
                                                      labelStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                                                        font: GoogleFonts.lexend(
                                                          fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                                                          fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                        ),
                                                        color: FlutterFlowTheme.of(context).primary,
                                                        fontSize: 16,
                                                        letterSpacing: 0.0,
                                                      ),
                                                      hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                        font: GoogleFonts.lexend(
                                                          fontWeight: FontWeight.bold,
                                                          fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                        ),
                                                        color: FlutterFlowTheme.of(context).primary,
                                                        fontSize: 16,
                                                        letterSpacing: 0.0,
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
                                                      contentPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                                                      prefixIcon: Icon(
                                                        Icons.location_on,
                                                        color: FlutterFlowTheme.of(context).primary,
                                                        size: 25,
                                                      ),
                                                      // AGREGAR INDICADOR DE CARGA
                                                      suffixIcon: _isLoadingPostalCode
                                                          ? Padding(
                                                              padding: const EdgeInsets.all(12.0),
                                                              child: SizedBox(
                                                                width: 20,
                                                                height: 20,
                                                                child: CircularProgressIndicator(
                                                                  strokeWidth: 2,
                                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                                    FlutterFlowTheme.of(context).primary,
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : _postalCodeValidated
                                                              ? Icon(
                                                                  Icons.check_circle,
                                                                  color: Colors.green,
                                                                  size: 25,
                                                                )
                                                              : null,
                                                    ),
                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      font: GoogleFonts.lexend(
                                                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                      ),
                                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                                      fontSize: 16,
                                                      letterSpacing: 0.0,
                                                    ),
                                                    keyboardType: TextInputType.number,
                                                    cursorColor: FlutterFlowTheme.of(context).primaryText,
                                                    validator: (value) => Validators.postalCode(value),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                                      LengthLimitingTextInputFormatter(5),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                                child: Container(
                                                  // height:
                                                  //     MediaQuery.sizeOf(context)
                                                  //             .height *
                                                  //         0.05,
                                                  decoration: const BoxDecoration(),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                                                          child: Container(
                                                            width: 350,
                                                            child: TextFormField(
                                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                                              controller: _model
                                                                  .exteriorNumberDogWalkerTextController,
                                                              focusNode: _model
                                                                  .exteriorNumberDogWalkerFocusNode,
                                                              autofocus: false,
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              obscureText: false,
                                                              decoration:
                                                                  InputDecoration(
                                                                isDense: true,
                                                                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                                                                labelText: 'Ext',
                                                                labelStyle:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .override(
                                                                          font: GoogleFonts
                                                                              .lexend(
                                                                            fontWeight: FlutterFlowTheme.of(context)
                                                                                .labelMedium
                                                                                .fontWeight,
                                                                            fontStyle: FlutterFlowTheme.of(context)
                                                                                .labelMedium
                                                                                .fontStyle,
                                                                          ),
                                                                          color: FlutterFlowTheme.of(context)
                                                                              .primary,
                                                                          fontSize:
                                                                              16,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                hintStyle:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .override(
                                                                          font: GoogleFonts
                                                                              .lexend(
                                                                            fontWeight: FlutterFlowTheme.of(context)
                                                                                .labelMedium
                                                                                .fontWeight,
                                                                            fontStyle: FlutterFlowTheme.of(context)
                                                                                .labelMedium
                                                                                .fontStyle,
                                                                          ),
                                                                          color: FlutterFlowTheme.of(context)
                                                                              .primary,
                                                                          fontSize:
                                                                              16,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      const BorderSide(
                                                                    color: Color(
                                                                        0x00000000),
                                                                    width: 1,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                ),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      const BorderSide(
                                                                    color: Color(
                                                                        0x00000000),
                                                                    width: 1,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                ),
                                                                errorBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .error,
                                                                    width: 1,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                ),
                                                                focusedErrorBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .error,
                                                                    width: 1,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                ),
                                                                filled: true,
                                                                fillColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .alternate,
                                                                prefixIcon: Icon(
                                                                  Icons
                                                                      .numbers_sharp,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  size: 25,
                                                                ),
                                                              ),
                                                              style: FlutterFlowTheme
                                                                      .of(context)
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
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                    fontSize: 16,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              cursorColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,

                                                              validator: (value) => Validators.requiredField(value, fieldName: 'No. exterior'),
                                                              inputFormatters: 
                                                                [
                                                                  FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                                                  LengthLimitingTextInputFormatter(7)
                                                                ], 
                                                            ),
                                                            
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                            const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                                                          child: Container(
                                                            width: 350,
                                                            child: TextFormField(
                                                              controller: _model
                                                                  .interiorNumberDogWalkerInputTextController,
                                                              focusNode: _model
                                                                  .interiorNumberDogWalkerInputFocusNode,
                                                              autofocus: false,
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              obscureText: false,
                                                              decoration:
                                                                  InputDecoration(
                                                                isDense: true,
                                                                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                                                                labelText: 'Int',
                                                                labelStyle:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .override(
                                                                          font: GoogleFonts
                                                                              .lexend(
                                                                            fontWeight: FlutterFlowTheme.of(context)
                                                                                .labelMedium
                                                                                .fontWeight,
                                                                            fontStyle: FlutterFlowTheme.of(context)
                                                                                .labelMedium
                                                                                .fontStyle,
                                                                          ),
                                                                          color: FlutterFlowTheme.of(context)
                                                                              .primary,
                                                                          fontSize:
                                                                              16,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                hintStyle:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .override(
                                                                          font: GoogleFonts
                                                                              .lexend(
                                                                            fontWeight: FlutterFlowTheme.of(context)
                                                                                .labelMedium
                                                                                .fontWeight,
                                                                            fontStyle: FlutterFlowTheme.of(context)
                                                                                .labelMedium
                                                                                .fontStyle,
                                                                          ),
                                                                          color: FlutterFlowTheme.of(context)
                                                                              .primary,
                                                                          fontSize:
                                                                              16,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      const BorderSide(
                                                                    color: Color(
                                                                        0x00000000),
                                                                    width: 1,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                ),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      const BorderSide(
                                                                    color: Color(
                                                                        0x00000000),
                                                                    width: 1,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                ),
                                                                errorBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .error,
                                                                    width: 1,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                ),
                                                                focusedErrorBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .error,
                                                                    width: 1,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                ),
                                                                filled: true,
                                                                fillColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .alternate,
                                                                prefixIcon: Icon(
                                                                  Icons
                                                                      .numbers_sharp,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  size: 25,
                                                                ),
                                                              ),
                                                              style: FlutterFlowTheme
                                                                      .of(context)
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
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                    fontSize: 16,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              cursorColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                              
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                              padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                              child: _availableNeighborhoods.isEmpty
                                                  ? // Campo deshabilitado si no hay CP válido
                                                    TextFormField(
                                                      controller: _model.neighborhoodDogWalkerInputTextController,
                                                      focusNode: _model.neighborhoodDogWalkerInputFocusNode,
                                                      enabled: false,
                                                      decoration: InputDecoration(
                                                        isDense: true,
                                                        labelText: 'Colonia',
                                                        hintText: 'Ingresa un código postal válido primero',
                                                        labelStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                                                          font: GoogleFonts.lexend(),
                                                          color: FlutterFlowTheme.of(context).primary,
                                                          fontSize: 16,
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color: FlutterFlowTheme.of(context).alternate,
                                                            width: 1,
                                                          ),
                                                          borderRadius: BorderRadius.circular(30),
                                                        ),
                                                        disabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color: FlutterFlowTheme.of(context).alternate,
                                                            width: 1,
                                                          ),
                                                          borderRadius: BorderRadius.circular(30),
                                                        ),
                                                        filled: true,
                                                        fillColor: FlutterFlowTheme.of(context).alternate.withOpacity(0.5),
                                                        contentPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                                                        prefixIcon: Icon(
                                                          Icons.home_rounded,
                                                          color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
                                                          size: 25,
                                                        ),
                                                      ),
                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                        font: GoogleFonts.lexend(),
                                                        color: FlutterFlowTheme.of(context).secondaryBackground.withOpacity(0.5),
                                                        fontSize: 16,
                                                      ),
                                                    )
                                                  : _showCustomNeighborhoodInput
                                                      ? // Input de texto para escribir colonia personalizada
                                                        TextFormField(
                                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                                          controller: _model.neighborhoodDogWalkerInputTextController,
                                                          focusNode: _model.neighborhoodDogWalkerInputFocusNode,
                                                          autofocus: true,
                                                          textInputAction: TextInputAction.next,
                                                          obscureText: false,
                                                          decoration: InputDecoration(
                                                            isDense: true,
                                                            labelText: 'Escribe tu colonia',
                                                            hintText: 'Nombre de la colonia',
                                                            labelStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                                                              font: GoogleFonts.lexend(),
                                                              color: FlutterFlowTheme.of(context).primary,
                                                              fontSize: 16,
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
                                                            contentPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                                                            prefixIcon: Icon(
                                                              Icons.home_rounded,
                                                              color: FlutterFlowTheme.of(context).primary,
                                                              size: 25,
                                                            ),
                                                            // Botón para volver al dropdown
                                                            suffixIcon: IconButton(
                                                              icon: Icon(
                                                                Icons.arrow_back,
                                                                color: FlutterFlowTheme.of(context).primary,
                                                                size: 20,
                                                              ),
                                                              onPressed: () {
                                                                setState(() {
                                                                  _showCustomNeighborhoodInput = false;
                                                                  _selectedNeighborhood = null;
                                                                  _model.neighborhoodDogWalkerInputTextController?.clear();
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                            font: GoogleFonts.lexend(),
                                                            color: FlutterFlowTheme.of(context).secondaryBackground,
                                                            fontSize: 16,
                                                          ),
                                                          cursorColor: FlutterFlowTheme.of(context).primaryText,
                                                          validator: (value) {
                                                            final required = Validators.requiredField(value, fieldName: 'Colonia');
                                                            if (required != null) return required;
                                                            final min = Validators.minLength(value, 3, fieldName: 'Colonia');
                                                            if (min != null) return min;
                                                            return Validators.maxLength(value, 50, fieldName: 'Colonia');
                                                          },
                                                          inputFormatters: [
                                                            LengthLimitingTextInputFormatter(50),
                                                          ],
                                                        )
                                                      : // Dropdown con colonias + "Otra"
                                                        FlutterFlowDropDown<String>(
                                                          controller: _model.neighborhoodDogWalkerMenuValueController ??=
                                                              FormFieldController<String>(null),
                                                          options: _availableNeighborhoods,
                                                          onChanged: (val) {
                                                            setState(() {
                                                              if (val == 'Otra') {
                                                                _showCustomNeighborhoodInput = true;
                                                                _selectedNeighborhood = null;
                                                                _model.neighborhoodDogWalkerInputTextController?.clear();
                                                              } else {
                                                                _selectedNeighborhood = val;
                                                                _model.neighborhoodDogWalkerInputTextController?.text = val ?? '';
                                                              }
                                                            });
                                                          },
                                                          width: MediaQuery.sizeOf(context).width,
                                                          height: MediaQuery.sizeOf(context).height * 0.05,
                                                          textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                            font: GoogleFonts.lexend(),
                                                            color: FlutterFlowTheme.of(context).primary,
                                                            fontSize: 16,
                                                          ),
                                                          hintText: 'Selecciona una colonia',
                                                          icon: Icon(
                                                            Icons.keyboard_arrow_down_rounded,
                                                            color: FlutterFlowTheme.of(context).primary,
                                                            size: 25,
                                                          ),
                                                          fillColor: FlutterFlowTheme.of(context).alternate,
                                                          elevation: 2,
                                                          borderColor: Colors.transparent,
                                                          borderWidth: 0,
                                                          borderRadius: 30,
                                                          margin: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                                                          hidesUnderline: true,
                                                          isOverButton: false,
                                                          isSearchable: false,
                                                          isMultiSelect: false,
                                                        ),
                                            ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                                child: TextFormField(
                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                  controller: _model.cityDogWalkerInputTextController,
                                                  focusNode: _model.cityDogWalkerInputFocusNode,
                                                  enabled: _postalCodeValidated, // Habilitado solo si hay CP válido
                                                  textInputAction: TextInputAction.next,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    labelText: 'Ciudad',
                                                    hintText: _postalCodeValidated 
                                                        ? 'Puedes editar si es necesario'
                                                        : 'Se completará automáticamente',
                                                    labelStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                                                      font: GoogleFonts.lexend(),
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      fontSize: 16,
                                                    ),
                                                    hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                      font: GoogleFonts.lexend(),
                                                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.7),
                                                      fontSize: 14,
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
                                                    disabledBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: FlutterFlowTheme.of(context).alternate,
                                                        width: 1,
                                                      ),
                                                      borderRadius: BorderRadius.circular(30),
                                                    ),
                                                    filled: true,
                                                    fillColor: _postalCodeValidated 
                                                        ? FlutterFlowTheme.of(context).alternate
                                                        : FlutterFlowTheme.of(context).alternate.withOpacity(0.5),
                                                    contentPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                                                    prefixIcon: Icon(
                                                      Icons.location_city,
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      size: 25,
                                                    ),
                                                  ),
                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                    font: GoogleFonts.lexend(),
                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                    fontSize: 16,
                                                  ),
                                                  cursorColor: FlutterFlowTheme.of(context).primaryText,
                                                  validator: (value) {
                                                    final required = Validators.requiredField(value, fieldName: 'Ciudad');
                                                    if (required != null) return required;
                                                    final min = Validators.minLength(value, 3, fieldName: 'Ciudad');
                                                    if (min != null) return min;
                                                    return Validators.maxLength(value, 50, fieldName: 'Ciudad');
                                                  },
                                                  inputFormatters: [
                                                    LengthLimitingTextInputFormatter(50),
                                                  ],
                                                ),
                                              ),

                                              if(widget.registerMethod == 'email')
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 18, 0, 0),
                                                child: TextFormField(
                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                  controller: _model
                                                      .passDogWalkerInputTextController,
                                                  focusNode: _model
                                                      .passDogWalkerInputFocusNode,
                                                  autofocus: false,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  obscureText: !_model
                                                      .passDogWalkerInputVisibility,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    labelText: 'Contraseña',
                                                    labelStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.lexend(
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
                                                    hintStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .bodyLarge
                                                        .override(
                                                          font:
                                                              GoogleFonts.lexend(
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
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .alternate,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: const BorderSide(
                                                        color: Color(0x00000000),
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    filled: true,
                                                    fillColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .alternate,
                                                    contentPadding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 0, 0, 20),
                                                    prefixIcon: Icon(
                                                      Icons.lock_outline,
                                                      color: FlutterFlowTheme.of(
                                                              context)
                                                          .primary,
                                                      size: 25,
                                                    ),
                                                    suffixIcon: InkWell(
                                                      onTap: () => safeSetState(
                                                        () => _model
                                                                .passDogWalkerInputVisibility =
                                                            !_model
                                                                .passDogWalkerInputVisibility,
                                                      ),
                                                      focusNode: FocusNode(
                                                          skipTraversal: true),
                                                      child: Icon(
                                                        _model.passDogWalkerInputVisibility
                                                            ? Icons
                                                                .visibility_off_outlined
                                                            : Icons
                                                                .visibility_outlined,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        size: 25,
                                                      ),
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
                                                        color: FlutterFlowTheme
                                                                .of(context)
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
                                                  validator: (value) => Validators.password(value),
                                                  maxLength: 16,
                                                ),
                                              ),

                                              if(widget.registerMethod == 'email')
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 18, 0, 0),
                                                child: TextFormField(
                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                  controller: _model
                                                      .confirmPassDogWalkerInputTextController,
                                                  focusNode: _model
                                                      .confirmPassDogWalkerInputFocusNode,
                                                  autofocus: false,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  obscureText: !_model
                                                      .confirmPassDogWalkerInputVisibility,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    labelText:
                                                        'Confirmar contraseña',
                                                    labelStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.lexend(
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
                                                    hintStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .bodyLarge
                                                        .override(
                                                          font:
                                                              GoogleFonts.lexend(
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
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .alternate,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: const BorderSide(
                                                        color: Color(0x00000000),
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    filled: true,
                                                    fillColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .alternate,
                                                    contentPadding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 0, 0, 20),
                                                    prefixIcon: Icon(
                                                      Icons.lock_outline,
                                                      color: FlutterFlowTheme.of(
                                                              context)
                                                          .primary,
                                                      size: 25,
                                                    ),
                                                    suffixIcon: InkWell(
                                                      onTap: () => safeSetState(
                                                        () => _model
                                                                .confirmPassDogWalkerInputVisibility =
                                                            !_model
                                                                .confirmPassDogWalkerInputVisibility,
                                                      ),
                                                      focusNode: FocusNode(
                                                          skipTraversal: true),
                                                      child: Icon(
                                                        _model.confirmPassDogWalkerInputVisibility
                                                            ? Icons
                                                                .visibility_off_outlined
                                                            : Icons
                                                                .visibility_outlined,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        size: 25,
                                                      ),
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
                                                        color: FlutterFlowTheme
                                                                .of(context)
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
                                                  validator: (value) => Validators.password(value),
                                                  maxLength: 16,
                                                ),
                                              ),

                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 18, 0, 18),
                                                child: FFButtonWidget(
                                                   onPressed: isRegistering
                                                    ? null
                                                    : () async {
                                                        final genderValid = _model.genderDogWalkerMenuValue != null && 
                                                                          _model.genderDogWalkerMenuValue!.isNotEmpty;
                                                        
                                                        setState(() {
                                                          _showGenderError = !genderValid;
                                                        });

                                                        if (!genderValid) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(
                                                              content: Text('Por favor selecciona tu género'),
                                                            ),
                                                          );
                                                          return; 
                                                        }

                                                        // Validaciones básicas antes de iniciar el registro
                                                        if (!_model.formKey.currentState!.validate()) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(content: Text('Corrige los campos con errores')),
                                                          );
                                                          return;
                                                        }

                                                        // Validar código postal con la API de Google
                                                        final geoService = ZipCodeService();
                                                        final postalCode = _model.zipCodeDogWalkerInputTextController.text.trim();

                                                        final isValidPostal = await geoService.validatePostalCode(postalCode);
                                                        if (!isValidPostal) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(content: Text('El código postal no es válido o no pertenece a Jalisco.')),
                                                          );
                                                          return;
                                                        }

                                                        // VALIDAR COLONIA SELECCIONADA
                                                        final coloniaValue = _model.neighborhoodDogWalkerInputTextController.text.trim();
                                                        if (coloniaValue.isEmpty) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(
                                                              content: Text('Por favor ingresa o selecciona una colonia'),
                                                            ),
                                                          );
                                                          return;
                                                        }

                                                        if (_model.datePicked == null) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(content: Text('Selecciona una fecha de nacimiento')),
                                                          );
                                                          return;
                                                        }

                                                        if (_model.passDogWalkerInputTextController.text !=
                                                            _model.confirmPassDogWalkerInputTextController.text) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(content: Text('Las contraseñas no coinciden')),
                                                          );
                                                          return;
                                                        }

                                                        setState(() => isRegistering = true);

                                                        try {
                                                          await registerDogWalker(context, widget.registerMethod); 

                                                          if (!mounted) return;

                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(content: Text('¡Registro exitoso!')),
                                                          );

                                                          await Future.delayed(const Duration(milliseconds: 500));

                                                          context.go('/');
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text('Error: $e')),
                                                          );
                                                        } finally {
                                                          if (mounted) setState(() => isRegistering = false);
                                                        }
                                                      },
                                                  text: 'Registrarse',
                                                  options: FFButtonOptions(
                                                    width:
                                                        MediaQuery.sizeOf(context)
                                                            .width,
                                                    height:
                                                        MediaQuery.sizeOf(context)
                                                                .height *
                                                            0.05,
                                                    padding: const EdgeInsetsDirectional
                                                        .fromSTEB(0, 0, 0, 0),
                                                    iconPadding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(0, 0, 0, 0),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .accent1,
                                                    textStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .titleSmall
                                                        .override(
                                                          font:
                                                              GoogleFonts.lexend(
                                                            fontWeight:
                                                                FontWeight.normal,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                          ),
                                                          color: Colors.white,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontStyle,
                                                        ),
                                                    elevation: 0,
                                                    borderRadius:
                                                        BorderRadius.circular(10),
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
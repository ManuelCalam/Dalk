import 'package:dalk/backend/supabase/supabase.dart';
import 'package:dalk/utils/validation.dart';
import '/auth/supabase_auth/auth_util.dart';
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

import 'dog_owner_update_profile_model.dart';
export 'dog_owner_update_profile_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dalk/services/zipCode_service.dart';
import 'dart:io';
import '/user_provider.dart';
import '/user_prefs.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DogOwnerUpdateProfileWidget extends StatefulWidget {
  const DogOwnerUpdateProfileWidget({super.key});

  static String routeName = 'dogOwnerUpdateProfile';
  static String routePath = '/dogOwnerUpdateProfile';

  
  @override
  State<DogOwnerUpdateProfileWidget> createState() =>
      _DogOwnerUpdateProfileWidgetState();
}

class _DogOwnerUpdateProfileWidgetState
    extends State<DogOwnerUpdateProfileWidget> {
  late DogOwnerUpdateProfileModel _model;

  //imagen
  File? _ownerImage;
  File? _walkerImage;
  File? _tempImage;
  final ImagePicker _picker = ImagePicker();

  List<String> _availableNeighborhoods = [];
  bool _isLoadingPostalCode = false;
  String? _selectedNeighborhood;
  bool _postalCodeValidated = false;
  bool _showCustomNeighborhoodInput = false;
  
  bool _isInitialLoad = true;
  String? _initialPostalCode;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> cargarDatosUsuario() async {
    
    final response = await Supabase.instance.client
        .from('users')
        .select()
        .eq('uuid', currentUserUid)
        .single();

    if (response != null) {
      _model.nameDogOwnerInputTextController.text = response['name'] ?? '';
      _model.phoneDogOwnerInputTextController.text = response['phone'] ?? '';
      _model.streetDogOwnerInputTextController.text = response['address'] ?? '';
      _model.exteriorNumberDogOwnerInputTextController.text = response['ext_number'] ?? '';
      _model.interiorNumberDogOwnerInputTextController.text = response['int_number'] ?? '';
      _model.zipCodeDogOwnerInputTextController.text = response['zipCode'] ?? '';
      _model.neighborhoodDogOwnerInputTextController.text = response['neighborhood'] ?? '';
      _model.cityDogOwnerInputTextController.text = response['city'] ?? '';
      
      _model.genderDogOwnerMenuValue = response['gender'] ?? '';
      if (response['birthdate'] != null) {
        _model.datePicked = DateTime.tryParse(response['birthdate']);
      }
      _model.genderDogOwnerMenuValueController?.value = _model.genderDogOwnerMenuValue;

      _initialPostalCode = response['zipCode'] ?? '';

      if (_model.zipCodeDogOwnerInputTextController.text.length == 5) {
        await _loadExistingPostalCodeData();
      }

      setState(() {
        _isInitialLoad = false;
      });
    }
  }

  Future<void> _loadExistingPostalCodeData() async {
    final postalCode = _model.zipCodeDogOwnerInputTextController.text.trim();
    if (postalCode.length != 5) return;

    setState(() => _isLoadingPostalCode = true);

    try {
      final geoService = ZipCodeService();
      final postalInfo = await geoService.getPostalCodeInfo(postalCode);

      if (!mounted) return;

      if (postalInfo.isValid) {
        setState(() {
          _postalCodeValidated = true;
          _availableNeighborhoods = [...postalInfo.neighborhoods, 'Otra'];
          
          // Si la colonia actual está en la lista, seleccionarla
          final currentNeighborhood = _model.neighborhoodDogOwnerInputTextController.text;
          if (postalInfo.neighborhoods.contains(currentNeighborhood)) {
            _selectedNeighborhood = currentNeighborhood;
          } else if (currentNeighborhood.isNotEmpty) {
            // Si tiene colonia pero no está en la lista, mostrar input personalizado
            _showCustomNeighborhoodInput = true;
            _selectedNeighborhood = 'Otra';
          }
        });
      }
    } catch (e) {
      print('Error cargando código postal existente: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingPostalCode = false);
      }
    }
  }

  void _onPostalCodeChanged() async {
    final postalCode = _model.zipCodeDogOwnerInputTextController!.text.trim();

    if (_isInitialLoad) return;

    if (postalCode == _initialPostalCode && _postalCodeValidated) return;

    if (postalCode.length != 5) {
      if (_postalCodeValidated) {
        setState(() {
          _postalCodeValidated = false;
          _availableNeighborhoods = [];
          _selectedNeighborhood = null;
          _showCustomNeighborhoodInput = false;
          _model.neighborhoodDogOwnerInputTextController?.clear();
          _model.cityDogOwnerInputTextController?.clear();
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
          _availableNeighborhoods = [...postalInfo.neighborhoods, 'Otra'];
          _selectedNeighborhood = null;
          _showCustomNeighborhoodInput = false;
          
          // Auto-completar ciudad
          _model.cityDogOwnerInputTextController?.text = postalInfo.city;
          
          // Limpiar colonia anterior
          _model.neighborhoodDogOwnerInputTextController?.clear();
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
          _model.neighborhoodDogOwnerInputTextController?.clear();
          _model.cityDogOwnerInputTextController?.clear();
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DogOwnerUpdateProfileModel());

    _model.nameDogOwnerInputTextController ??= TextEditingController();
    _model.nameDogOwnerInputFocusNode ??= FocusNode();

    _model.phoneDogOwnerInputTextController ??= TextEditingController();
    _model.phoneDogOwnerInputFocusNode ??= FocusNode();

    _model.streetDogOwnerInputTextController ??= TextEditingController();
    _model.streetDogOwnerInputFocusNode ??= FocusNode();

    _model.interiorNumberDogOwnerInputTextController ??= TextEditingController();
    _model.interiorNumberDogOwnerInputFocusNode ??= FocusNode();

    _model.exteriorNumberDogOwnerInputTextController ??= TextEditingController();
    _model.exteriorNumberDogOwnerInputFocusNode ??= FocusNode();

    _model.zipCodeDogOwnerInputTextController ??= TextEditingController();
    _model.zipCodeDogOwnerInputFocusNode ??= FocusNode();
    _model.zipCodeDogOwnerInputTextController!.addListener(_onPostalCodeChanged);

    _model.neighborhoodDogOwnerInputTextController ??= TextEditingController();
    _model.neighborhoodDogOwnerInputFocusNode ??= FocusNode();

    _model.cityDogOwnerInputTextController ??= TextEditingController();
    _model.cityDogOwnerInputFocusNode ??= FocusNode();

    cargarDatosUsuario();
  }


  @override
  void dispose() {
    _model.zipCodeDogOwnerInputTextController?.removeListener(_onPostalCodeChanged);
    _model.dispose();
    super.dispose();
  }

  Future<String?> _uploadOwnerImage(String userId, File imageFile) async {
    try {
      final filePath = 'owners/$userId/profile.jpg';
      final storage = Supabase.instance.client.storage;

      // Subir a storage (sobrescribir si ya existe)
      await storage.from('profile_pics').upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = storage.from('profile_pics').getPublicUrl(filePath);

      final uniqueUrl = '$imageUrl?version=${DateTime.now().millisecondsSinceEpoch}';

      await Supabase.instance.client
          .from('users')
          .update({'photo_url': uniqueUrl})
          .eq('uuid', userId);

      return uniqueUrl;
    } catch (e) {
      debugPrint('Error al subir imagen: $e');
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _tempImage = File(pickedFile.path);
      });

      

    }
  }

  void _showImagePickerOptions(BuildContext context) {
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
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de la galería'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final String? userType = user?.usertype; 
    final String userPrefix = userType == 'Dueño' ? 'owner' : 'walker';
    final photoUrl = user?.photoUrl ?? "";
    final supabase = Supabase.instance.client;
    final user1 = supabase.auth.currentUser;
      
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
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height * 0.82,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).tertiary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
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
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.9,
                          decoration: const BoxDecoration(),
                          child: ListView(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            children: [
                              Container(
                                width: MediaQuery.sizeOf(context).width,
                                decoration: const BoxDecoration(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Mi Perfil',
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
                                            fontSize: 32,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                    Text(
                                      'Edita tu información',
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
                                            color: FlutterFlowTheme.of(context)
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
                                  ],
                                ),
                              ),
                              Align(
                                alignment: const AlignmentDirectional(0, 0),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                                  child: GestureDetector(
                                    onTap: () => _showImagePickerOptions(context),
                                    child: _tempImage != null
                                        // Si eligió una imagen local (File)
                                        ? CircleAvatar(
                                            radius: 60,
                                            backgroundImage: FileImage(_tempImage!),
                                          )
                                        //Si ya tiene foto en Supabase (con cache)
                                        : (photoUrl.isNotEmpty)
                                            ? CircleAvatar(
                                                radius: 60,
                                                backgroundImage:
                                                    CachedNetworkImageProvider(photoUrl),
                                              )
                                            // Si no hay imagen
                                            : const CircleAvatar(
                                                radius: 60,
                                                child: Icon(Icons.person, size: 60),
                                              ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width * 0.9,
                                  decoration: const BoxDecoration(),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Form(
                                        key: _model.formKey,
                                        autovalidateMode:
                                            AutovalidateMode.disabled,
                                        child: SingleChildScrollView(
                                          primary: false,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                        .width,
                                                child: TextFormField(
                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                  controller: _model
                                                      .nameDogOwnerInputTextController,
                                                  focusNode: _model
                                                      .nameDogOwnerInputFocusNode,
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
                                                        .phoneDogOwnerInputTextController,
                                                    focusNode: _model
                                                        .phoneDogOwnerInputFocusNode,
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
                                                        await showDatePicker(
                                                      context: context,
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
                                                                  color: FlutterFlowTheme.of(context).primary,
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
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 18, 0, 0),
                                                child:
                                                    FlutterFlowDropDown<String>(
                                                  controller: _model
                                                          .genderDogOwnerMenuValueController ??=
                                                      FormFieldController<
                                                          String>(
                                                    _model.genderDogOwnerMenuValue ??=
                                                        '',
                                                  ),
                                                  options: List<String>.from([
                                                    'Hombre',
                                                    'Mujer',
                                                    'Otro'
                                                  ]),
                                                  optionLabels: const [
                                                    'Hombre',
                                                    'Mujer',
                                                    'Otro'
                                                  ],
                                                  onChanged: (val) =>
                                                      safeSetState(() => _model
                                                              .genderDogOwnerMenuValue =
                                                          val),
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                          .width,
                                                  height:
                                                      MediaQuery.sizeOf(context)
                                                              .height *
                                                          0.05,
                                                  textStyle: FlutterFlowTheme
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
                                                    Icons
                                                        .keyboard_arrow_down_rounded,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    size: 25,
                                                  ),
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .alternate,
                                                  elevation: 2,
                                                  borderColor:
                                                      Colors.transparent,
                                                  borderWidth: 0,
                                                  borderRadius: 8,
                                                  margin: const EdgeInsetsDirectional
                                                      .fromSTEB(12, 0, 12, 0),
                                                  hidesUnderline: true,
                                                  isOverButton: false,
                                                  isSearchable: false,
                                                  isMultiSelect: false,
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
                                                      .streetDogOwnerInputTextController,
                                                  focusNode: _model
                                                      .streetDogOwnerInputFocusNode,
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
                                                  controller: _model.zipCodeDogOwnerInputTextController,
                                                  focusNode: _model.zipCodeDogOwnerInputFocusNode,
                                                  autofocus: false,
                                                  textInputAction: TextInputAction.next,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    labelText: 'Código postal',
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
                                                      Icons.location_on,
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      size: 25,
                                                    ),
                                                    // 🔑 AGREGAR INDICADOR DE CARGA Y VALIDACIÓN
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
                                                    font: GoogleFonts.lexend(),
                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                    fontSize: 16,
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
                                                                .exteriorNumberDogOwnerInputTextController,
                                                            focusNode: _model
                                                                .exteriorNumberDogOwnerInputFocusNode,
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
                                                                .interiorNumberDogOwnerInputTextController,
                                                            focusNode: _model
                                                                .interiorNumberDogOwnerInputFocusNode,
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
                                                  ? TextFormField(
                                                      controller: _model.neighborhoodDogOwnerInputTextController,
                                                      focusNode: _model.neighborhoodDogOwnerInputFocusNode,
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
                                                      ? TextFormField(
                                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                                          controller: _model.neighborhoodDogOwnerInputTextController,
                                                          focusNode: _model.neighborhoodDogOwnerInputFocusNode,
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
                                                                  _model.neighborhoodDogOwnerInputTextController?.clear();
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
                                                            if (value == null || value.trim().isEmpty) {
                                                              return 'La colonia es obligatoria';
                                                            }
                                                            final min = Validators.minLength(value, 3, fieldName: 'Colonia');
                                                            if (min != null) return min;
                                                            return Validators.maxLength(value, 50, fieldName: 'Colonia');
                                                          },
                                                          inputFormatters: [
                                                            LengthLimitingTextInputFormatter(50),
                                                          ],
                                                        )
                                                      : FlutterFlowDropDown<String>(
                                                          controller: _model.neighborhoodDogOwnerMenuValueController ??=
                                                              FormFieldController<String>(_selectedNeighborhood),
                                                          options: _availableNeighborhoods,
                                                          onChanged: (val) {
                                                            setState(() {
                                                              if (val == 'Otra') {
                                                                _showCustomNeighborhoodInput = true;
                                                                _selectedNeighborhood = null;
                                                                _model.neighborhoodDogOwnerInputTextController?.clear();
                                                              } else {
                                                                _selectedNeighborhood = val;
                                                                _model.neighborhoodDogOwnerInputTextController?.text = val ?? '';
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
                                                controller: _model.cityDogOwnerInputTextController,
                                                focusNode: _model.cityDogOwnerInputFocusNode,
                                                enabled: _postalCodeValidated,
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
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 18, 0, 18),
                                                child: FFButtonWidget(
                                                  onPressed: () async {
                                                    if (!_model.formKey.currentState!.validate()) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(content: Text('Corrige los campos con errores')),
                                                      );
                                                      return;
                                                    }

                                                    if (_model.neighborhoodDogOwnerInputTextController.text.trim().isEmpty) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(
                                                          content: Text('Debes seleccionar o escribir una colonia'),
                                                          backgroundColor: Colors.red,
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
                                                    final address = (user?.address);
                                                        
                                                    try {
                                                      final response = await Supabase.instance.client
                                                          .from('users')
                                                          .update({
                                                            'name': _model.nameDogOwnerInputTextController.text,
                                                            'phone': _model.phoneDogOwnerInputTextController.text,
                                                            'birthdate': supaSerialize<DateTime>(_model.datePicked),
                                                            'gender': _model.genderDogOwnerMenuValue,
                                                            'address': _model.streetDogOwnerInputTextController.text,
                                                            'ext_number': _model.exteriorNumberDogOwnerInputTextController.text,
                                                            'int_number': _model.interiorNumberDogOwnerInputTextController.text,
                                                            'houseNumber': _model.interiorNumberDogOwnerInputTextController.text, //Quitar esta línea
                                                            'zipCode': _model.zipCodeDogOwnerInputTextController.text,
                                                            'neighborhood': _model.neighborhoodDogOwnerInputTextController.text,
                                                            'city': _model.cityDogOwnerInputTextController.text,
                                                          })
                                                          .eq('uuid', currentUserUid); 

                                                          if(address == null || address == '') {
                                                            await supabase.from('addresses').insert({
                                                              'uuid': currentUserUid,
                                                              'alias': 'Mi Dirección',
                                                              'address': _model.streetDogOwnerInputTextController.text.trim(),
                                                              'ext_number': _model.exteriorNumberDogOwnerInputTextController.text.trim(),
                                                              'int_number': _model.interiorNumberDogOwnerInputTextController.text.trim(),
                                                              'zipCode': _model.zipCodeDogOwnerInputTextController.text.trim(),
                                                              'neighborhood': _model.neighborhoodDogOwnerInputTextController.text.trim(),
                                                              'city': _model.cityDogOwnerInputTextController.text.trim(),
                                                            });
                                                          }

                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(content: Text('¡Perfil actualizado exitosamente!')),
                                                          );
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text('Error al actualizar el perfil: $e')),
                                                      );
                                                    }
                                                    //setState(() {});
                                                    //PaintingBinding.instance.imageCache.clear();
                                                    //PaintingBinding.instance.imageCache.clearLiveImages();
                                                    // 2. Limpiar la imagen vieja del caché
                                                    try {
                                                      await CachedNetworkImage.evictFromCache(photoUrl);

                                                      if (user1 == null || _tempImage == null) {
                                                        debugPrint('Error: no hay usuario o imagen seleccionada.');
                                                        return; 
                                                      }

                                                      // Subir a Supabase
                                                      final uploadedUrl = await _uploadOwnerImage(user1.id, _tempImage!);

                                                      if (uploadedUrl != null) {
                                                        // Solo actualizar Provider y SharedPrefs
                                                        final currentUser = context.read<UserProvider>().user;
                                                        final updatedUser = UserModel(
                                                          name: currentUser?.name ?? "User",
                                                          photoUrl: uploadedUrl,
                                                        );
                                                        context.read<UserProvider>().setUser(updatedUser);
                                                        await UserPrefs.saveUser(updatedUser);

                                                        setState(() {
                                                          _tempImage = null;
                                                        });
                                                      }
                                                    } catch (e, stack) {
                                                      debugPrint('Error en el proceso de carga: $e');
                                                      debugPrint('$stack');
                                                    } finally {
                                                      if (context.mounted) {
                                                        context.read<UserProvider>().loadUser(forceRefresh: true);
                                                        GoRouter.of(context).go('/$userPrefix/profile');
                                                      }
                                                    }

                                                  },
                                                  text: 'Guardar cambios',
                                                  options: FFButtonOptions(
                                                    width: 360,
                                                    height: 40,
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 0, 0, 0),
                                                    iconPadding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 0, 0, 0),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .accent1,
                                                    textStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .titleSmall
                                                        .override(
                                                          font: GoogleFonts
                                                              .lexend(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
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
                                                        BorderRadius.circular(
                                                            10),
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
                            ],
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
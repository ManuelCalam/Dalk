import 'package:dalk/backend/supabase/supabase.dart';
import 'package:dalk/dog_owner/buy_tracker/buy_tracker_widget.dart';
import 'package:dalk/dog_owner/set_walk_schedule/set_walk_schedule_widget.dart';
import 'package:dalk/flutter_flow/flutter_flow_drop_down.dart';
import 'package:dalk/utils/validation.dart';
import 'package:flutter/services.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/components/go_back_container/go_back_container_widget.dart';
import '/components/notification_container/notification_container_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dalk/services/zipCode_service.dart';
import '/flutter_flow/form_field_controller.dart';

import 'add_address_model.dart';
export 'add_address_model.dart';

class AddAddressWidget extends StatefulWidget {
  const AddAddressWidget({
    super.key,
    required this.originWindow
    });

    final String originWindow;

  static String routeName = 'addAddress';
  static String routePath = '/addAddress';

  @override
  State<AddAddressWidget> createState() => _AddAddressWidgetState();
}

class _AddAddressWidgetState extends State<AddAddressWidget> {
  late AddAddressModel _model;

  List<String> _availableNeighborhoods = [];
  bool _isLoadingPostalCode = false;
  String? _selectedNeighborhood;
  bool _postalCodeValidated = false;
  bool _showCustomNeighborhoodInput = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddAddressModel());

    _model.aliasInputTextController ??= TextEditingController();
    _model.aliasInputFocusNode ??= FocusNode();

    _model.addressInputTextController ??= TextEditingController();
    _model.addressInputFocusNode ??= FocusNode();

    _model.interiorNumberInputTextController ??= TextEditingController();
    _model.interiorNumberInputFocusNode ??= FocusNode();
    
    _model.exteriorNumberInputTextController ??= TextEditingController();
    _model.exteriorNumberInputFocusNode ??= FocusNode();

    _model.zipCodeInputTextController ??= TextEditingController();
    _model.zipCodeInputFocusNode ??= FocusNode();
    _model.zipCodeInputTextController!.addListener(_onPostalCodeChanged);

    _model.neighborhoodInputTextController ??= TextEditingController();
    _model.neighborhoodInputFocusNode ??= FocusNode();

    _model.cityInputTextController ??= TextEditingController();
    _model.cityInputFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.zipCodeInputTextController?.removeListener(_onPostalCodeChanged);
    _model.dispose();
    super.dispose();
  }

void _onPostalCodeChanged() async {
  final postalCode = _model.zipCodeInputTextController!.text.trim();

  if (postalCode.length != 5) {
    if (_postalCodeValidated) {
      setState(() {
        _postalCodeValidated = false;
        _availableNeighborhoods = [];
        _selectedNeighborhood = null;
        _showCustomNeighborhoodInput = false;
        _model.neighborhoodInputTextController?.clear();
        _model.cityInputTextController?.clear();
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
        
        _model.cityInputTextController?.text = postalInfo.city;
        _model.neighborhoodInputTextController?.clear();
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
        _model.neighborhoodInputTextController?.clear();
        _model.cityInputTextController?.clear();
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  shape: BoxShape.rectangle,
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
                  height: MediaQuery.sizeOf(context).height * 0.9,
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
                      Container(
                        width: MediaQuery.sizeOf(context).width * 0.9,
                        height: MediaQuery.sizeOf(context).height * 0.08,
                        decoration: const BoxDecoration(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AutoSizeText(
                              'Nueva Dirección',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              minFontSize: 22,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
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
                              '¡Registra el lugar de recogida!',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              minFontSize: 10,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
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
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 15),
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 0.9,
                                height: double.infinity,
                                decoration: const BoxDecoration(),
                                child: SingleChildScrollView(
                                  child: Form(
                                    key: _model.formKey, 
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Align(
                                          alignment: const AlignmentDirectional(-1, -1),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                                            child: Container(
                                              width: MediaQuery.sizeOf(context).width,
                                              height: MediaQuery.sizeOf(context).height * 0.05,
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(context).alternate,
                                                borderRadius: BorderRadius.circular(35),
                                              ),
                                              child: Container(
                                                width: double.infinity,
                                                child: TextFormField(
                                                  controller: _model.aliasInputTextController,
                                                  focusNode: _model.aliasInputFocusNode,
                                                  autofocus: false,
                                                  textInputAction: TextInputAction.next,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    labelText: 'Alias',
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
                                                      borderSide: const BorderSide(
                                                        color: Color(0x00000000),
                                                        width: 1,
                                                      ),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderSide: const BorderSide(
                                                        color: Color(0x00000000),
                                                        width: 1,
                                                      ),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    errorBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: FlutterFlowTheme.of(context).error,
                                                        width: 1,
                                                      ),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    focusedErrorBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: FlutterFlowTheme.of(context).error,
                                                        width: 1,
                                                      ),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
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
                                                    final required = Validators.requiredField(value, fieldName: 'Alias');
                                                    if (required != null) return required;
                                                    return Validators.maxLength(value, 25, fieldName: 'Alias');
                                                  },                                                  
                                                  inputFormatters: [
                                                    LengthLimitingTextInputFormatter(25),
                                                  ],                                                                  
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        
                                        Align(
                                          alignment: const AlignmentDirectional(-1, -1),
                                          child: Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 18, 0, 0),
                                                child: Container(
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                          .width,
                                                  child: TextFormField(
                                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                                    controller: _model
                                                        .addressInputTextController,
                                                    focusNode: _model
                                                        .addressInputFocusNode,
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
                                        ),
                                        Align(
                                          alignment: const AlignmentDirectional(-1, -1),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                            child: Container(
                                              width: MediaQuery.sizeOf(context).width,
                                              child: TextFormField(
                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                controller: _model.zipCodeInputTextController,
                                                focusNode: _model.zipCodeInputFocusNode,
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
                                        ),
                                        Align(
                                          alignment: const AlignmentDirectional(-1, -1),
                                          child: Padding(
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
                                                      controller: _model.exteriorNumberInputTextController,
                                                      focusNode: _model.exteriorNumberInputFocusNode,
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
                                                          .interiorNumberInputTextController,
                                                      focusNode: _model
                                                          .interiorNumberInputFocusNode,
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
                                    ),
                                    Align(
                                      alignment: const AlignmentDirectional(-1, -1),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                        child: _availableNeighborhoods.isEmpty
                                            ? 
                                              TextFormField(
                                                controller: _model.neighborhoodInputTextController,
                                                focusNode: _model.neighborhoodInputFocusNode,
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
                                                ? 
                                                  TextFormField(
                                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                                    controller: _model.neighborhoodInputTextController,
                                                    focusNode: _model.neighborhoodInputFocusNode,
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
                                                            _model.neighborhoodInputTextController?.clear();
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
                                                : 
                                                  FlutterFlowDropDown<String>(
                                                    controller: _model.neighborhoodInputValueController ??=
                                                        FormFieldController<String>(null),
                                                    options: _availableNeighborhoods,
                                                    onChanged: (val) {
                                                      setState(() {
                                                        if (val == 'Otra') {
                                                          _showCustomNeighborhoodInput = true;
                                                          _selectedNeighborhood = null;
                                                          _model.neighborhoodInputTextController?.clear();
                                                        } else {
                                                          _selectedNeighborhood = val;
                                                          _model.neighborhoodInputTextController?.text = val ?? '';
                                                          _showCustomNeighborhoodInput = false;
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
                                    ),
                                    Align(
                                      alignment: const AlignmentDirectional(-1, -1),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                        child: TextFormField(
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          controller: _model.cityInputTextController,
                                          focusNode: _model.cityInputFocusNode,
                                          enabled: _postalCodeValidated,
                                          autofocus: false,
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
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                                      child: FFButtonWidget(
                                        onPressed: () async {
                                          if (!_model.formKey.currentState!.validate()) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Corrige los campos con errores')),
                                            );
                                            return;
                                          }

                                          try{
                                            final response = await Supabase.instance.client
                                            .from('addresses')
                                            .insert({
                                                'uuid': currentUserUid,
                                                'alias': _model.aliasInputTextController.text,
                                                'address': _model.addressInputTextController.text,
                                                'ext_number': _model.exteriorNumberInputTextController.text,
                                                'int_number': _model.interiorNumberInputTextController.text,
                                                'houseNumber': _model.interiorNumberInputTextController.text, // quitar esta línea
                                                'zipCode': _model.zipCodeInputTextController.text,
                                                'neighborhood': _model.neighborhoodInputTextController.text,
                                                'city': _model.cityInputTextController.text,

                                            });
                                              if (widget.originWindow == 'addWalk') {
                                                context.pushReplacementNamed(SetWalkScheduleWidget.routeName);
                                              } else if (widget.originWindow == 'buyTracker') {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => const BuyTrackerWidget()),
                                                );                                            
                                              }
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Error al registrar la dirección: $e')),
                                            );
                                          }
                                          
                                        },
                                        text: 'Registrar dirección',
                                        options: FFButtonOptions(
                                          width: double.infinity,
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

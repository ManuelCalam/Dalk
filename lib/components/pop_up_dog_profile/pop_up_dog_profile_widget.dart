import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/supabase/supabase.dart';
import 'package:dalk/common/review_details_card/review_details_card_widget.dart';

import 'pop_up_dog_profile_model.dart';
export 'pop_up_dog_profile_model.dart';

class PopUpDogProfileWidget extends StatefulWidget {
  // const PopUpDogProfileWidget({super.key});
  final int dogId;
  // final String dogId; // ID de la mascota

  //const DogReviewsList({Key? key, required this.dogId}) : super(key: key);
  const PopUpDogProfileWidget({
    super.key,
   required this.dogId,
  });

  @override
  State<PopUpDogProfileWidget> createState() => _PopUpDogProfileWidgetState();
}

class _PopUpDogProfileWidgetState extends State<PopUpDogProfileWidget> {
  late PopUpDogProfileModel _model;
  // final int dogId = ;

  // Variables para mostrar datos
  String? dogName;
  String ? dogOwner;
  int? dogAge;
  String? dogGender;
  String? dogBree;
  String? dogSize;
  List<String>? dogBehaviour;
  String? dogAboutMe;
  String? dogPhotoUrl;
  int? _totalWalks;
  double? _avgDogRating;
  String? _createdAgo;


  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _reviews = [];
  bool _loading = true;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
    
    //fetchDogData(); // Cargar datos al iniciar
  }

  Future<void> _fetchReviews() async {
    final response = await supabase
        .from('reviews')
        .select('id, rating, walk_id, comments, created_at, author_id, reviewer_photo, users:author_id (name)')
        .eq('reviewed_dog_id', widget.dogId)
        .order('created_at', ascending: false);
    print('Reviews response: $response');
    setState(() {
      _reviews = response.map<Map<String, dynamic>>((review) {
        return {
          'user_name': review['users']?['name'] ?? 'Usuario',
          'rating': review['rating'],
          'comments': review['comments'],
          'created_at': review['created_at'],
          'walk_id': review['walker_id'],
          'reviewer_photo': review['reviewer_photo'] ,
        };
      }).toList();
      _loading = false;
    });
  }

  Future<void> fetchDogData() async {
    final response = await Supabase.instance.client
        .from('pets_info') 
        .select('id,name,age,gender,bree,size,behaviour,aboutme,photo_url,average_rating,total_walks,created_at')
        .eq('id', widget.dogId)
        .maybeSingle();

    if (response != null) {
      setState(() {
        dogName = response['name'];
        dogAge = response['age'];
        dogGender = response['gender'];
        dogBree = response['bree'];
        dogSize = response['size'];
        dogBehaviour = List<String>.from(response['behaviour'] ?? []);
        dogAboutMe = response['aboutme'];
        dogPhotoUrl = response['photo_url'];

        _avgDogRating = (response['average_rating'] as num?)?.toDouble();
        _totalWalks = response['total_walks'] as int?;

        //  Calcular hace cuánto fue creado
        if (response['created_at'] != null) {
          final createdAt = DateTime.parse(response['created_at']);
          final diff = DateTime.now().difference(createdAt);

          if (diff.inDays < 1) {
            _createdAgo = '${diff.inHours} horas';
          } else if (diff.inDays < 30) {
            _createdAgo = '${diff.inDays} días';
          } else if (diff.inDays < 365) {
            _createdAgo = '${(diff.inDays / 30).floor()} meses';
          } else {
            _createdAgo = '${(diff.inDays / 365).floor()} años';
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PopUpDogProfileModel());
     fetchDogData();
     _fetchReviews();
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height * 0.85,
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
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
            child: Container(
              width: MediaQuery.sizeOf(context).width * 0.92,
              height: MediaQuery.sizeOf(context).height * 0.05,
              decoration: const BoxDecoration(),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  FlutterFlowIconButton(
                    borderRadius: 8,
                    buttonSize: 40,
                    icon: Icon(
                      Icons.chat,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 28,
                    ),
                    onPressed: () {
                      print('IconButton pressed ...');
                    },
                  ),
                  Expanded(
                    child: Align(
                      alignment: const AlignmentDirectional(1, 0),
                      child: FlutterFlowIconButton(
                        borderRadius: 8,
                        buttonSize: 40,
                        icon: FaIcon(
                          FontAwesomeIcons.angleDown,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 24,
                        ),
                        onPressed: () async {
                          // Action 1
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
              child: Container(
                width: MediaQuery.sizeOf(context).width * 0.9,
                decoration: const BoxDecoration(),
                child: SingleChildScrollView(
                  primary: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width * 0.9,
                        decoration: const BoxDecoration(),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              clipBehavior: Clip.antiAlias,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Image.network(
                                dogPhotoUrl ?? 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxMnx8ZG9nfGVufDB8fHx8MTc1OTcwNTIzMHww&ixlib=rb-4.1.0&q=80&w=1080',
                                fit: BoxFit.cover,
                              ),
                            ),
                            AutoSizeText(
                              dogName ?? '[Nombre]',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.lexend(
                                      fontWeight: FontWeight.bold,
                                      fontStyle:
                                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context).primary,
                                    fontSize: 32,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle:
                                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                  ),
                            ),
                            AutoSizeText(
                              dogBree?? '[breed]',
                              textAlign: TextAlign.center,
                              maxLines: 1,
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
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(5, 5, 0, 0),
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 0.25,
                                height:
                                    MediaQuery.sizeOf(context).height * 0.15,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(0),
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(0),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Align(
                                      alignment: const AlignmentDirectional(0, -1),
                                      child: Container(
                                        width: MediaQuery.sizeOf(context).width,
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.08,
                                        decoration: const BoxDecoration(),
                                        child: Align(
                                          alignment: const AlignmentDirectional(0, 1),
                                          child: Icon(
                                            Icons.star_border,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            size: 42,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: const AlignmentDirectional(0, -1),
                                      child: AutoSizeText(
                                        _avgDogRating != null 
                                        ? _avgDogRating!.toStringAsFixed(1)  // ejemplo: 4.8
                                        : '-',
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              fontSize: 22,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
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
                            ),
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(10, 5, 0, 0),
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 0.25,
                                height:
                                    MediaQuery.sizeOf(context).height * 0.15,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Align(
                                      alignment: const AlignmentDirectional(0, -1),
                                      child: Container(
                                        width: MediaQuery.sizeOf(context).width,
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.08,
                                        decoration: const BoxDecoration(),
                                        child: Align(
                                          alignment: const AlignmentDirectional(0, 1),
                                          child: Icon(
                                            Icons.hail,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            size: 48,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: const AlignmentDirectional(0, 0),
                                      child: AutoSizeText(
                                        _totalWalks != null 
                                          ? '${_totalWalks} Viajes' 
                                          : '0 Viajes',
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        minFontSize: 12,
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              fontSize: 20,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
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
                            ),
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(10, 5, 0, 0),
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 0.25,
                                height:
                                    MediaQuery.sizeOf(context).height * 0.15,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(0),
                                    bottomRight: Radius.circular(20),
                                    topLeft: Radius.circular(0),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Align(
                                      alignment: const AlignmentDirectional(0, -1),
                                      child: Container(
                                        width: MediaQuery.sizeOf(context).width,
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.08,
                                        decoration: const BoxDecoration(),
                                        child: Align(
                                          alignment: const AlignmentDirectional(0, 1),
                                          child: Icon(
                                            Icons.calendar_month,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            size: 48,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: const AlignmentDirectional(0, -1),
                                      child: AutoSizeText(
                                        _createdAgo ?? '',
                                        textAlign: TextAlign.center,
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              fontSize: 22,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
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
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(-1, -1),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                          child: Text(
                            'Conóceme',
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
                                  fontSize: 18,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(-1, 0),
                        child: AutoSizeText(
                          dogAboutMe ?? "No hay informacion",
                          textAlign: TextAlign.justify,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
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
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0, 0),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 18),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: dogBehaviour?.map((trait) {
                              return Container(
                                height: 35,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).primary,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  child: AutoSizeText(
                                    trait,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.lexend(
                                            fontWeight:
                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                          ),
                                          color: Colors.white,
                                          fontSize: 15,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                  ),
                                ),
                              );
                            }).toList() ?? [],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          height: MediaQuery.sizeOf(context).height * 0.065,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).alternate,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Align(
                                alignment: const AlignmentDirectional(-1, 0),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      10, 0, 0, 0),
                                  child: Icon(
                                    Icons.calendar_today_outlined,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 28,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                                child: AutoSizeText(
                                  //Esta mal --------------------------------------
                                  (dogAge != null ? '${dogAge} años' : '[age]'),
                                  maxLines: 1,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.lexend(
                                          fontWeight: FontWeight.normal,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        fontSize: 18,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          height: MediaQuery.sizeOf(context).height * 0.065,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).alternate,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Align(
                                  alignment: const AlignmentDirectional(-1, 0),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        10, 0, 0, 0),
                                    child: Icon(
                                      Icons.pets_outlined,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      8, 0, 0, 0),
                                  child: AutoSizeText(
                                    dogGender ?? '[gender]',
                                    maxLines: 1,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.lexend(
                                            fontWeight: FontWeight.normal,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          fontSize: 18,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.normal,
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
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          height: MediaQuery.sizeOf(context).height * 0.065,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).alternate,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Align(
                                  alignment: const AlignmentDirectional(-1, 0),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        10, 0, 0, 0),
                                    child: FaIcon(
                                      FontAwesomeIcons.dog,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      8, 0, 0, 0),
                                  child: AutoSizeText(
                                    dogSize?? '[size]',
                                    maxLines: 1,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.lexend(
                                            fontWeight: FontWeight.normal,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          fontSize: 18,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.normal,
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
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(-1, 0),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                          child: Text(
                            'Reseñas',
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  font: GoogleFonts.lexend(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).accent1,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                        
                      ),
                      if (_loading)
                        const Center(child: CircularProgressIndicator())
                      else if (_reviews.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            'Aún no hay reseñas para esta mascota.',
                            style: FlutterFlowTheme.of(context).bodyMedium,
                          ),
                        )
                      else
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final review = _reviews[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: ReviewDetailsCardWidget(
                                userName: review['user_name'] ?? 'Usuario',
                                rating: review['rating'] ?? 0,
                                comment: review['comments'] ?? '',
                                date: DateTime.parse(review['created_at']),
                                imageUrl: review['reviewer_photo'] ?? 'https://images.unsplash.com/photo-1604004555489-723a93d6ce74?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080', // puedes usar la foto del usuario si la tienes
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

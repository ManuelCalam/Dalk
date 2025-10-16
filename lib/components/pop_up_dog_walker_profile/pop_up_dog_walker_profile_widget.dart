import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/supabase/supabase.dart';
import 'package:dalk/common/review_details_card/review_details_card_widget.dart';

import 'pop_up_dog_walker_profile_model.dart';
export 'pop_up_dog_walker_profile_model.dart';

class PopUpDogWalkerProfileWidget extends StatefulWidget {
  final String walkerId;
  const PopUpDogWalkerProfileWidget({
    super.key,
    required this.walkerId,

    });

  @override
  State<PopUpDogWalkerProfileWidget> createState() =>
      _PopUpDogWalkerProfileWidgetState();
}

class _PopUpDogWalkerProfileWidgetState
    extends State<PopUpDogWalkerProfileWidget> {
  late PopUpDogWalkerProfileModel _model;

  // final int dogId = 12;
  // final int dogId = ;

  String get walkerId => widget.walkerId;
  String? walkerName;
  String? walkerUuid;
  String? walkerArea;
  int? walkerAge;
  String? walkerAboutMe;
  int? walkerFee;
  double? walkerAvgRating;
  int? walkerTotalWalks;
  String? walkerJoinedAgo;
  String? walkerLastWalk;
  String? walkerPhotoUrl;

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
    
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PopUpDogWalkerProfileModel());
    fetchWalkerData();
     _fetchReviews();
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }
  Future<void> fetchWalkerData() async {
    try {
      final response = await Supabase.instance.client
          .from('walkers_info')
          .select('uuid,name,working_area,age,about_me,fee,average_rating,total_walks,joined_at,last_walk_date,photo_url')
          .eq('uuid', walkerId ) 
          .maybeSingle();

      if (response != null) {
        setState(() {
          walkerName = response['name'];
          walkerUuid = response['uuid'];
          walkerArea = response['working_area'];
          walkerAge = response['age'];
          walkerAboutMe = response['about_me'];
          walkerFee = response['fee'] ?? '0';
          walkerAvgRating = (response['average_rating'] as num?)?.toDouble() ?? 0;
          walkerTotalWalks = response['total_walks'] as int?;
          walkerLastWalk = response['last_walk_date'];
          walkerPhotoUrl = response['photo_url'];

          // Calcular hace cuánto se unió a la app
          if (response['joined_at'] != null) {
            final joinedAt = DateTime.parse(response['joined_at']);
            final diff = DateTime.now().difference(joinedAt);

            if (diff.inDays < 1) {
              walkerJoinedAgo = '${diff.inHours} horas';
            } else if (diff.inDays < 30) {
              walkerJoinedAgo = '${diff.inDays} días';
            } else if (diff.inDays < 365) {
              walkerJoinedAgo = '${(diff.inDays / 30).floor()} meses';
            } else {
              walkerJoinedAgo = '${(diff.inDays / 365).floor()} años';
            }
          }
        });
      }
    } catch (e) {
      debugPrint(' Error al obtener datos del paseador: $e');
    }
  }

  Future<void> _fetchReviews() async {
  try {
      final response = await supabase
          .from('reviews')
          .select('id, rating, walk_id, comments, created_at, author_id, reviewer_photo, users:author_id (name)')
          .eq('reviewed_user_id', walkerId)
          .order('created_at', ascending: false);


      if (response.isEmpty) {
        print('No reviews found');
      }

      setState(() {
        _reviews = response.map<Map<String, dynamic>>((review) {
          print('Review item: $review');
          return {
            'user_name': review['users']?['name'] ?? 'Usuario',
            'rating': review['rating'],
            'comments': review['comments'],
            'created_at': review['created_at'],
            'walk_id': review['walk_id'], 
            'reviewer_photo': review['reviewer_photo'],
          };
        }).toList();
        _loading = false;
      });
    } catch (e) {
      print('Error fetching reviews: $e');
      setState(() {
        _loading = false;
        _reviews = [];
      });
    }
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
                                walkerPhotoUrl?? 'https://picsum.photos/seed/854/600',
                                fit: BoxFit.cover,
                              ),
                            ),
                            AutoSizeText(
                              walkerName?? 'Nombre',
                              textAlign: TextAlign.center,
                              maxLines: 1,
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
                              walkerArea?? 'Colonia Providencia',
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
                                        walkerAvgRating.toString()?? '0',
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
                                        walkerTotalWalks != null 
                                          ? '${walkerTotalWalks} Viajes' 
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
                                        walkerJoinedAgo?? 'mes',
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
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 13),
                          child: AutoSizeText(
                            walkerAboutMe?? 'No hay información disponible.' ,
                            textAlign: TextAlign.justify,
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
                                  (walkerAge != null ? '${walkerAge} años' : '[age]'),
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
                                    child: Icon(
                                      Icons.monetization_on_outlined,
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
                                    (walkerFee != null ? '\$${walkerFee} ' : '[Fee]'),
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
                            'Aún no hay reseñas para este paseador.',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                            ),
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
                                imageUrl: review['reviewer_photo'] ?? 'https://images.unsplash.com/photo-1604004555489-723a93d6ce74?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080',
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

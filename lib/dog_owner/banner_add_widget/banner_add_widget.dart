import 'package:dalk/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  final String adUnitId; 
  final double maxWidth; 

  const BannerAdWidget({
    super.key, 
    required this.adUnitId, 
    required this.maxWidth,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // Usamos una altura predeterminada o calculada.
  double _adHeight = 0.0; 

  @override
  void initState() {
    super.initState();
    _loadAdaptiveAd();
  }

  void _loadAdaptiveAd() async {
    final AdSize? adaptiveSize = await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait, 
      widget.maxWidth.toInt(), 
    );

    if (adaptiveSize == null) {
      return; 
    }

    _adHeight = adaptiveSize.height.toDouble();

    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: adaptiveSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose(); 
          _bannerAd = null;
          setState(() {
            _isLoaded = false;
          });
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _adHeight, 
        child: AdWidget(ad: _bannerAd!),
      );
    } // 2. ANUNCIO NO CARGADO (o falló), pero la altura ya se calculó
    if (_adHeight > 0.0) {
      return Container(
        width: widget.maxWidth,
        height: _adHeight,
        color: FlutterFlowTheme.of(context).tertiary, 
        child: Center(
          child: SizedBox(
            width: 20, 
            height: 20, 
            child: CircularProgressIndicator(strokeWidth: 2.0, color: FlutterFlowTheme.of(context).primary),
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
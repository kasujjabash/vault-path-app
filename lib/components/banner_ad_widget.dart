import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

/// Reusable banner ad component for the app
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAd();

    // Add timeout for ad loading
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && !_isLoaded && _errorMessage.isEmpty) {
        debugPrint('⏰ Banner ad loading timeout - retrying...');
        _retryLoadAd();
      }
    });
  }

  void _loadAd() {
    final adUnitId = AdService.bannerAdUnitId;
    debugPrint('Loading banner ad with unit ID: $adUnitId');

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ Banner ad loaded successfully');
          if (mounted) {
            setState(() {
              _isLoaded = true;
              _errorMessage = '';
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('❌ Failed to load banner ad: ${err.message}');
          debugPrint('Error code: ${err.code}');
          if (mounted) {
            setState(() {
              _errorMessage = 'Ad failed to load: ${err.message}';
            });
          }
          ad.dispose();
        },
        onAdOpened: (ad) {
          debugPrint('📱 Banner ad opened');
        },
        onAdClosed: (ad) {
          debugPrint('🔒 Banner ad closed');
        },
        onAdImpression: (ad) {
          debugPrint('👁️ Banner ad impression recorded');
        },
        onAdClicked: (ad) {
          debugPrint('👆 Banner ad clicked');
        },
      ),
    );

    _bannerAd!.load();
  }

  void _retryLoadAd() {
    debugPrint('🔄 Retrying banner ad load...');
    _bannerAd?.dispose();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd != null && _isLoaded) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        ),
      );
    } else if (_errorMessage.isNotEmpty) {
      // Hide ad space completely when offline/error
      return const SizedBox.shrink();
    } else {
      // Hide loading space completely when not loaded
      return const SizedBox.shrink();
    }
  }
}

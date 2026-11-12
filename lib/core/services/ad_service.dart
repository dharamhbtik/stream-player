import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_constants.dart';

/// Service for managing AdMob ads
class AdService {
  static AdService? _instance;
  
  InterstitialAd? _interstitialAd;
  bool _isInterstitialReady = false;
  int _navigationCount = 0;

  AdService._();

  static AdService get instance {
    _instance ??= AdService._();
    return _instance!;
  }

  /// Load an interstitial ad
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
          
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialReady = false;
              loadInterstitialAd(); // Preload next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialReady = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialReady = false;
        },
      ),
    );
  }

  /// Show interstitial ad based on navigation frequency
  void onNavigation({bool isPremium = false}) {
    if (isPremium) return;
    
    _navigationCount++;
    
    if (_navigationCount >= AdConstants.interstitialFrequency) {
      showInterstitialAd();
      _navigationCount = 0;
    }
  }

  /// Force show interstitial ad
  void showInterstitialAd() {
    if (_isInterstitialReady && _interstitialAd != null) {
      _interstitialAd!.show();
    }
  }

  /// Create a banner ad
  BannerAd createBannerAd({
    required Function(Ad) onLoaded,
    required Function(Ad, LoadAdError) onFailed,
  }) {
    return BannerAd(
      adUnitId: AdConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: onFailed,
      ),
    );
  }

  /// Dispose resources
  void dispose() {
    _interstitialAd?.dispose();
  }
}

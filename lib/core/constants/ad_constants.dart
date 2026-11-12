import 'dart:io';

/// AdMob configuration constants
class AdConstants {
  AdConstants._();

  // Test Ad IDs (Replace with production IDs before release)
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test Banner
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test Interstitial
    }
    return '';
  }

  // Ad display settings
  static const int interstitialFrequency = 5; // Show every N navigations
  static const bool showAdsOnPlaylistScreen = true;
  static const bool showAdsOnPlayerScreen = false; // Never during playback
}

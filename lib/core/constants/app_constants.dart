/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Zenith IPTV Player';
  static const String appTagline = 'M3U Playlist Player';
  static const String appVersion = '1.0.0';
  
  // Legal
  static const String dmcaEmail = 'dmca@zenithcodestudio.com';
  static const String privacyPolicyUrl = 'https://zenithcodestudio.com/privacy';
  static const String termsOfUseUrl = 'https://zenithcodestudio.com/terms';
  
  // Educational Resources (Policy-Safe)
  static const List<Map<String, String>> educationalResources = [
    {
      'title': 'IPTV-org GitHub Repository',
      'description': 'Learn about M3U playlist formats and organization',
      'url': 'https://github.com/iptv-org/iptv/tree/master',
    },
    {
      'title': 'Free-TV IPTV Repository',
      'description': 'Explore community-maintained playlist documentation',
      'url': 'https://github.com/Free-TV/IPTV',
    },
    {
      'title': 'M3U Playlist Format Guide',
      'description': 'Understanding M3U playlist structure and metadata',
      'url': 'https://www.comfortskillz.com/2025/12/updated-m3u-playlist-urls-for-iptv-players.html',
    },
  ];
  
  // UI Constants
  static const double channelLogoSize = 48.0;
  static const double cardScaleOnTap = 1.04;
  static const int cardAnimationDuration = 180;
  static const int fadeInAnimationDuration = 300;
  static const int playerControlsHideDelay = 3000;
  static const int seekDuration = 10; // seconds
  static const int searchDebounceMs = 300;
  
  // Storage Keys
  static const String hasSeenDisclaimerKey = 'has_seen_disclaimer';
  static const String isPremiumKey = 'is_premium';
  static const String themeKey = 'theme_mode';
  static const String viewModeKey = 'view_mode';
  
  // Playlist Limits (Free vs Premium)
  static const int freePlaylistLimit = 1;
  static const int freeChannelLimit = 500;
}

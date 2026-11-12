import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';

/// App settings state
class AppSettings {
  final bool hasSeenDisclaimer;
  final bool isPremium;
  final bool isDarkMode;
  final bool isGridView;
  final int interstitialCounter;

  const AppSettings({
    this.hasSeenDisclaimer = false,
    this.isPremium = false,
    this.isDarkMode = true,
    this.isGridView = true,
    this.interstitialCounter = 0,
  });

  AppSettings copyWith({
    bool? hasSeenDisclaimer,
    bool? isPremium,
    bool? isDarkMode,
    bool? isGridView,
    int? interstitialCounter,
  }) {
    return AppSettings(
      hasSeenDisclaimer: hasSeenDisclaimer ?? this.hasSeenDisclaimer,
      isPremium: isPremium ?? this.isPremium,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isGridView: isGridView ?? this.isGridView,
      interstitialCounter: interstitialCounter ?? this.interstitialCounter,
    );
  }
}

/// Settings notifier for app-wide settings
class SettingsNotifier extends StateNotifier<AppSettings> {
  static const String _boxName = 'settings';
  Box? _box;

  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _box = await Hive.openBox(_boxName);
    
    state = AppSettings(
      hasSeenDisclaimer: _box?.get(AppConstants.hasSeenDisclaimerKey, defaultValue: false) ?? false,
      isPremium: _box?.get(AppConstants.isPremiumKey, defaultValue: false) ?? false,
      isDarkMode: _box?.get(AppConstants.themeKey, defaultValue: true) ?? true,
      isGridView: _box?.get(AppConstants.viewModeKey, defaultValue: true) ?? true,
    );
  }

  Future<void> setDisclaimerSeen() async {
    await _box?.put(AppConstants.hasSeenDisclaimerKey, true);
    state = state.copyWith(hasSeenDisclaimer: true);
  }

  Future<void> setPremium(bool value) async {
    await _box?.put(AppConstants.isPremiumKey, value);
    state = state.copyWith(isPremium: value);
  }

  Future<void> toggleTheme() async {
    final newValue = !state.isDarkMode;
    await _box?.put(AppConstants.themeKey, newValue);
    state = state.copyWith(isDarkMode: newValue);
  }

  Future<void> toggleViewMode() async {
    final newValue = !state.isGridView;
    await _box?.put(AppConstants.viewModeKey, newValue);
    state = state.copyWith(isGridView: newValue);
  }

  void incrementInterstitialCounter() {
    state = state.copyWith(interstitialCounter: state.interstitialCounter + 1);
  }

  void resetInterstitialCounter() {
    state = state.copyWith(interstitialCounter: 0);
  }
}

/// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

/// Theme mode provider for easy access
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).isDarkMode;
});

/// Grid view mode provider
final isGridViewProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).isGridView;
});

/// Premium status provider
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).isPremium;
});

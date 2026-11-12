import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/service_providers.dart';
import '../../domain/entities/channel.dart';
import '../../domain/entities/playlist.dart';

/// State class for playlist management
class PlaylistState {
  final List<Playlist> playlists;
  final List<Channel> channels;
  final List<Channel> favoriteChannels;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const PlaylistState({
    this.playlists = const [],
    this.channels = const [],
    this.favoriteChannels = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  PlaylistState copyWith({
    List<Playlist>? playlists,
    List<Channel>? channels,
    List<Channel>? favoriteChannels,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return PlaylistState(
      playlists: playlists ?? this.playlists,
      channels: channels ?? this.channels,
      favoriteChannels: favoriteChannels ?? this.favoriteChannels,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  /// Get channels grouped by category
  Map<String, List<Channel>> get channelsByCategory {
    final map = <String, List<Channel>>{};
    for (final channel in channels) {
      final category = channel.displayCategory;
      map.putIfAbsent(category, () => []).add(channel);
    }
    return map;
  }

  /// Get channels grouped by language
  Map<String, List<Channel>> get channelsByLanguage {
    final map = <String, List<Channel>>{};
    for (final channel in channels) {
      final language = channel.displayLanguage;
      if (language != 'Unknown') {
        map.putIfAbsent(language, () => []).add(channel);
      }
    }
    return map;
  }

  /// Get channels grouped by country
  Map<String, List<Channel>> get channelsByCountry {
    final map = <String, List<Channel>>{};
    for (final channel in channels) {
      final country = channel.displayCountry;
      if (country != 'Unknown') {
        map.putIfAbsent(country, () => []).add(channel);
      }
    }
    return map;
  }

  /// Get unique categories
  List<String> get categories {
    final cats = channels.map((c) => c.displayCategory).toSet().toList();
    cats.sort();
    return cats;
  }

  /// Get unique languages
  List<String> get languages {
    final langs = channels
        .where((c) => c.language != null && c.language!.isNotEmpty)
        .map((c) => c.displayLanguage)
        .toSet()
        .toList();
    langs.sort();
    return langs;
  }

  /// Get unique countries
  List<String> get countries {
    final ctrs = channels
        .where((c) => c.country != null && c.country!.isNotEmpty)
        .map((c) => c.displayCountry)
        .toSet()
        .toList();
    ctrs.sort();
    return ctrs;
  }
}

/// Playlist state notifier
class PlaylistNotifier extends StateNotifier<PlaylistState> {
  final Ref ref;

  PlaylistNotifier(this.ref) : super(const PlaylistState()) {
    loadPlaylists();
  }

  /// Load all playlists and channels
  Future<void> loadPlaylists() async {
    state = state.copyWith(isLoading: true);

    final repository = ref.read(playlistRepositoryProvider);
    
    final playlistsResult = await repository.getAllPlaylists();
    final channelsResult = await repository.getAllChannels();
    final favoritesResult = await repository.getFavoriteChannels();

    playlistsResult.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (playlists) {
        channelsResult.fold(
          (failure) => state = state.copyWith(
            isLoading: false,
            playlists: playlists,
            errorMessage: failure.message,
          ),
          (channels) {
            favoritesResult.fold(
              (failure) => state = state.copyWith(
                isLoading: false,
                playlists: playlists,
                channels: channels,
              ),
              (favorites) => state = state.copyWith(
                isLoading: false,
                playlists: playlists,
                channels: channels,
                favoriteChannels: favorites,
              ),
            );
          },
        );
      },
    );
  }

  /// Add playlist from URL
  Future<bool> addPlaylistFromUrl(String url, String name) async {
    state = state.copyWith(isLoading: true);

    final repository = ref.read(playlistRepositoryProvider);
    final result = await repository.addPlaylistFromUrl(url: url, name: name);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (parsed) {
        final newPlaylists = [...state.playlists, parsed.playlist];
        final newChannels = [...state.channels, ...parsed.channels];
        state = state.copyWith(
          isLoading: false,
          playlists: newPlaylists,
          channels: newChannels,
          successMessage: 'Playlist added with ${parsed.channels.length} channels',
        );
        return true;
      },
    );
  }

  /// Add playlist from file
  Future<bool> addPlaylistFromFile(String filePath, String name) async {
    state = state.copyWith(isLoading: true);

    final repository = ref.read(playlistRepositoryProvider);
    final result = await repository.addPlaylistFromFile(
      filePath: filePath,
      name: name,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (parsed) {
        final newPlaylists = [...state.playlists, parsed.playlist];
        final newChannels = [...state.channels, ...parsed.channels];
        state = state.copyWith(
          isLoading: false,
          playlists: newPlaylists,
          channels: newChannels,
          successMessage: 'Playlist added with ${parsed.channels.length} channels',
        );
        return true;
      },
    );
  }

  /// Delete a playlist
  Future<void> deletePlaylist(String playlistId) async {
    state = state.copyWith(isLoading: true);

    final repository = ref.read(playlistRepositoryProvider);
    final result = await repository.deletePlaylist(playlistId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (_) {
        final newPlaylists = state.playlists
            .where((p) => p.id != playlistId)
            .toList();
        final newChannels = state.channels
            .where((c) => c.playlistId != playlistId)
            .toList();
        state = state.copyWith(
          isLoading: false,
          playlists: newPlaylists,
          channels: newChannels,
          successMessage: 'Playlist deleted',
        );
      },
    );
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(Channel channel) async {
    final repository = ref.read(playlistRepositoryProvider);
    final newStatus = !channel.isFavorite;
    
    final result = await repository.toggleFavorite(channel.id, newStatus);

    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) {
        final updatedChannels = state.channels.map((c) {
          if (c.id == channel.id) {
            return c.copyWith(isFavorite: newStatus);
          }
          return c;
        }).toList();

        final updatedFavorites = newStatus
            ? [...state.favoriteChannels, channel.copyWith(isFavorite: true)]
            : state.favoriteChannels.where((c) => c.id != channel.id).toList();

        state = state.copyWith(
          channels: updatedChannels,
          favoriteChannels: updatedFavorites,
        );
      },
    );
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Clear success message
  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }
}

/// Main playlist provider
final playlistProvider = StateNotifierProvider<PlaylistNotifier, PlaylistState>((ref) {
  return PlaylistNotifier(ref);
});

/// Filtered channels provider for search
final filteredChannelsProvider = Provider.family<List<Channel>, String>((ref, query) {
  final state = ref.watch(playlistProvider);
  if (query.isEmpty) return state.channels;
  
  final lowerQuery = query.toLowerCase();
  return state.channels.where((channel) {
    return channel.name.toLowerCase().contains(lowerQuery) ||
           (channel.groupTitle?.toLowerCase().contains(lowerQuery) ?? false) ||
           (channel.language?.toLowerCase().contains(lowerQuery) ?? false) ||
           (channel.country?.toLowerCase().contains(lowerQuery) ?? false);
  }).toList();
});

/// Channels by category provider
final channelsByCategoryProvider = Provider.family<List<Channel>, String>((ref, category) {
  final state = ref.watch(playlistProvider);
  return state.channels.where((c) => c.displayCategory == category).toList();
});

/// Channels by language provider
final channelsByLanguageProvider = Provider.family<List<Channel>, String>((ref, language) {
  final state = ref.watch(playlistProvider);
  return state.channels.where((c) => c.displayLanguage == language).toList();
});

/// Channels by country provider
final channelsByCountryProvider = Provider.family<List<Channel>, String>((ref, country) {
  final state = ref.watch(playlistProvider);
  return state.channels.where((c) => c.displayCountry == country).toList();
});

import 'package:equatable/equatable.dart';
import 'channel.dart';

/// Represents a user-added playlist
class Playlist extends Equatable {
  final String id;
  final String name;
  final String sourceUrl; // URL or local file path
  final bool isLocal; // true for local files, false for URLs
  final DateTime addedAt;
  final DateTime? lastUpdated;
  final int channelCount;
  final List<String> categories;
  final List<String> languages;
  final List<String> countries;

  const Playlist({
    required this.id,
    required this.name,
    required this.sourceUrl,
    this.isLocal = false,
    required this.addedAt,
    this.lastUpdated,
    this.channelCount = 0,
    this.categories = const [],
    this.languages = const [],
    this.countries = const [],
  });

  Playlist copyWith({
    String? id,
    String? name,
    String? sourceUrl,
    bool? isLocal,
    DateTime? addedAt,
    DateTime? lastUpdated,
    int? channelCount,
    List<String>? categories,
    List<String>? languages,
    List<String>? countries,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      isLocal: isLocal ?? this.isLocal,
      addedAt: addedAt ?? this.addedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      channelCount: channelCount ?? this.channelCount,
      categories: categories ?? this.categories,
      languages: languages ?? this.languages,
      countries: countries ?? this.countries,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        sourceUrl,
        isLocal,
        addedAt,
        lastUpdated,
        channelCount,
        categories,
        languages,
        countries,
      ];
}

/// Parsed result containing playlist metadata and channels
class ParsedPlaylist {
  final Playlist playlist;
  final List<Channel> channels;

  const ParsedPlaylist({
    required this.playlist,
    required this.channels,
  });
}

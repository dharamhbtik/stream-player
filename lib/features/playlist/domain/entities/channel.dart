import 'package:equatable/equatable.dart';

/// Represents a channel/stream from an M3U playlist
class Channel extends Equatable {
  final String id;
  final String name;
  final String streamUrl;
  final String? logoUrl;
  final String? groupTitle;
  final String? language;
  final String? country;
  final String playlistId;
  final bool isFavorite;
  final DateTime? lastWatched;

  const Channel({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.logoUrl,
    this.groupTitle,
    this.language,
    this.country,
    required this.playlistId,
    this.isFavorite = false,
    this.lastWatched,
  });

  Channel copyWith({
    String? id,
    String? name,
    String? streamUrl,
    String? logoUrl,
    String? groupTitle,
    String? language,
    String? country,
    String? playlistId,
    bool? isFavorite,
    DateTime? lastWatched,
  }) {
    return Channel(
      id: id ?? this.id,
      name: name ?? this.name,
      streamUrl: streamUrl ?? this.streamUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      groupTitle: groupTitle ?? this.groupTitle,
      language: language ?? this.language,
      country: country ?? this.country,
      playlistId: playlistId ?? this.playlistId,
      isFavorite: isFavorite ?? this.isFavorite,
      lastWatched: lastWatched ?? this.lastWatched,
    );
  }

  /// Display-friendly category name
  String get displayCategory => groupTitle ?? 'Uncategorized';

  /// Display-friendly language name
  String get displayLanguage => language ?? 'Unknown';

  /// Display-friendly country name
  String get displayCountry => country ?? 'Unknown';

  @override
  List<Object?> get props => [
        id,
        name,
        streamUrl,
        logoUrl,
        groupTitle,
        language,
        country,
        playlistId,
        isFavorite,
        lastWatched,
      ];
}

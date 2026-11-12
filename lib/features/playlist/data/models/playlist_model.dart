import 'package:hive/hive.dart';
import '../../domain/entities/playlist.dart';

part 'playlist_model.g.dart';

@HiveType(typeId: 1)
class PlaylistModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String sourceUrl;

  @HiveField(3)
  final bool isLocal;

  @HiveField(4)
  final DateTime addedAt;

  @HiveField(5)
  DateTime? lastUpdated;

  @HiveField(6)
  int channelCount;

  @HiveField(7)
  List<String> categories;

  @HiveField(8)
  List<String> languages;

  @HiveField(9)
  List<String> countries;

  PlaylistModel({
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

  /// Convert to domain entity
  Playlist toEntity() {
    return Playlist(
      id: id,
      name: name,
      sourceUrl: sourceUrl,
      isLocal: isLocal,
      addedAt: addedAt,
      lastUpdated: lastUpdated,
      channelCount: channelCount,
      categories: categories,
      languages: languages,
      countries: countries,
    );
  }

  /// Create from domain entity
  factory PlaylistModel.fromEntity(Playlist playlist) {
    return PlaylistModel(
      id: playlist.id,
      name: playlist.name,
      sourceUrl: playlist.sourceUrl,
      isLocal: playlist.isLocal,
      addedAt: playlist.addedAt,
      lastUpdated: playlist.lastUpdated,
      channelCount: playlist.channelCount,
      categories: playlist.categories,
      languages: playlist.languages,
      countries: playlist.countries,
    );
  }
}

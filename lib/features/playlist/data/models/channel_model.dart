import 'package:hive/hive.dart';
import '../../domain/entities/channel.dart';

part 'channel_model.g.dart';

@HiveType(typeId: 0)
class ChannelModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String streamUrl;

  @HiveField(3)
  final String? logoUrl;

  @HiveField(4)
  final String? groupTitle;

  @HiveField(5)
  final String? language;

  @HiveField(6)
  final String? country;

  @HiveField(7)
  final String playlistId;

  @HiveField(8)
  bool isFavorite;

  @HiveField(9)
  DateTime? lastWatched;

  ChannelModel({
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

  /// Convert to domain entity
  Channel toEntity() {
    return Channel(
      id: id,
      name: name,
      streamUrl: streamUrl,
      logoUrl: logoUrl,
      groupTitle: groupTitle,
      language: language,
      country: country,
      playlistId: playlistId,
      isFavorite: isFavorite,
      lastWatched: lastWatched,
    );
  }

  /// Create from domain entity
  factory ChannelModel.fromEntity(Channel channel) {
    return ChannelModel(
      id: channel.id,
      name: channel.name,
      streamUrl: channel.streamUrl,
      logoUrl: channel.logoUrl,
      groupTitle: channel.groupTitle,
      language: channel.language,
      country: channel.country,
      playlistId: channel.playlistId,
      isFavorite: channel.isFavorite,
      lastWatched: channel.lastWatched,
    );
  }
}

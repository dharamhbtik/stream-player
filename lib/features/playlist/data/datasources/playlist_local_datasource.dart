import 'package:hive_flutter/hive_flutter.dart';
import '../models/channel_model.dart';
import '../models/playlist_model.dart';
import '../../../../core/errors/exceptions.dart';

/// Local data source for playlist and channel storage using Hive
abstract class PlaylistLocalDataSource {
  Future<void> savePlaylist(PlaylistModel playlist);
  Future<void> deletePlaylist(String playlistId);
  Future<List<PlaylistModel>> getAllPlaylists();
  Future<PlaylistModel?> getPlaylist(String playlistId);
  
  Future<void> saveChannels(List<ChannelModel> channels);
  Future<void> deleteChannelsByPlaylist(String playlistId);
  Future<List<ChannelModel>> getChannelsByPlaylist(String playlistId);
  Future<List<ChannelModel>> getAllChannels();
  Future<List<ChannelModel>> getFavoriteChannels();
  Future<void> toggleFavorite(String channelId, bool isFavorite);
  Future<void> updateLastWatched(String channelId);
}

class PlaylistLocalDataSourceImpl implements PlaylistLocalDataSource {
  static const String playlistBoxName = 'playlists';
  static const String channelBoxName = 'channels';

  Box<PlaylistModel>? _playlistBox;
  Box<ChannelModel>? _channelBox;

  Future<Box<PlaylistModel>> get playlistBox async {
    _playlistBox ??= await Hive.openBox<PlaylistModel>(playlistBoxName);
    return _playlistBox!;
  }

  Future<Box<ChannelModel>> get channelBox async {
    _channelBox ??= await Hive.openBox<ChannelModel>(channelBoxName);
    return _channelBox!;
  }

  @override
  Future<void> savePlaylist(PlaylistModel playlist) async {
    try {
      final box = await playlistBox;
      await box.put(playlist.id, playlist);
    } catch (e) {
      throw CacheException(message: 'Failed to save playlist: $e');
    }
  }

  @override
  Future<void> deletePlaylist(String playlistId) async {
    try {
      final box = await playlistBox;
      await box.delete(playlistId);
      // Also delete associated channels
      await deleteChannelsByPlaylist(playlistId);
    } catch (e) {
      throw CacheException(message: 'Failed to delete playlist: $e');
    }
  }

  @override
  Future<List<PlaylistModel>> getAllPlaylists() async {
    try {
      final box = await playlistBox;
      return box.values.toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get playlists: $e');
    }
  }

  @override
  Future<PlaylistModel?> getPlaylist(String playlistId) async {
    try {
      final box = await playlistBox;
      return box.get(playlistId);
    } catch (e) {
      throw CacheException(message: 'Failed to get playlist: $e');
    }
  }

  @override
  Future<void> saveChannels(List<ChannelModel> channels) async {
    try {
      final box = await channelBox;
      final map = <String, ChannelModel>{};
      for (final channel in channels) {
        map[channel.id] = channel;
      }
      await box.putAll(map);
    } catch (e) {
      throw CacheException(message: 'Failed to save channels: $e');
    }
  }

  @override
  Future<void> deleteChannelsByPlaylist(String playlistId) async {
    try {
      final box = await channelBox;
      final keysToDelete = box.values
          .where((channel) => channel.playlistId == playlistId)
          .map((channel) => channel.id)
          .toList();
      await box.deleteAll(keysToDelete);
    } catch (e) {
      throw CacheException(message: 'Failed to delete channels: $e');
    }
  }

  @override
  Future<List<ChannelModel>> getChannelsByPlaylist(String playlistId) async {
    try {
      final box = await channelBox;
      return box.values
          .where((channel) => channel.playlistId == playlistId)
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get channels: $e');
    }
  }

  @override
  Future<List<ChannelModel>> getAllChannels() async {
    try {
      final box = await channelBox;
      return box.values.toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get all channels: $e');
    }
  }

  @override
  Future<List<ChannelModel>> getFavoriteChannels() async {
    try {
      final box = await channelBox;
      return box.values.where((channel) => channel.isFavorite).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get favorite channels: $e');
    }
  }

  @override
  Future<void> toggleFavorite(String channelId, bool isFavorite) async {
    try {
      final box = await channelBox;
      final channel = box.get(channelId);
      if (channel != null) {
        channel.isFavorite = isFavorite;
        await channel.save();
      }
    } catch (e) {
      throw CacheException(message: 'Failed to toggle favorite: $e');
    }
  }

  @override
  Future<void> updateLastWatched(String channelId) async {
    try {
      final box = await channelBox;
      final channel = box.get(channelId);
      if (channel != null) {
        channel.lastWatched = DateTime.now();
        await channel.save();
      }
    } catch (e) {
      throw CacheException(message: 'Failed to update last watched: $e');
    }
  }
}

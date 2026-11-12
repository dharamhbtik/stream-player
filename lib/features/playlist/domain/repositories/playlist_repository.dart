import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/channel.dart';
import '../entities/playlist.dart';

/// Abstract repository interface for playlist operations
abstract class PlaylistRepository {
  /// Add a new playlist from a URL (user manually pasted)
  Future<Either<Failure, ParsedPlaylist>> addPlaylistFromUrl({
    required String url,
    required String name,
  });

  /// Add a new playlist from a local file
  Future<Either<Failure, ParsedPlaylist>> addPlaylistFromFile({
    required String filePath,
    required String name,
  });

  /// Delete a playlist and its channels
  Future<Either<Failure, Unit>> deletePlaylist(String playlistId);

  /// Get all saved playlists
  Future<Either<Failure, List<Playlist>>> getAllPlaylists();

  /// Get channels for a specific playlist
  Future<Either<Failure, List<Channel>>> getChannelsByPlaylist(String playlistId);

  /// Get all channels across all playlists
  Future<Either<Failure, List<Channel>>> getAllChannels();

  /// Get favorite channels
  Future<Either<Failure, List<Channel>>> getFavoriteChannels();

  /// Toggle channel favorite status
  Future<Either<Failure, Unit>> toggleFavorite(String channelId, bool isFavorite);

  /// Update last watched timestamp
  Future<Either<Failure, Unit>> updateLastWatched(String channelId);

  /// Refresh a playlist from its source
  Future<Either<Failure, ParsedPlaylist>> refreshPlaylist(String playlistId);
}

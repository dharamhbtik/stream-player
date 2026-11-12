import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/m3u_parser.dart';
import '../../domain/entities/channel.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../datasources/playlist_local_datasource.dart';
import '../datasources/playlist_remote_datasource.dart';
import '../models/channel_model.dart';
import '../models/playlist_model.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistLocalDataSource localDataSource;
  final PlaylistRemoteDataSource remoteDataSource;
  final M3uParser parser;
  final Uuid uuid;

  PlaylistRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.parser,
    required this.uuid,
  });

  @override
  Future<Either<Failure, ParsedPlaylist>> addPlaylistFromUrl({
    required String url,
    required String name,
  }) async {
    try {
      // Fetch playlist content from URL
      final content = await remoteDataSource.fetchPlaylistContent(url);
      
      // Validate content
      if (!parser.validateContent(content)) {
        return const Left(ValidationFailure(
          message: 'Invalid M3U playlist format',
        ));
      }

      // Parse the playlist
      final playlistId = uuid.v4();
      final parsedPlaylist = parser.parse(
        content: content,
        playlistId: playlistId,
        playlistName: name,
        sourceUrl: url,
        isLocal: false,
      );

      // Save to local storage
      await localDataSource.savePlaylist(
        PlaylistModel.fromEntity(parsedPlaylist.playlist),
      );
      await localDataSource.saveChannels(
        parsedPlaylist.channels.map((c) => ChannelModel.fromEntity(c)).toList(),
      );

      return Right(parsedPlaylist);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode?.toString()));
    } on ParsingException catch (e) {
      return Left(ParsingFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ParsedPlaylist>> addPlaylistFromFile({
    required String filePath,
    required String name,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return const Left(ValidationFailure(message: 'File not found'));
      }

      final content = await file.readAsString();
      
      // Validate content
      if (!parser.validateContent(content)) {
        return const Left(ValidationFailure(
          message: 'Invalid M3U playlist format',
        ));
      }

      // Parse the playlist
      final playlistId = uuid.v4();
      final parsedPlaylist = parser.parse(
        content: content,
        playlistId: playlistId,
        playlistName: name,
        sourceUrl: filePath,
        isLocal: true,
      );

      // Save to local storage
      await localDataSource.savePlaylist(
        PlaylistModel.fromEntity(parsedPlaylist.playlist),
      );
      await localDataSource.saveChannels(
        parsedPlaylist.channels.map((c) => ChannelModel.fromEntity(c)).toList(),
      );

      return Right(parsedPlaylist);
    } on ParsingException catch (e) {
      return Left(ParsingFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to read file: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deletePlaylist(String playlistId) async {
    try {
      await localDataSource.deletePlaylist(playlistId);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Playlist>>> getAllPlaylists() async {
    try {
      final playlists = await localDataSource.getAllPlaylists();
      return Right(playlists.map((p) => p.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Channel>>> getChannelsByPlaylist(String playlistId) async {
    try {
      final channels = await localDataSource.getChannelsByPlaylist(playlistId);
      return Right(channels.map((c) => c.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Channel>>> getAllChannels() async {
    try {
      final channels = await localDataSource.getAllChannels();
      return Right(channels.map((c) => c.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Channel>>> getFavoriteChannels() async {
    try {
      final channels = await localDataSource.getFavoriteChannels();
      return Right(channels.map((c) => c.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleFavorite(String channelId, bool isFavorite) async {
    try {
      await localDataSource.toggleFavorite(channelId, isFavorite);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateLastWatched(String channelId) async {
    try {
      await localDataSource.updateLastWatched(channelId);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, ParsedPlaylist>> refreshPlaylist(String playlistId) async {
    try {
      final playlist = await localDataSource.getPlaylist(playlistId);
      if (playlist == null) {
        return const Left(CacheFailure(message: 'Playlist not found'));
      }

      if (playlist.isLocal) {
        return addPlaylistFromFile(
          filePath: playlist.sourceUrl,
          name: playlist.name,
        );
      } else {
        // Delete old channels first
        await localDataSource.deleteChannelsByPlaylist(playlistId);
        
        // Fetch and parse again
        final content = await remoteDataSource.fetchPlaylistContent(playlist.sourceUrl);
        final parsedPlaylist = parser.parse(
          content: content,
          playlistId: playlistId,
          playlistName: playlist.name,
          sourceUrl: playlist.sourceUrl,
          isLocal: false,
        );

        // Update playlist
        await localDataSource.savePlaylist(
          PlaylistModel.fromEntity(parsedPlaylist.playlist),
        );
        await localDataSource.saveChannels(
          parsedPlaylist.channels.map((c) => ChannelModel.fromEntity(c)).toList(),
        );

        return Right(parsedPlaylist);
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to refresh playlist: $e'));
    }
  }
}

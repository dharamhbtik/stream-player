import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/m3u_parser.dart';
import '../../features/playlist/data/datasources/playlist_local_datasource.dart';
import '../../features/playlist/data/datasources/playlist_remote_datasource.dart';
import '../../features/playlist/data/repositories/playlist_repository_impl.dart';
import '../../features/playlist/domain/repositories/playlist_repository.dart';

/// Dio HTTP client provider
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
});

/// UUID generator provider
final uuidProvider = Provider<Uuid>((ref) => const Uuid());

/// M3U Parser provider
final m3uParserProvider = Provider<M3uParser>((ref) => M3uParser());

/// Local data source provider
final playlistLocalDataSourceProvider = Provider<PlaylistLocalDataSource>((ref) {
  return PlaylistLocalDataSourceImpl();
});

/// Remote data source provider
final playlistRemoteDataSourceProvider = Provider<PlaylistRemoteDataSource>((ref) {
  return PlaylistRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

/// Playlist repository provider
final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return PlaylistRepositoryImpl(
    localDataSource: ref.watch(playlistLocalDataSourceProvider),
    remoteDataSource: ref.watch(playlistRemoteDataSourceProvider),
    parser: ref.watch(m3uParserProvider),
    uuid: ref.watch(uuidProvider),
  );
});

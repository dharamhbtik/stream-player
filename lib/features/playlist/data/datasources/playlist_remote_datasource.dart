import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';

/// Remote data source for fetching playlist content from URLs
abstract class PlaylistRemoteDataSource {
  Future<String> fetchPlaylistContent(String url);
  Future<bool> validateUrl(String url);
}

class PlaylistRemoteDataSourceImpl implements PlaylistRemoteDataSource {
  final Dio dio;

  PlaylistRemoteDataSourceImpl({required this.dio});

  @override
  Future<String> fetchPlaylistContent(String url) async {
    try {
      final response = await dio.get<String>(
        url,
        options: Options(
          responseType: ResponseType.plain,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 15),
          headers: {
            'Accept': '*/*',
            'User-Agent': 'ZenithIPTVPlayer/1.0',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data!;
      } else {
        throw ServerException(
          message: 'Failed to fetch playlist',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'No internet connection');
      } else {
        throw ServerException(
          message: e.message ?? 'Failed to fetch playlist',
          statusCode: e.response?.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<bool> validateUrl(String url) async {
    try {
      final response = await dio.head(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 5),
        ),
      );

      // Check if the response indicates success
      return response.statusCode != null && response.statusCode! < 400;
    } catch (e) {
      return false;
    }
  }
}

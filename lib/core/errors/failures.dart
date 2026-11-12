import 'package:equatable/equatable.dart';

/// Base class for all failures in the app
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Network error occurred'});
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error occurred', super.code});
}

/// Cache/Storage failures
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred'});
}

/// Parsing failures (e.g., invalid M3U format)
class ParsingFailure extends Failure {
  const ParsingFailure({super.message = 'Failed to parse playlist'});
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({super.message = 'Validation failed'});
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure({super.message = 'Permission denied'});
}

/// Playback failures
class PlaybackFailure extends Failure {
  const PlaybackFailure({super.message = 'Playback failed'});
}

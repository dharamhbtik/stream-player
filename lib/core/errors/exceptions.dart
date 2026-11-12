/// Custom exceptions for the app
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({this.message = 'Server error', this.statusCode});

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  CacheException({this.message = 'Cache error'});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  NetworkException({this.message = 'Network error'});

  @override
  String toString() => 'NetworkException: $message';
}

class ParsingException implements Exception {
  final String message;
  final int? lineNumber;

  ParsingException({this.message = 'Parsing error', this.lineNumber});

  @override
  String toString() => 'ParsingException: $message${lineNumber != null ? ' at line $lineNumber' : ''}';
}

class ValidationException implements Exception {
  final String message;

  ValidationException({this.message = 'Validation error'});

  @override
  String toString() => 'ValidationException: $message';
}

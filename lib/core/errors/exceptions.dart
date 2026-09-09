class ServerException implements Exception {
  const ServerException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class NetworkException implements Exception {
  const NetworkException(this.message);

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  const ValidationException(this.message);

  final String message;

  @override
  String toString() => 'ValidationException: $message';
}

class CacheException implements Exception {
  const CacheException(this.message);

  final String message;

  @override
  String toString() => 'CacheException: $message';
}

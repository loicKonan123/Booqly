class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class UnauthorizedException implements Exception {
  const UnauthorizedException();
}

class NetworkException implements Exception {
  const NetworkException();
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});
}

class ValidationException implements Exception {
  final Map<String, List<String>> errors;
  const ValidationException({required this.errors});
}

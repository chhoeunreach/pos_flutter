class AppException implements Exception {
  final String message;
  final dynamic originalError;

  const AppException({this.message = 'An unexpected error occurred', this.originalError});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([String message = 'Network error occurred'])
      : super(message: message);
}

class TimeoutException extends AppException {
  const TimeoutException([String message = 'Request timed out'])
      : super(message: message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'Unauthorized'])
      : super(message: message);
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException([String message = 'Permission denied'])
      : super(message: message);
}

class NotFoundException extends AppException {
  const NotFoundException([String message = 'Resource not found'])
      : super(message: message);
}

class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  const ValidationException({
    super.message = 'Validation failed',
    this.errors,
  });

  String get firstError {
    if (errors == null || errors!.isEmpty) return message;
    final firstKey = errors!.keys.first;
    final firstValue = errors![firstKey];
    if (firstValue is List && firstValue.isNotEmpty) {
      return firstValue.first.toString();
    }
    return message;
  }
}

class ServerException extends AppException {
  const ServerException([String message = 'Server error occurred'])
      : super(message: message);
}

class CacheException extends AppException {
  const CacheException([String message = 'Cache error occurred'])
      : super(message: message);
}

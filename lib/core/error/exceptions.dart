class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server Error']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache Error']);
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException([this.message = 'Database Error']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'No Internet Connection']);
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
}

class GeminiException implements Exception {
  final String message;
  GeminiException([this.message = 'Gemini AI Error']);
}

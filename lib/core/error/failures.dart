import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server failure occurred']) : super(message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([String message = 'Database failure occurred']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache failure occurred']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection']) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure([String message = 'Authentication failed']) : super(message);
}

class GeminiFailure extends Failure {
  const GeminiFailure([String message = 'Gemini AI processing failed']) : super(message);
}

import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server failure occurred']);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database failure occurred']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache failure occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

class GeminiFailure extends Failure {
  const GeminiFailure([super.message = 'Gemini AI processing failed']);
}

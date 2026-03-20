import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../models/user_profile.dart';
import '../repositories/user_repository.dart';

@lazySingleton
class SaveUserProfile {
  final UserRepository repository;
  SaveUserProfile(this.repository);

  Future<Either<Failure, Unit>> call(UserProfile profile) {
    return repository.saveUserProfile(profile);
  }
}

@lazySingleton
class GetUserProfile {
  final UserRepository repository;
  GetUserProfile(this.repository);

  Future<Either<Failure, UserProfile>> call(String userId) {
    return repository.getUserProfile(userId);
  }
}

@lazySingleton
class CheckOnboardingStatus {
  final UserRepository repository;
  CheckOnboardingStatus(this.repository);

  Future<Either<Failure, bool>> call(String userId) {
    return repository.isOnboarded(userId);
  }
}

@lazySingleton
class UpdateUserGoals {
  final UserRepository repository;
  UpdateUserGoals(this.repository);

  Future<Either<Failure, Unit>> call(String userId, Map<String, dynamic> goals) {
    return repository.updateUserGoals(userId, goals);
  }
}

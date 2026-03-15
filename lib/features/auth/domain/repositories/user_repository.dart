import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../models/user_profile.dart';

abstract class UserRepository {
  Future<Either<Failure, UserProfile>> getUserProfile(String id);
  Future<Either<Failure, Unit>> saveUserProfile(UserProfile profile);
  Future<Either<Failure, Unit>> updateUserGoals(String userId, Map<String, dynamic> goals);
  Future<Either<Failure, bool>> isOnboarded(String userId);
}

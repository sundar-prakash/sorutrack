import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sorutrack_pro/features/gamification/domain/models/gamification_models.dart';
import 'package:sorutrack_pro/features/gamification/domain/repositories/gamification_repository.dart';

// Events
abstract class GamificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadGamificationData extends GamificationEvent {
  final String userId;
  LoadGamificationData(this.userId);
  @override
  List<Object?> get props => [userId];
}

class RefreshGamificationData extends GamificationEvent {
  final String userId;
  RefreshGamificationData(this.userId);
  @override
  List<Object?> get props => [userId];
}

// States
abstract class GamificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GamificationInitial extends GamificationState {}

class GamificationLoading extends GamificationState {}

class GamificationLoaded extends GamificationState {
  final GamificationData data;
  final List<Badge> badges;
  final List<Achievement> achievements;
  final List<Challenge> activeChallenges;
  final List<UserChallenge> userChallenges;

  GamificationLoaded({
    required this.data,
    required this.badges,
    required this.achievements,
    required this.activeChallenges,
    required this.userChallenges,
  });

  @override
  List<Object?> get props => [data, badges, achievements, activeChallenges, userChallenges];
}

class GamificationError extends GamificationState {
  final String message;
  GamificationError(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final GamificationRepository _repository;

  GamificationBloc(this._repository) : super(GamificationInitial()) {
    on<LoadGamificationData>(_onLoadData);
    on<RefreshGamificationData>(_onLoadData);
  }

  Future<void> _onLoadData(GamificationEvent event, Emitter<GamificationState> emit) async {
    final userId = (event as dynamic).userId;
    emit(GamificationLoading());

    final dataResult = await _repository.getGamificationData(userId);
    final badgesResult = await _repository.getBadges();
    final achievementsResult = await _repository.getUserAchievements(userId);
    final challengesResult = await _repository.getActiveChallenges();
    final userChallengesResult = await _repository.getUserChallenges(userId);

    dataResult.fold(
      (failure) => emit(GamificationError(failure.message)),
      (data) {
        badgesResult.fold(
          (failure) => emit(GamificationError(failure.message)),
          (badges) {
            achievementsResult.fold(
              (failure) => emit(GamificationError(failure.message)),
              (achievements) {
                challengesResult.fold(
                  (failure) => emit(GamificationError(failure.message)),
                  (challenges) {
                    userChallengesResult.fold(
                      (failure) => emit(GamificationError(failure.message)),
                      (userChallenges) {
                        emit(GamificationLoaded(
                          data: data,
                          badges: badges,
                          achievements: achievements,
                          activeChallenges: challenges,
                          userChallenges: userChallenges,
                        ));
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

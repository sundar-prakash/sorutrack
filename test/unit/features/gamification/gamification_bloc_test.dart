import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:sorutrack_pro/features/gamification/presentation/bloc/gamification_bloc.dart';
import 'package:sorutrack_pro/features/gamification/domain/repositories/gamification_repository.dart';
import 'package:sorutrack_pro/features/gamification/domain/models/gamification_models.dart';
import 'package:sorutrack_pro/core/error/failures.dart';

import 'gamification_bloc_test.mocks.dart';

@GenerateMocks([GamificationRepository])
void main() {
  late GamificationBloc bloc;
  late MockGamificationRepository mockRepository;

  final sampleData = const GamificationData(
    userId: 'user1',
    xp: 100,
    level: 2,
    currentStreak: 5,
    highestStreak: 10,
    streakFreezeCount: 1,
  );

  setUp(() {
    mockRepository = MockGamificationRepository();
    bloc = GamificationBloc(mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('GamificationBloc', () {
    const userId = 'user1';

    blocTest<GamificationBloc, GamificationState>(
      'should emit [Loading, Loaded] when all data fetching is successful',
      build: () {
        when(mockRepository.getGamificationData(userId))
            .thenAnswer((_) async => Right(sampleData));
        when(mockRepository.getBadges())
            .thenAnswer((_) async => const Right([]));
        when(mockRepository.getUserAchievements(userId))
            .thenAnswer((_) async => const Right([]));
        when(mockRepository.getActiveChallenges())
            .thenAnswer((_) async => const Right([]));
        when(mockRepository.getUserChallenges(userId))
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadGamificationData(userId)),
      expect: () => [
        GamificationLoading(),
        isA<GamificationLoaded>(),
      ],
      verify: (_) {
        verify(mockRepository.getGamificationData(userId)).called(1);
      },
    );

    blocTest<GamificationBloc, GamificationState>(
      'should emit [Loading, Error] when gamification data fetching fails',
      build: () {
        when(mockRepository.getGamificationData(userId))
            .thenAnswer((_) async => const Left(DatabaseFailure('Error')));
        when(mockRepository.getBadges())
            .thenAnswer((_) async => const Right([]));
        when(mockRepository.getUserAchievements(any))
            .thenAnswer((_) async => const Right([]));
        when(mockRepository.getActiveChallenges())
            .thenAnswer((_) async => const Right([]));
        when(mockRepository.getUserChallenges(any))
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadGamificationData(userId)),
      expect: () => [
        GamificationLoading(),
        GamificationError('Error'),
      ],
    );

    blocTest<GamificationBloc, GamificationState>(
      'should emit [Loading, Error] when badges fetching fails',
      build: () {
        when(mockRepository.getGamificationData(userId))
            .thenAnswer((_) async => Right(sampleData));
        when(mockRepository.getBadges())
            .thenAnswer((_) async => const Left(DatabaseFailure('Badges Error')));
        when(mockRepository.getUserAchievements(any))
            .thenAnswer((_) async => const Right([]));
        when(mockRepository.getActiveChallenges())
            .thenAnswer((_) async => const Right([]));
        when(mockRepository.getUserChallenges(any))
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadGamificationData(userId)),
      expect: () => [
        GamificationLoading(),
        GamificationError('Badges Error'),
      ],
    );
  });
}

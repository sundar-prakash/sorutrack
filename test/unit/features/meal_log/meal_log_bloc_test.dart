import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:sorutrack_pro/features/meal_log/presentation/bloc/meal_log_bloc.dart';
import 'package:sorutrack_pro/features/meal_log/presentation/bloc/meal_log_event.dart';
import 'package:sorutrack_pro/features/meal_log/presentation/bloc/meal_log_state.dart';
import 'package:sorutrack_pro/features/meal_log/domain/repositories/meal_repository.dart';
import 'package:sorutrack_pro/features/meal_log/domain/models/parsed_meal.dart';
import 'package:sorutrack_pro/core/error/failures.dart';

import 'meal_log_bloc_test.mocks.dart';

@GenerateMocks([MealRepository])
void main() {
  late MealLogBloc bloc;
  late MockMealRepository mockRepository;

  setUp(() {
    mockRepository = MockMealRepository();
    bloc = MealLogBloc(mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  final tParsedMeal = ParsedMeal(
    mealName: 'Apple',
    mealTime: '08:00',
    mealType: 'breakfast',
    confidenceScore: 0.9,
    totalCalories: 95,
    totalProteinG: 0.5,
    totalCarbsG: 25,
    totalFatG: 0.3,
    items: const [
      ParsedMealItem(
        name: 'Apple',
        quantity: 1,
        unit: 'piece',
        weightG: 150,
        calories: 95,
        proteinG: 0.5,
        carbsG: 25,
        fatG: 0.3,
        servingDescription: '1 medium apple',
      ),
    ],
  );

  group('MealLogBloc', () {
    test('initial state is correct', () {
      expect(bloc.state, const MealLogState.initial());
    });

    blocTest<MealLogBloc, MealLogState>(
      'emits [analyzing, reviewing] when ParseMealEvent is successful',
      build: () {
        when(mockRepository.parseMeal(any, any))
            .thenAnswer((_) async => Right(tParsedMeal));
        return bloc;
      },
      act: (bloc) => bloc.add(const ParseMealEvent('I ate an apple', 'breakfast')),
      expect: () => [
        const MealLogState.analyzing(),
        MealLogState.reviewing(tParsedMeal),
      ],
    );

    blocTest<MealLogBloc, MealLogState>(
      'emits [analyzing, error] when ParseMealEvent fails',
      build: () {
        when(mockRepository.parseMeal(any, any))
            .thenAnswer((_) async => const Left(ServerFailure('API Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const ParseMealEvent('I ate an apple', 'breakfast')),
      expect: () => [
        const MealLogState.analyzing(),
        const MealLogState.error('API Error'),
      ],
    );

    blocTest<MealLogBloc, MealLogState>(
      'emits [saving, success] when SaveMealEvent is successful',
      build: () {
        when(mockRepository.saveMeal(any))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(SaveMealEvent(tParsedMeal)),
      expect: () => [
        const MealLogState.saving(),
        const MealLogState.success(),
      ],
    );

    blocTest<MealLogBloc, MealLogState>(
      'emits [saving, error] when SaveMealEvent fails',
      build: () {
        when(mockRepository.saveMeal(any))
            .thenAnswer((_) async => const Left(DatabaseFailure('Save Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(SaveMealEvent(tParsedMeal)),
      expect: () => [
        const MealLogState.saving(),
        const MealLogState.error('Save Error'),
      ],
    );

    blocTest<MealLogBloc, MealLogState>(
      'emits [initial] when ResetEvent is triggered',
      build: () => bloc,
      act: (bloc) => bloc.add(const ResetEvent()),
      expect: () => [
        const MealLogState.initial(),
      ],
    );
  });
}

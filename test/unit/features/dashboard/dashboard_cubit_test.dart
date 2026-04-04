import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:sorutrack_pro/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:sorutrack_pro/features/dashboard/domain/models/dashboard_data.dart';
import 'package:sorutrack_pro/core/services/home_widget_service.dart';
import 'package:sorutrack_pro/core/error/failures.dart';

import 'dashboard_cubit_test.mocks.dart';

@GenerateMocks([DashboardRepository, HomeWidgetService])
void main() {
  late DashboardCubit cubit;
  late MockDashboardRepository mockRepository;
  late MockHomeWidgetService mockHomeWidgetService;

  final sampleData = DashboardData(
    nutritionSummary: const DailyNutritionSummary(
      consumedCalories: 1500,
      targetCalories: 2000,
      burnedCalories: 200,
      proteinG: 100,
      proteinTargetG: 150,
      carbsG: 200,
      carbsTargetG: 250,
      fatG: 50,
      fatTargetG: 70,
      fiberG: 20,
      fiberTargetG: 30,
    ),
    meals: [],
    waterIntakeMl: 1000,
    waterTargetMl: 2500,
    currentStreak: 5,
    greeting: "Good morning",
    weeklyCalories: [],
    dailyInsight: "Test",
  );

  setUp(() {
    mockRepository = MockDashboardRepository();
    mockHomeWidgetService = MockHomeWidgetService();
    cubit = DashboardCubit(mockRepository, mockHomeWidgetService);
  });

  tearDown(() {
    cubit.close();
  });

  group('loadDashboard', () {
    final testDate = DateTime(2024, 4, 4);

    blocTest<DashboardCubit, DashboardState>(
      'should emit [loading, loaded] when fetching data is successful',
      build: () {
        when(mockRepository.getDashboardData(any, any))
            .thenAnswer((_) async => Right(sampleData));
        return cubit;
      },
      act: (cubit) => cubit.loadDashboard(date: testDate),
      expect: () => [
        const DashboardState.loading(),
        DashboardState.loaded(data: sampleData, selectedDate: testDate),
      ],
      verify: (_) {
        verify(mockRepository.getDashboardData('default_user', testDate));
        verify(mockHomeWidgetService.updateWidget(
          caloriesConsumed: 1500,
          calorieTarget: 2000,
          streak: 5,
        ));
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'should emit [loading, error] when fetching data fails',
      build: () {
        when(mockRepository.getDashboardData(any, any))
            .thenAnswer((_) async => const Left(DatabaseFailure('Error')));
        return cubit;
      },
      act: (cubit) => cubit.loadDashboard(date: testDate),
      expect: () => [
        const DashboardState.loading(),
        const DashboardState.error('Error'),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'should emit [loaded(isRefreshing: true), loaded] when refreshing existing data',
      build: () {
        when(mockRepository.getDashboardData(any, any))
            .thenAnswer((_) async => Right(sampleData));
        return cubit;
      },
      seed: () => DashboardState.loaded(data: sampleData, selectedDate: testDate),
      act: (cubit) => cubit.loadDashboard(date: testDate, isRefresh: true),
      expect: () => [
        DashboardState.loaded(data: sampleData, selectedDate: testDate, isRefreshing: true),
        DashboardState.loaded(data: sampleData, selectedDate: testDate, isRefreshing: false),
      ],
    );
  });

  group('addWater', () {
    final testDate = DateTime(2024, 4, 4);

    blocTest<DashboardCubit, DashboardState>(
      'should log water and then refresh dashboard silently',
      build: () {
        when(mockRepository.logWater(any, any, any))
            .thenAnswer((_) async => const Right(null));
        when(mockRepository.getDashboardData(any, any))
            .thenAnswer((_) async => Right(sampleData));
        return cubit;
      },
      seed: () => DashboardState.loaded(data: sampleData, selectedDate: testDate),
      act: (cubit) => cubit.addWater(250),
      // Silent refresh means it doesn't emit LOADING, but it emits LOADED(isRefreshing: true) then LOADED
      expect: () => [
        DashboardState.loaded(data: sampleData, selectedDate: testDate, isRefreshing: true),
        DashboardState.loaded(data: sampleData, selectedDate: testDate, isRefreshing: false),
      ],
      verify: (_) {
        verify(mockRepository.logWater('default_user', testDate, 250));
      },
    );
  });

  group('Day Navigation', () {
    final initialDate = DateTime(2024, 4, 4);
    final nextDate = DateTime(2024, 4, 5);
    final prevDate = DateTime(2024, 4, 3);

    blocTest<DashboardCubit, DashboardState>(
      'nextDay should transition to next day from current loaded date',
      build: () {
        when(mockRepository.getDashboardData(any, any))
            .thenAnswer((_) async => Right(sampleData));
        return cubit;
      },
      seed: () => DashboardState.loaded(data: sampleData, selectedDate: initialDate),
      act: (cubit) => cubit.nextDay(),
      expect: () => [
        DashboardState.loaded(data: sampleData, selectedDate: nextDate),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'previousDay should transition to previous day from current loaded date',
      build: () {
        when(mockRepository.getDashboardData(any, any))
            .thenAnswer((_) async => Right(sampleData));
        return cubit;
      },
      seed: () => DashboardState.loaded(data: sampleData, selectedDate: initialDate),
      act: (cubit) => cubit.previousDay(),
      expect: () => [
        DashboardState.loaded(data: sampleData, selectedDate: prevDate),
      ],
    );
  });
}

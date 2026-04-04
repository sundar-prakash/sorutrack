import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sorutrack_pro/features/reports/domain/repositories/reports_repository.dart';
import 'package:sorutrack_pro/features/reports/data/services/gemini_reports_service.dart';
import 'package:sorutrack_pro/features/reports/presentation/bloc/reports_cubit.dart';
import 'package:sorutrack_pro/features/reports/presentation/bloc/report_filter_cubit.dart';
import 'package:sorutrack_pro/features/reports/domain/models/report_models.dart';

import 'reports_cubit_test.mocks.dart';

@GenerateMocks([ReportsRepository, GeminiReportsService])
void main() {
  late MockReportsRepository mockRepository;
  late MockGeminiReportsService mockGeminiService;
  late ReportsCubit cubit;

  final filter = ReportFilterState.initial();
  const userId = 'user123';

  setUp(() {
    mockRepository = MockReportsRepository();
    mockGeminiService = MockGeminiReportsService();
    cubit = ReportsCubit(mockRepository, mockGeminiService);
  });

  tearDown(() {
    cubit.close();
  });

  group('ReportsCubit', () {
    test('initial state is ReportsInitial', () {
      expect(cubit.state, ReportsInitial());
    });

    blocTest<ReportsCubit, ReportsState>(
      'loadReports emits [ReportsLoading, ReportsLoaded] on success',
      build: () {
        when(mockRepository.getCalorieTrend(any, any, any)).thenAnswer((_) async => []);
        when(mockRepository.getMacroTrend(any, any, any)).thenAnswer((_) async => []);
        when(mockRepository.getTopFoods(any, limit: anyNamed('limit'), startDate: anyNamed('startDate'), endDate: anyNamed('endDate')))
            .thenAnswer((_) async => []);
        when(mockRepository.getMealTimingData(any)).thenAnswer((_) async => []);
        when(mockRepository.getWeightTrend(any, any, any)).thenAnswer((_) async => []);
        when(mockRepository.getGoalAdherence(any, any, any)).thenAnswer((_) async => []);
        when(mockRepository.getMicronutrientAverages(any, any, any)).thenAnswer((_) async => const MicronutrientData(fiber: 0, sodium: 0, sugar: 0, potassium: 0));
        when(mockRepository.searchFoodEntries(
          any, 
          query: anyNamed('query'), 
          startDate: anyNamed('startDate'), 
          endDate: anyNamed('endDate'), 
          mealTypes: anyNamed('mealTypes'), 
          minCalories: anyNamed('minCalories'), 
          maxCalories: anyNamed('maxCalories'),
        )).thenAnswer((_) async => []);
        when(mockRepository.getCurrentStreak(any)).thenAnswer((_) async => 5);
        return cubit;
      },
      act: (c) => c.loadReports(filter, userId),
      expect: () => [
        ReportsLoading(),
        isA<ReportsLoaded>().having((s) => s.currentStreak, 'streak', 5),
      ],
    );

    blocTest<ReportsCubit, ReportsState>(
      'loadReports emits [ReportsLoading, ReportsError] on repository failure',
      build: () {
        when(mockRepository.getCalorieTrend(any, any, any)).thenThrow(Exception('Database Error'));
        return cubit;
      },
      act: (c) => c.loadReports(filter, userId),
      expect: () => [
        ReportsLoading(),
        isA<ReportsError>().having((s) => s.message, 'message', contains('Database Error')),
      ],
    );

    blocTest<ReportsCubit, ReportsState>(
      'loadInsights updates state with generated insights on success',
      build: () => cubit,
      seed: () => const ReportsLoaded(
        calorieTrend: [], macroTrend: [], topFoods: [], mealTiming: [], 
        weightTrend: [], goalAdherence: [], 
        micronutrients: MicronutrientData(fiber: 0, sodium: 0, sugar: 0, potassium: 0), 
        foodDiary: [], 
        currentStreak: 5
      ),
      act: (c) {
        when(mockGeminiService.generateWeeklyInsights(
          calories: anyNamed('calories'),
          macros: anyNamed('macros'),
          topFoods: anyNamed('topFoods'),
          micros: anyNamed('micros'),
        )).thenAnswer((_) async => 'Great progress!');
        return c.loadInsights();
      },
      expect: () => [
        isA<ReportsLoaded>().having((s) => s.insights, 'insights', 'Great progress!'),
      ],
    );

    blocTest<ReportsCubit, ReportsState>(
      'loadInsights handles error from gemini service gracefully',
      build: () => cubit,
      seed: () => const ReportsLoaded(
        calorieTrend: [], macroTrend: [], topFoods: [], mealTiming: [], 
        weightTrend: [], goalAdherence: [], 
        micronutrients: MicronutrientData(fiber: 0, sodium: 0, sugar: 0, potassium: 0), 
        foodDiary: [], 
        currentStreak: 5
      ),
      act: (c) {
        when(mockGeminiService.generateWeeklyInsights(
          calories: anyNamed('calories'),
          macros: anyNamed('macros'),
          topFoods: anyNamed('topFoods'),
          micros: anyNamed('micros'),
        )).thenThrow(Exception('API Error'));
        return c.loadInsights();
      },
      expect: () => [
        isA<ReportsLoaded>().having((s) => s.insights, 'insights', contains('API Error')),
      ],
    );
  });
}

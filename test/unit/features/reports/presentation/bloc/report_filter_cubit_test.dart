import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:sorutrack_pro/features/reports/presentation/bloc/report_filter_cubit.dart';

void main() {
  group('ReportFilterCubit', () {
    late ReportFilterCubit cubit;

    setUp(() {
      cubit = ReportFilterCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      final now = DateTime.now();
      expect(cubit.state.rangeType, DateRangeType.today);
      expect(cubit.state.startDate.year, now.year);
      expect(cubit.state.startDate.month, now.month);
      expect(cubit.state.startDate.day, now.day);
      expect(cubit.state.mealTypes, isEmpty);
    });

    blocTest<ReportFilterCubit, ReportFilterState>(
      'setRange updates state for thisWeek',
      build: () => cubit,
      act: (c) => c.setRange(DateRangeType.thisWeek),
      verify: (c) {
        expect(c.state.rangeType, DateRangeType.thisWeek);
        // Basic check that start date is on or before today
        expect(c.state.startDate.isBefore(DateTime.now()) || 
               c.state.startDate.isAtSameMomentAs(DateTime.now()), true);
      },
    );

    blocTest<ReportFilterCubit, ReportFilterState>(
      'setRange updates state for thisMonth',
      build: () => cubit,
      act: (c) => c.setRange(DateRangeType.thisMonth),
      verify: (c) {
        expect(c.state.rangeType, DateRangeType.thisMonth);
        expect(c.state.startDate.day, 1);
      },
    );

    blocTest<ReportFilterCubit, ReportFilterState>(
      'setRange updates state for last30Days',
      build: () => cubit,
      act: (c) => c.setRange(DateRangeType.last30Days),
      verify: (c) {
        expect(c.state.rangeType, DateRangeType.last30Days);
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        expect(c.state.startDate.isAfter(thirtyDaysAgo.subtract(const Duration(seconds: 5))), true);
      },
    );

    blocTest<ReportFilterCubit, ReportFilterState>(
      'setRange updates state for custom',
      build: () => cubit,
      act: (c) => c.setRange(
        DateRangeType.custom, 
        customStart: DateTime(2023, 1, 1), 
        customEnd: DateTime(2023, 1, 31)
      ),
      expect: () => [
        isA<ReportFilterState>()
            .having((s) => s.rangeType, 'rangeType', DateRangeType.custom)
            .having((s) => s.startDate, 'startDate', DateTime(2023, 1, 1))
            .having((s) => s.endDate, 'endDate', DateTime(2023, 1, 31)),
      ],
    );

    blocTest<ReportFilterCubit, ReportFilterState>(
      'updateFilters updates meal types and query',
      build: () => cubit,
      act: (c) => c.updateFilters(
        mealTypes: ['breakfast', 'lunch'],
        query: 'apple',
        minCalories: 100,
        maxCalories: 500,
      ),
      expect: () => [
        isA<ReportFilterState>()
            .having((s) => s.mealTypes, 'mealTypes', ['breakfast', 'lunch'])
            .having((s) => s.query, 'query', 'apple')
            .having((s) => s.minCalories, 'minCalories', 100)
            .having((s) => s.maxCalories, 'maxCalories', 500),
      ],
    );

    blocTest<ReportFilterCubit, ReportFilterState>(
      'resetFilters returns state to initial',
      build: () => cubit,
      seed: () => ReportFilterState(
        rangeType: DateRangeType.custom,
        startDate: DateTime(2020),
        endDate: DateTime(2021),
        query: 'test',
      ),
      act: (c) => c.resetFilters(),
      verify: (c) {
        expect(c.state.rangeType, DateRangeType.today);
        expect(c.state.query, isEmpty);
      },
    );
  });
}

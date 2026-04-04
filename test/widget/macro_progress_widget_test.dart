import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/widgets/macro_bars_widget.dart';
import 'package:sorutrack_pro/features/dashboard/domain/models/dashboard_data.dart';
import 'package:sorutrack_pro/features/auth/presentation/cubit/profile_cubit.dart';
import 'package:sorutrack_pro/features/auth/domain/models/user_profile.dart';
import 'package:sorutrack_pro/features/auth/domain/models/auth_enums.dart';

import 'macro_progress_widget_test.mocks.dart';

@GenerateMocks([ProfileCubit])
void main() {
  late MockProfileCubit mockProfileCubit;

  final sampleProfile = UserProfile(
    id: 'user1',
    name: 'John Doe',
    age: 30,
    gender: Gender.male,
    height: 175,
    weight: 70,
    targetWeight: 68,
    weeklyGoal: 0.5,
    activityLevel: ActivityLevel.sedentary,
    goal: GoalType.maintain,
    weightUnit: WeightUnit.kg,
    heightUnit: HeightUnit.cm,
    isOnboarded: true,
    dietaryPreference: DietaryPreference.nonVeg,
    mealReminderMorning: DateTime(2024, 1, 1, 8, 0),
    mealReminderAfternoon: DateTime(2024, 1, 1, 13, 0),
    mealReminderEvening: DateTime(2024, 1, 1, 19, 0),
    waterReminderIntervalMinutes: 60,
  );

  setUp(() {
    mockProfileCubit = MockProfileCubit();
    // Provide an initial state
    when(mockProfileCubit.state).thenReturn(ProfileState.loaded(
      profile: sampleProfile,
      bmr: 1600,
      tdee: 2000,
      calorieTarget: 2000,
      macros: {'protein': 150, 'carbs': 250, 'fat': 70, 'fiber': 30},
      bmi: 22.8,
      bmiStatus: 'Normal',
    ));
    when(mockProfileCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  group('MacroBarsWidget Tests', () {
    const summary = DailyNutritionSummary(
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
    );

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<ProfileCubit>.value(
            value: mockProfileCubit,
            child: const MacroBarsWidget(summary: summary),
          ),
        ),
      );
    }

    testWidgets('renders all macro bars with correct labels and values', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Check labels
      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('Carbs'), findsOneWidget);
      expect(find.text('Fat'), findsOneWidget);
      expect(find.text('Fiber'), findsOneWidget);

      // Check values
      expect(find.text('100 / 150g'), findsOneWidget);
      expect(find.text('200 / 250g'), findsOneWidget);
      expect(find.text('50 / 70g'), findsOneWidget);
      expect(find.text('20 / 30g'), findsOneWidget);
    });

    testWidgets('displays correct labels and values', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Check values match the summary
      expect(find.text('100 / 150g'), findsOneWidget);
      expect(find.text('200 / 250g'), findsOneWidget);
      expect(find.text('50 / 70g'), findsOneWidget);
      expect(find.text('20 / 30g'), findsOneWidget);
    });
  });
}

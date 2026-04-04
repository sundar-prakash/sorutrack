import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sorutrack_pro/features/auth/presentation/pages/profile_screen.dart';
import 'package:sorutrack_pro/features/auth/presentation/cubit/profile_cubit.dart';
import 'package:sorutrack_pro/features/auth/domain/models/user_profile.dart';
import 'package:sorutrack_pro/features/auth/domain/models/auth_enums.dart';

class MockProfileCubit extends MockCubit<ProfileState> implements ProfileCubit {}

void main() {
  late MockProfileCubit mockProfileCubit;

  final testProfile = UserProfile(
    id: 'user123',
    name: 'Test User',
    age: 25,
    gender: Gender.male,
    height: 175,
    heightUnit: HeightUnit.cm,
    weight: 75,
    weightUnit: WeightUnit.kg,
    activityLevel: ActivityLevel.sedentary,
    goal: GoalType.maintain,
    targetWeight: 75,
    weeklyGoal: 0,
    dietaryPreference: DietaryPreference.nonVeg,
    isOnboarded: true,
    mealReminderMorning: DateTime(2024, 1, 1, 8, 0),
    mealReminderAfternoon: DateTime(2024, 1, 1, 13, 0),
    mealReminderEvening: DateTime(2024, 1, 1, 20, 0),
    waterReminderIntervalMinutes: 60,
  );

  setUp(() {
    mockProfileCubit = MockProfileCubit();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<ProfileCubit>.value(
        value: mockProfileCubit,
        child: const ProfileScreen(),
      ),
    );
  }

  testWidgets('renders loading state correctly', (WidgetTester tester) async {
    when(() => mockProfileCubit.state).thenReturn(const ProfileState.loading());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders error state correctly', (WidgetTester tester) async {
    const errorMessage = 'Something went wrong';
    when(() => mockProfileCubit.state).thenReturn(const ProfileState.error(errorMessage));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text(errorMessage), findsOneWidget);
  });

  testWidgets('renders loaded state with profile data', (WidgetTester tester) async {
    when(() => mockProfileCubit.state).thenReturn(ProfileState.loaded(
      profile: testProfile,
      bmr: 1800,
      tdee: 2200,
      calorieTarget: 2200,
      macros: {
        'protein': 150,
        'carbs': 250,
        'fat': 70,
      },
      bmi: 24.5,
      bmiStatus: 'Normal',
    ));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); // For animations (FadeIn)

    expect(find.text('Test User'), findsWidgets);
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('2200'), findsWidgets); // Target & TDEE
    expect(find.text('1800'), findsOneWidget); // BMR
    expect(find.text('BMI: 24.5 (Normal)'), findsOneWidget);
    
    // Check macros (Screen uses round() so it's 150g, 250g, 70g)
    expect(find.textContaining('150g'), findsOneWidget);
    expect(find.textContaining('250g'), findsOneWidget);
    expect(find.textContaining('70g'), findsOneWidget);
  });
}

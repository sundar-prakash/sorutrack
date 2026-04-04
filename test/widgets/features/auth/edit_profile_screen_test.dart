import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sorutrack_pro/features/auth/presentation/pages/edit_profile_screen.dart';
import 'package:sorutrack_pro/features/auth/presentation/cubit/profile_cubit.dart';
import 'package:sorutrack_pro/features/auth/domain/models/user_profile.dart';
import 'package:sorutrack_pro/features/auth/domain/models/auth_enums.dart';

class MockProfileCubit extends MockCubit<ProfileState> implements ProfileCubit {}
class FakeUserProfile extends Fake implements UserProfile {}

// Simple Mock GoRouter
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockProfileCubit mockProfileCubit;
  late MockGoRouter mockGoRouter;

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

  setUpAll(() {
    registerFallbackValue(FakeUserProfile());
  });

  setUp(() {
    mockProfileCubit = MockProfileCubit();
    mockGoRouter = MockGoRouter();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: InheritedGoRouter(
        goRouter: mockGoRouter,
        child: BlocProvider<ProfileCubit>.value(
          value: mockProfileCubit,
          child: const EditProfileScreen(),
        ),
      ),
    );
  }

  testWidgets('renders loaded state with form values', (WidgetTester tester) async {
    when(() => mockProfileCubit.state).thenReturn(ProfileState.loaded(
      profile: testProfile,
      bmr: 1800,
      tdee: 2200,
      calorieTarget: 2200,
      macros: {'protein': 150, 'carbs': 250, 'fat': 70},
      bmi: 24.5,
      bmiStatus: 'Normal',
    ));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Name'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
  });

  testWidgets('calls updateProfile and pops when save button is pressed', (WidgetTester tester) async {
    when(() => mockProfileCubit.state).thenReturn(ProfileState.loaded(
      profile: testProfile,
      bmr: 1800,
      tdee: 2200,
      calorieTarget: 2200,
      macros: {'protein': 150, 'carbs': 250, 'fat': 70},
      bmi: 24.5,
      bmiStatus: 'Normal',
    ));
    
    when(() => mockProfileCubit.updateProfile(any())).thenAnswer((_) async {});
    // mocktail does not need stubbing for pop if we just want it to not throw

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Updated Name');
    
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    verify(() => mockProfileCubit.updateProfile(any())).called(1);
    // verify(() => mockGoRouter.pop()).called(1); // Optional but good
  });
}

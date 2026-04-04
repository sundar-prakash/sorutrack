import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorutrack_pro/features/auth/presentation/pages/onboarding_screen.dart';
import 'package:sorutrack_pro/features/auth/presentation/cubit/onboarding_cubit.dart';
import 'package:sorutrack_pro/features/auth/domain/usecases/profile_use_cases.dart';
import 'package:sorutrack_pro/core/services/gemini_key_service.dart';

import 'onboarding_screen_test.mocks.dart';

@GenerateMocks([SaveUserProfile, GeminiKeyService])
void main() {
  late MockSaveUserProfile mockSaveUserProfile;
  late MockGeminiKeyService mockGeminiKeyService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockSaveUserProfile = MockSaveUserProfile();
    mockGeminiKeyService = MockGeminiKeyService();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<OnboardingCubit>(
        create: (context) => OnboardingCubit(mockSaveUserProfile, mockGeminiKeyService),
        child: const OnboardingScreen(),
      ),
    );
  }

  group('OnboardingScreen Widget Tests', () {
    testWidgets('renders first step and validates name input', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert: Step 1 components
      expect(find.text('Welcome to SoruTrack!'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(1)); // One for name

      // Act: Try to go next without name
      await tester.tap(find.text('NEXT'));
      await tester.pump();

      // Assert: Error snackbar or field error should show
      expect(find.text('Please enter your full name'), findsAtLeastNWidgets(1));

      // Act: Enter valid name and dob
      await tester.enterText(find.byType(TextField), 'John Doe');
      // Dob is usually picked via picker, but for test we might need to mock state or tap picker
      // In OnboardingStep1, the DOB picker updates the cubit.
    });

    testWidgets('transitions through steps with validation', (WidgetTester tester) async {
      // Arrange
      final cubit = OnboardingCubit(mockSaveUserProfile, mockGeminiKeyService);
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<OnboardingCubit>.value(
            value: cubit,
            child: const OnboardingScreen(),
          ),
        ),
      );

      // Step 1: Identity
      expect(find.text('Welcome to SoruTrack!'), findsOneWidget);
      cubit.updateName('John Doe');
      cubit.updateDateOfBirth(DateTime(1990, 1, 1));
      
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Step 2: Body Metrics
      expect(find.text('Body Metrics'), findsOneWidget);
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();
      
      // Step 3: Activity Level
      expect(find.text('Activity Level'), findsOneWidget);
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Step 4: Goals
      expect(find.text('What is your Goal?'), findsOneWidget);
    });
  });
}

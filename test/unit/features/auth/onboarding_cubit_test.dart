import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorutrack_pro/features/auth/presentation/cubit/onboarding_cubit.dart';
import 'package:sorutrack_pro/features/auth/presentation/cubit/onboarding_state.dart';
import 'package:sorutrack_pro/features/auth/domain/usecases/profile_use_cases.dart';
import 'package:sorutrack_pro/core/services/gemini_key_service.dart';
import 'package:sorutrack_pro/features/auth/domain/models/auth_enums.dart';

import 'onboarding_cubit_test.mocks.dart';

@GenerateMocks([SaveUserProfile, GeminiKeyService])
void main() {
  late OnboardingCubit cubit;
  late MockSaveUserProfile mockSaveUserProfile;
  late MockGeminiKeyService mockGeminiKeyService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockSaveUserProfile = MockSaveUserProfile();
    mockGeminiKeyService = MockGeminiKeyService();
    cubit = OnboardingCubit(mockSaveUserProfile, mockGeminiKeyService);
  });

  tearDown(() {
    cubit.close();
  });

  group('OnboardingCubit', () {
    test('initial state is correct', () {
      expect(cubit.state, const OnboardingState());
    });

    blocTest<OnboardingCubit, OnboardingState>(
      'updateName emits correct state',
      build: () => cubit,
      act: (cubit) => cubit.updateName('John Doe'),
      expect: () => [
        const OnboardingState(name: 'John Doe'),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'nextStep updates currentStep on valid input',
      build: () => cubit,
      seed: () => OnboardingState(
        name: 'John Doe',
        dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 25)),
      ),
      act: (cubit) => cubit.nextStep(),
      expect: () => [
        isA<OnboardingState>().having((s) => s.currentStep, 'currentStep', 1),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'nextStep emits error on invalid input (Step 0)',
      build: () => cubit,
      act: (cubit) => cubit.nextStep(),
      expect: () => [
        isA<OnboardingState>().having((s) => s.error, 'error', isNotNull),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'submit succeeds and updates shared prefs',
      build: () {
        when(mockSaveUserProfile.call(any))
            .thenAnswer((_) async => const Right(unit));
        return cubit;
      },
      seed: () => OnboardingState(
        name: 'John Doe',
        dateOfBirth: DateTime(1990, 1, 1),
        currentStep: 6,
      ),
      act: (cubit) => cubit.submit(),
      expect: () => [
        isA<OnboardingState>().having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<OnboardingState>().having((s) => s.isSubmitting, 'isSubmitting', false),
      ],
      verify: (_) async {
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('isOnboarded'), true);
      },
    );

    test('_enforceWeightConstraints adjusts targetWeight for loseWeight goal', () {
      cubit.updateWeight(100.0, WeightUnit.kg);
      cubit.updateGoal(GoalType.loseWeight);
      cubit.updateTargetWeight(110.0); // Invalid for loss
      
      expect(cubit.state.targetWeight, 99.0); // 100 - 1.0
    });
  });
}

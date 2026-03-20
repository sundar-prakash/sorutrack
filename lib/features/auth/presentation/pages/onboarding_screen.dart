import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/onboarding_step1.dart';
import '../widgets/onboarding_step2.dart';
import '../widgets/onboarding_step3.dart';
import '../widgets/onboarding_step4.dart';
import '../widgets/onboarding_step5.dart';
import '../widgets/onboarding_step6.dart';
import '../widgets/onboarding_step7.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onNext() {
    final cubit = context.read<OnboardingCubit>();
    if (cubit.state.currentStep < 6) {
      if (cubit.nextStep()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _confettiController.play();
      Future.delayed(const Duration(seconds: 2), () {
        cubit.submit().then((_) {
          if (mounted) context.go('/dashboard');
        });
      });
    }
  }

  void _onSkip() {
    context.go('/dashboard');
  }

  void _onBack() {
    final cubit = context.read<OnboardingCubit>();
    if (cubit.state.currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      cubit.previousStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<OnboardingCubit>();

          return Stack(
            alignment: Alignment.center,
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // Top Bar (Skip + Progress Dots)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          if (state.currentStep > 0)
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: _onBack,
                            )
                          else
                            const SizedBox(
                                width: 48), // Placeholder for alignment

                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(7, (index) {
                                final isActive = index == state.currentStep;
                                final isCompleted = index < state.currentStep;
                                final color = isActive || isCompleted
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  height: 8,
                                  width: isActive ? 24 : 8,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              }),
                            ),
                          ),
                          TextButton(
                            onPressed: _onSkip,
                            child: const Text('Skip'),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          OnboardingStep1(
                            name: state.name,
                            dateOfBirth: state.dateOfBirth,
                            gender: state.gender,
                            error: state.currentStep == 0 ? state.error : null,
                            onNameChanged: cubit.updateName,
                            onDateOfBirthChanged: cubit.updateDateOfBirth,
                            onGenderChanged: cubit.updateGender,
                          ),
                          OnboardingStep2(
                            height: state.height,
                            heightUnit: state.heightUnit,
                            weight: state.weight,
                            weightUnit: state.weightUnit,
                            error: state.currentStep == 1 ? state.error : null,
                            onHeightChanged: cubit.updateHeight,
                            onWeightChanged: cubit.updateWeight,
                          ),
                          OnboardingStep3(
                            selectedLevel: state.activityLevel,
                            onLevelChanged: cubit.updateActivityLevel,
                          ),
                          OnboardingStep4(
                            selectedGoal: state.goal,
                            onGoalChanged: cubit.updateGoal,
                          ),
                          OnboardingStep5(
                            currentWeight: state.weight,
                            goal: state.goal,
                            targetWeight: state.targetWeight,
                            weeklyGoal: state.weeklyGoal,
                            weightUnit: state.weightUnit,
                            error: state.currentStep == 4 ? state.error : null,
                            onTargetWeightChanged: cubit.updateTargetWeight,
                            onWeeklyGoalChanged: cubit.updateWeeklyGoal,
                          ),
                          OnboardingStep6(
                            dietaryPreference: state.dietaryPreference,
                            selectedAllergies: state.allergies,
                            onPrefChanged: cubit.updateDietaryPreference,
                            onAllergiesChanged: cubit.updateAllergies,
                          ),
                          OnboardingStep7(
                            apiKey: state.geminiApiKey,
                            onKeyChanged: cubit.updateGeminiApiKey,
                          ),
                        ],
                      ),
                    ),

                    // Bottom Navigation
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: state.isSubmitting ? null : _onNext,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: state.isSubmitting
                                  ? const CircularProgressIndicator()
                                  : Text(state.currentStep == 6
                                      ? 'FINISH'
                                      : 'NEXT'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Confetti Overlay
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 2, // down
                  maxBlastForce: 5,
                  minBlastForce: 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 50,
                  gravity: 0.2,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

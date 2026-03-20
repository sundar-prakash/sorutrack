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
import '../../../../core/services/gemini_key_service.dart';

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

  // ─── Navigation ───────────────────────────────────────────
  void _onNext() {
    final cubit = context.read<OnboardingCubit>();

    if (cubit.state.currentStep < 6) {
      if (cubit.nextStep()) {
        _pageController.animateToPage(
          cubit.state.currentStep,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    } else {
      // Last step — handle Gemini key validation before finishing
      _handleFinish();
    }
  }

  Future<void> _handleFinish() async {
    final cubit = context.read<OnboardingCubit>();
    final key = cubit.state.geminiApiKey.trim();

    if (key.isEmpty) {
      // No key — warn user
      final proceed = await _showNoKeyDialog();
      if (!proceed) return;
      _doSubmit();
      return;
    }

    // Key is present — test it live
    setState(() {}); // trigger isSubmitting UI via cubit
    final result = await cubit.validateAndTestGeminiKey();

    if (!mounted) return;

    if (result == ApiKeyValidationResult.valid ||
        result == ApiKeyValidationResult.rateLimited) {
      // Valid (or rate limited — key exists) → proceed
      _doSubmit();
    } else {
      // Invalid/network error — warn user
      final proceed = await _showInvalidKeyDialog(result);
      if (!proceed) return;
      _doSubmit();
    }
  }

  void _doSubmit() {
    final cubit = context.read<OnboardingCubit>();
    _confettiController.play();
    Future.delayed(const Duration(seconds: 2), () {
      cubit.submit().then((_) {
        if (mounted) context.go('/dashboard');
      });
    });
  }

  Future<bool> _showNoKeyDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.warning_amber_rounded,
                color: Colors.orange, size: 40),
            title: const Text('No Gemini API Key'),
            content: const Text(
              'Without a Gemini API key, AI meal parsing won\'t work.\n\n'
              'You can add one later in Settings → AI Settings.\n\n'
              'Continue without AI features?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('GO BACK'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white),
                child: const Text('CONTINUE ANYWAY'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showInvalidKeyDialog(ApiKeyValidationResult result) async {
    final message = result == ApiKeyValidationResult.networkError
        ? 'Could not connect to verify your key. Check your internet connection.'
        : 'The key you entered appears to be invalid. AI meal parsing won\'t work.';

    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            icon:
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
            title: const Text('Invalid Gemini Key'),
            content: Text(
              '$message\n\nYou can fix this later in Settings → AI Settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('FIX KEY'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white),
                child: const Text('CONTINUE ANYWAY'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _onSkip() => context.go('/dashboard');

  void _onBack() {
    final cubit = context.read<OnboardingCubit>();
    if (cubit.state.currentStep > 0) {
      cubit.previousStep();
      _pageController.animateToPage(
        cubit.state.currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  // ─── Build ────────────────────────────────────────────────
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
                    // Top Bar
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
                            const SizedBox(width: 48),

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
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4),
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
                            error:
                                state.currentStep == 0 ? state.error : null,
                            onNameChanged: cubit.updateName,
                            onDateOfBirthChanged: cubit.updateDateOfBirth,
                            onGenderChanged: cubit.updateGender,
                          ),
                          OnboardingStep2(
                            height: state.height,
                            heightUnit: state.heightUnit,
                            weight: state.weight,
                            weightUnit: state.weightUnit,
                            error:
                                state.currentStep == 1 ? state.error : null,
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
                            error:
                                state.currentStep == 4 ? state.error : null,
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
                              onPressed:
                                  state.isSubmitting ? null : _onNext,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: state.isSubmitting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
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
              // Confetti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 2,
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

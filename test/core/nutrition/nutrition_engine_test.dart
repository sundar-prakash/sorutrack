import 'package:flutter_test/flutter_test.dart';
import 'package:sorutrack_pro/core/nutrition/nutrition_engine.dart';
import 'package:sorutrack_pro/features/auth/domain/models/auth_enums.dart';

void main() {
  group('NutritionEngine Tests', () {
    test('calculateBMRMifflin - Male', () {
      final bmr = NutritionEngine.calculateBMRMifflin(70, 175, 25, Gender.male);
      // (10 * 70) + (6.25 * 175) - (5 * 25) + 5 = 700 + 1093.75 - 125 + 5 = 1673.75
      expect(bmr, 1673.75);
    });

    test('calculateBMRMifflin - Female', () {
      final bmr = NutritionEngine.calculateBMRMifflin(60, 165, 30, Gender.female);
      // (10 * 60) + (6.25 * 165) - (5 * 30) - 161 = 600 + 1031.25 - 150 - 161 = 1320.25
      expect(bmr, 1320.25);
    });

    test('calculateTDEE - Sedentary', () {
      final tdee = NutritionEngine.calculateTDEE(1673.75, ActivityLevel.sedentary);
      expect(tdee, 1673.75 * 1.2);
    });

    test('calculateCalorieTarget - Lose Weight', () {
      final target = NutritionEngine.calculateCalorieTarget(
        2500,
        GoalType.loseWeight,
        0.5,
        Gender.male,
        false,
        false,
      );
      // 2500 - (0.5 * 7700 / 7) = 2500 - 550 = 1950
      expect(target, 1950);
    });

    test('calculateCalorieTarget - Minimum Floor (Female)', () {
      final target = NutritionEngine.calculateCalorieTarget(
        1300,
        GoalType.loseWeight,
        1.0,
        Gender.female,
        false,
        false,
      );
      // 1300 - 1100 = 200, should be 1200
      expect(target, 1200);
    });

    test('lbsToKg - conversion', () {
      expect(NutritionEngine.lbsToKg(154.324), closeTo(70, 0.1));
    });
  });
}

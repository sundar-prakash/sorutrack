import 'package:flutter_test/flutter_test.dart';
import 'package:sorutrack_pro/core/nutrition/nutrition_calculator.dart';

void main() {
  group('Nutrition Calculator Tests', () {
    test('Mifflin BMR - male 30yo 70kg 175cm', () {
      expect(
        NutritionCalculator.bmrMifflin(gender: 'male', weight: 70, height: 175, age: 30),
        closeTo(1695, 1),
      );
    });

    test('Mifflin BMR - female 25yo 60kg 160cm', () {
      expect(
        NutritionCalculator.bmrMifflin(gender: 'female', weight: 60, height: 160, age: 25),
        closeTo(1390, 1),
      );
    });

    test('TDEE - very active', () {
      final bmr = 1695.0;
      expect(NutritionCalculator.tdee(bmr, 'very active'), closeTo(bmr * 1.725, 0.1));
    });

    test('Calorie target - weight loss capped at -1000', () {
      final tdee = 3000.0;
      // 1kg loss per week = 7700 / 7 = 1100 deficit
      final target = NutritionCalculator.calculateCalorieTarget(
        tdee: tdee,
        goal: 'weight loss',
        weeklyGoalKg: 1.0,
        gender: 'male',
      );
      // Deficit is 1100, but capped at 1000
      expect(target, 2000.0);
    });

    test('Macro calculator - protein priority', () {
      final targetCalories = 2000.0;
      final weight = 70.0;
      final result = NutritionCalculator.calculateMacros(
        targetCalories: targetCalories,
        weight: weight,
        goal: 'gain muscle',
      );
      
      // Gain muscle -> 2.0g protein/kg
      expect(result['protein'], 140.0);
      // 140 * 4 = 560 fat calories
      // Fat = 25% of 2000 = 500 calories = 55.5g
      expect(result['fat'], closeTo(55.55, 0.1));
      // Carbs = 2000 - 560 - 500 = 940 calories = 235g
      expect(result['carbs'], 235.0);
    });

    test('Water target - 70kg person needs 2450ml', () {
      expect(NutritionCalculator.waterTarget(70), 2450.0);
    });

    test('BMI categories - underweight/normal/overweight/obese', () {
      expect(NutritionCalculator.bmiCategory(50, 180), 'underweight');
      expect(NutritionCalculator.bmiCategory(70, 175), 'normal');
      expect(NutritionCalculator.bmiCategory(85, 175), 'overweight');
      expect(NutritionCalculator.bmiCategory(110, 175), 'obese');
    });

    test('Unit conversion - lbs to kg', () {
      expect(NutritionCalculator.lbsToKg(154.32), closeTo(70, 0.1));
    });

    test('Unit conversion - feet/inches to cm', () {
      expect(NutritionCalculator.feetInchesToCm(5, 9), closeTo(175.26, 0.1));
    });

    test('Extreme values - 30kg person - warns and clamps', () {
       // Clamp to 30 as per implementation in NutritionCalculator
       final bmrSmall = NutritionCalculator.bmrMifflin(gender: 'male', weight: 20, height: 175, age: 30);
       final bmr30 = NutritionCalculator.bmrMifflin(gender: 'male', weight: 30, height: 175, age: 30);
       expect(bmrSmall, bmr30);
    });

    test('Extreme values - 300kg person - handles gracefully', () {
       final bmr = NutritionCalculator.bmrMifflin(gender: 'male', weight: 300, height: 175, age: 30);
       expect(bmr, closeTo(4777, 1));
    });

    test('Age 0 throws assertion', () {
      expect(() => NutritionCalculator.bmrMifflin(gender: 'male', weight: 70, height: 175, age: 0), throwsAssertionError);
    });

    test('Age 150 throws assertion', () {
      expect(() => NutritionCalculator.bmrMifflin(gender: 'male', weight: 70, height: 175, age: 150), throwsAssertionError);
    });
  });
}

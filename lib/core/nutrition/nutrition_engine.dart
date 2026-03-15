import 'dart:math';
import '../../features/auth/domain/models/auth_enums.dart';
import '../../features/auth/domain/models/user_profile.dart';

class NutritionEngine {
  /// Calculates Basal Metabolic Rate (BMR) using Mifflin-St Jeor formula (Default)
  static double calculateBMRMifflin(
    double weightKg,
    double heightCm,
    int age,
    Gender gender,
  ) {
    if (gender == Gender.male) {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
  }

  /// Calculates BMR using Harris-Benedict formula (Revised 1984)
  static double calculateBMRHarrisBenedict(
    double weightKg,
    double heightCm,
    int age,
    Gender gender,
  ) {
    if (gender == Gender.male) {
      return 88.362 + (13.397 * weightKg) + (4.799 * heightCm) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weightKg) + (3.098 * heightCm) - (4.330 * age);
    }
  }

  /// Calculates BMR using Katch-McArdle formula (requires body fat percentage)
  static double calculateBMRKatchMcArdle(double weightKg, double bodyFatPercentage) {
    final leanBodyMass = weightKg * (1 - (bodyFatPercentage / 100));
    return 370 + (21.6 * leanBodyMass);
  }

  /// Calculates BMR using Schofield equation
  static double calculateBMRSchofield(
    double weightKg,
    int age,
    Gender gender,
  ) {
    if (gender == Gender.male) {
      if (age < 3) return (59.512 * weightKg) - 30.4;
      if (age < 10) return (22.706 * weightKg) + 504.3;
      if (age < 18) return (17.686 * weightKg) + 658.2;
      if (age < 30) return (15.057 * weightKg) + 692.2;
      if (age < 60) return (11.472 * weightKg) + 873.1;
      return (11.711 * weightKg) + 587.7;
    } else {
      if (age < 3) return (58.317 * weightKg) - 31.1;
      if (age < 10) return (20.315 * weightKg) + 485.9;
      if (age < 18) return (13.384 * weightKg) + 692.6;
      if (age < 30) return (14.818 * weightKg) + 486.6;
      if (age < 60) return (8.126 * weightKg) + 845.6;
      return (9.082 * weightKg) + 658.5;
    }
  }

  /// Total Daily Energy Expenditure (TDEE)
  static double calculateTDEE(double bmr, ActivityLevel activityLevel) {
    final multiplier = switch (activityLevel) {
      ActivityLevel.sedentary => 1.2,
      ActivityLevel.lightlyActive => 1.375,
      ActivityLevel.moderatelyActive => 1.55,
      ActivityLevel.veryActive => 1.725,
      ActivityLevel.extraActive => 1.9,
    };
    return bmr * multiplier;
  }

  /// Calculates target calories based on goal
  static double calculateCalorieTarget(
    double tdee,
    GoalType goal,
    double weeklyGoalKg,
    Gender gender,
    bool isPregnant,
    bool isLactating,
  ) {
    double target = tdee;

    switch (goal) {
      case GoalType.loseWeight:
        // 7700 kcal per kg approx
        final deficit = (weeklyGoalKg * 7700) / 7;
        target -= deficit;
        // Max aggressive deficit check
        if (tdee - target > 1000) target = tdee - 1000;
        break;
      case GoalType.gainMuscle:
        target += 350; // Standard surplus for muscle gain
        break;
      case GoalType.maintain:
      case GoalType.improveHealth:
      case GoalType.custom:
        break;
    }

    // Pregnancy/Lactation adjustments
    if (isPregnant) target += 300;
    if (isLactating) target += 500;

    // Safety floors
    final minimumCalories = gender == Gender.male ? 1500.0 : 1200.0;
    return max(target, minimumCalories);
  }

  /// Calculate Macros
  static Map<String, double> calculateMacros(
    double targetCalories,
    double weightKg,
    GoalType goal,
  ) {
    // Protein: 1.6 - 2.2g per kg (using 1.8 as default, 2.0 for muscle gain)
    double proteinPerKg = (goal == GoalType.gainMuscle) ? 2.0 : 1.8;
    double proteinGrams = weightKg * proteinPerKg;
    double proteinCalories = proteinGrams * 4;

    // Fat: 20-35% of calories (using 25% as default)
    double fatCalories = targetCalories * 0.25;
    double fatGrams = fatCalories / 9;

    // Carbs: Remaining
    double carbCalories = targetCalories - proteinCalories - fatCalories;
    double carbGrams = carbCalories / 4;

    return {
      'protein': proteinGrams,
      'fat': fatGrams,
      'carbs': carbGrams,
    };
  }

  /// Fiber target
  static double calculateFiberTarget(int age) {
    return age + 5.0; // Simple rule of thumb, or 25-38g range
  }

  /// Water target in ml
  static double calculateWaterTarget(double weightKg) {
    return weightKg * 35; // 35ml per kg
  }

  /// BMI
  static double calculateBMI(double weightKg, double heightCm) {
    final heightMeters = heightCm / 100;
    return weightKg / (heightMeters * heightMeters);
  }

  /// Convert lbs to kg
  static double lbsToKg(double lbs) => lbs * 0.453592;

  /// Convert kg to lbs
  static double kgToLbs(double kg) => kg / 0.453592;

  /// Convert ft to cm
  static double ftToCm(double ft) => ft * 30.48;

  /// Convert cm to ft
  static double cmToFt(double cm) => cm / 30.48;
}

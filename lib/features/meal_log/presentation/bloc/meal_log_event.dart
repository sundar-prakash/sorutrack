import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/parsed_meal.dart';

part 'meal_log_event.freezed.dart';

@freezed
class MealLogEvent with _$MealLogEvent {
  const factory MealLogEvent.parseMeal(String input, String mealType) = ParseMealEvent;
  const factory MealLogEvent.updateMeal(ParsedMeal meal) = UpdateMealEvent;
  const factory MealLogEvent.saveMeal(ParsedMeal meal) = SaveMealEvent;
  const factory MealLogEvent.reset() = ResetEvent;
}

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/parsed_meal.dart';

part 'meal_log_state.freezed.dart';

@freezed
class MealLogState with _$MealLogState {
  const factory MealLogState.initial() = _Initial;
  const factory MealLogState.analyzing() = _Analyzing;
  const factory MealLogState.reviewing(ParsedMeal meal) = _Reviewing;
  const factory MealLogState.saving() = _Saving;
  const factory MealLogState.success() = _Success;
  const factory MealLogState.error(String message) = _Error;
}

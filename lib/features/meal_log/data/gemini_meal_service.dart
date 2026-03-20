import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../core/error/failures.dart';
import '../../../core/services/gemini_key_service.dart';
import '../domain/models/parsed_meal.dart';

@injectable
class GeminiMealService {
  final GeminiKeyService _keyService;

  GeminiMealService(this._keyService);

  final String _systemPrompt = """
You are a precise nutrition database assistant. Parse the user's meal description and return ONLY valid JSON with no markdown, no explanation, no extra text.

Parse each food item separately. For restaurant/homemade items, estimate based on standard portions. For Indian foods: idly (1 piece = 39g ≈ 39 cal), sambar (per cup = 90 cal), etc. Use IFCT (Indian Food Composition Tables) data.

Return this EXACT JSON structure:
{
  "meal_name": "Breakfast - Idly Sambar",
  "meal_time": "morning",
  "meal_type": "breakfast",
  "confidence_score": 0.92,
  "total_calories": 385,
  "total_protein_g": 12.4,
  "total_carbs_g": 68.2,
  "total_fat_g": 6.8,
  "total_fiber_g": 4.2,
  "items": [
    {
      "name": "Idly",
      "quantity": 4,
      "unit": "piece",
      "weight_g": 156,
      "calories": 152,
      "protein_g": 4.8,
      "carbs_g": 30.2,
      "fat_g": 0.8,
      "fiber_g": 1.2,
      "sodium_mg": 240,
      "sugar_g": 0.4,
      "glycemic_index": 69,
      "serving_description": "4 medium idly (39g each)",
      "notes": "Steamed rice cake, fermented batter"
    },
    {
      "name": "Sambar",
      "quantity": 1,
      "unit": "bowl",
      "weight_g": 240,
      "calories": 110,
      "protein_g": 5.2,
      "carbs_g": 18.4,
      "fat_g": 2.8,
      "fiber_g": 3.8,
      "sodium_mg": 380,
      "sugar_g": 3.2,
      "glycemic_index": 35,
      "serving_description": "1 medium bowl sambar (suitable for 4 idly)",
      "notes": "Lentil vegetable stew with tamarind"
    }
  ],
  "warnings": [],
  "alternatives_suggested": ["Plain dosa instead for lower carbs", "Add coconut chutney for healthy fats"]
}
""";

  Future<Either<Failure, ParsedMeal>> parseNaturalLanguageMeal(String userInput, String mealType) async {
    final apiKey = await _keyService.getKey();
    if (apiKey == null) {
      return Left(ServerFailure('No Gemini API key configured. Please add your key in Settings.'));
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final content = [
        Content.text(_systemPrompt),
        Content.text("User Input: $userInput\nMeal Type: $mealType"),
      ];

      final response = await model.generateContent(content);
      final text = response.text;

      if (text == null || text.isEmpty) {
        return Left(ServerFailure('Empty response from Gemini'));
      }

      final jsonData = jsonDecode(text);
      return Right(ParsedMeal.fromJson(jsonData));
    } catch (e) {
      return Left(ServerFailure('Failed to parse meal: ${e.toString()}'));
    }
  }

  // Placeholder for other methods requested
  Future<Either<Failure, ParsedMeal>> parseWithImage(dynamic image, String? additionalContext) async {
    // Implementation for image parsing
    return Left(ServerFailure('Image parsing not implemented yet'));
  }

  Future<Either<Failure, ParsedMeal>> correctParsedMeal(ParsedMeal original, String correction) async {
    // Implementation for correction
    return Left(ServerFailure('Correction not implemented yet'));
  }
}

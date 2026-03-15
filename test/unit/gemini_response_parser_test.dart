import 'package:flutter_test/flutter_test.dart';
import 'package:sorutrack_pro/features/meal_log/data/gemini_response_parser.dart';

void main() {
  group('Gemini Response Parser Tests', () {
    test('Parse valid JSON with all fields', () {
      final response = '''
      {
        "meal_name": "Lunch",
        "meal_time": "afternoon",
        "meal_type": "lunch",
        "confidence_score": 0.95,
        "total_calories": 500,
        "total_protein_g": 20,
        "total_carbs_g": 60,
        "total_fat_g": 15,
        "items": [
          {
            "name": "Rice",
            "quantity": 1,
            "unit": "cup",
            "calories": 200,
            "protein_g": 4,
            "carbs_g": 45,
            "fat_g": 0.5
          }
        ]
      }
      ''';
      final result = GeminiResponseParser.parse(response);
      expect(result.isRight(), true);
      result.fold((l) => fail('Should be right'), (meal) {
        expect(meal.mealName, 'Lunch');
        expect(meal.items.length, 1);
        expect(meal.items.first.name, 'Rice');
      });
    });

    test('Parse JSON missing optional fields - uses defaults', () {
      // Assuming ParsedMeal.fromJson handles optional fields or defaults
      final response = '''
      {
        "meal_name": "Snack",
        "items": []
      }
      ''';
      final result = GeminiResponseParser.parse(response);
      expect(result.isRight(), true);
    });

    test('Detect malformed JSON - returns Failure', () {
      final response = '{"meal_name": "Lunch", "items": [}';
      final result = GeminiResponseParser.parse(response);
      expect(result.isLeft(), true);
    });

    test('Parse idly-sambar response correctly', () {
      final response = '''
      {
        "meal_name": "Breakfast",
        "items": [
          {
            "name": "Idly",
            "quantity": 4,
            "unit": "piece",
            "calories": 152,
            "protein_g": 4.8,
            "carbs_g": 30.2,
            "fat_g": 0.8
          }
        ]
      }
      ''';
      final result = GeminiResponseParser.parse(response);
      expect(result.isRight(), true);
      result.fold((l) => fail('Should be right'), (meal) {
        expect(meal.items.first.name, 'Idly');
        expect(meal.items.first.quantity, 4);
      });
    });

    test('Handle Gemini timeout - returns Failure', () {
      // Parser doesn't handle timeout directly, the service does.
      // But we can test empty response if that's what a timeout might look like to the parser.
      final result = GeminiResponseParser.parse('');
      expect(result.isLeft(), true);
    });
  });
}

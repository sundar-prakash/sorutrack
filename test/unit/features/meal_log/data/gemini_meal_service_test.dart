import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sorutrack_pro/features/meal_log/data/gemini_meal_service.dart';
import 'package:sorutrack_pro/core/services/gemini_key_service.dart';
import 'package:sorutrack_pro/core/services/gemini_client.dart';
import 'package:sorutrack_pro/core/error/failures.dart';

import 'gemini_meal_service_test.mocks.dart';

@GenerateMocks([
  GeminiKeyService,
  GeminiClient,
])
void main() {
  late MockGeminiKeyService mockKeyService;
  late MockGeminiClient mockGeminiClient;
  late GeminiMealService service;

  setUp(() {
    mockKeyService = MockGeminiKeyService();
    mockGeminiClient = MockGeminiClient();
    service = GeminiMealService(mockKeyService, mockGeminiClient);
  });

  group('GeminiMealService', () {
    const validKey = 'AIzaSyA_TestKey';

    test('parseNaturalLanguageMeal returns ServerFailure if no API key', () async {
      when(mockKeyService.getKey()).thenAnswer((_) async => null);

      final result = await service.parseNaturalLanguageMeal('I ate 4 idly', 'breakfast');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should have returned a failure'),
      );
    });

    test('parseNaturalLanguageMeal returns ParsedMeal on success', () async {
      when(mockKeyService.getKey()).thenAnswer((_) async => validKey);
      
      final mockJsonResponse = {
        "meal_name": "Idly Breakfast",
        "meal_time": "morning",
        "meal_type": "breakfast",
        "confidence_score": 0.95,
        "total_calories": 200,
        "total_protein_g": 5.0,
        "total_carbs_g": 40.0,
        "total_fat_g": 1.0,
        "total_fiber_g": 2.0,
        "items": [],
        "warnings": [],
        "alternatives_suggested": []
      };

      when(mockGeminiClient.generateContent(
        apiKey: anyNamed('apiKey'),
        modelName: anyNamed('modelName'),
        content: anyNamed('content'),
        generationConfig: anyNamed('generationConfig'),
      )).thenAnswer((_) async => jsonEncode(mockJsonResponse));

      final result = await service.parseNaturalLanguageMeal('I ate 4 idly', 'breakfast');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should have returned a right'),
        (meal) => expect(meal.mealName, 'Idly Breakfast'),
      );
    });

    test('parseNaturalLanguageMeal returns failure on empty Gemini response', () async {
      when(mockKeyService.getKey()).thenAnswer((_) async => validKey);
      when(mockGeminiClient.generateContent(
        apiKey: anyNamed('apiKey'),
        modelName: anyNamed('modelName'),
        content: anyNamed('content'),
        generationConfig: anyNamed('generationConfig'),
      )).thenAnswer((_) async => '');

      final result = await service.parseNaturalLanguageMeal('I ate 4 idly', 'breakfast');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect((failure as ServerFailure).message, contains('Empty response')),
        (_) => fail('Should have failed'),
      );
    });

    test('parseNaturalLanguageMeal returns failure on Gemini exception', () async {
      when(mockKeyService.getKey()).thenAnswer((_) async => validKey);
      when(mockGeminiClient.generateContent(
        apiKey: anyNamed('apiKey'),
        modelName: anyNamed('modelName'),
        content: anyNamed('content'),
        generationConfig: anyNamed('generationConfig'),
      )).thenThrow(Exception('Network Error'));

      final result = await service.parseNaturalLanguageMeal('I ate 4 idly', 'breakfast');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect((failure as ServerFailure).message, contains('Failed to parse meal')),
        (_) => fail('Should have failed'),
      );
    });
  });
}

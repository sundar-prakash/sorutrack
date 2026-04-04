import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sorutrack_pro/features/reports/data/services/gemini_reports_service.dart';
import 'package:sorutrack_pro/core/services/gemini_key_service.dart';
import 'package:sorutrack_pro/core/services/gemini_client.dart';
import 'package:sorutrack_pro/features/reports/domain/models/report_models.dart';

import 'gemini_reports_service_test.mocks.dart';

@GenerateMocks([
  GeminiKeyService,
  GeminiClient,
])
void main() {
  late MockGeminiKeyService mockKeyService;
  late MockGeminiClient mockGeminiClient;
  late GeminiReportsService service;

  setUp(() {
    mockKeyService = MockGeminiKeyService();
    mockGeminiClient = MockGeminiClient();
    service = GeminiReportsService(mockKeyService, mockGeminiClient);
  });

  group('GeminiReportsService', () {
    const validKey = 'AIzaSyA_TestKey';
    const emptyMicros = MicronutrientData(fiber: 0, sodium: 0, sugar: 0, potassium: 0);

    test('generateWeeklyInsights returns Gemini response on success', () async {
      when(mockKeyService.getKey()).thenAnswer((_) async => validKey);
      
      when(mockGeminiClient.generateContent(
        apiKey: anyNamed('apiKey'),
        modelName: anyNamed('modelName'),
        content: anyNamed('content'),
        safetySettings: anyNamed('safetySettings'),
        generationConfig: anyNamed('generationConfig'),
        tools: anyNamed('tools'),
        toolConfig: anyNamed('toolConfig'),
      )).thenAnswer((_) async => 'Insightful advice.');

      final result = await service.generateWeeklyInsights(
        calories: [const ReportTrendData(date: '2024-01-01', value: 2000)],
        macros: [const MacroDistribution(date: '2024-01-01', protein: 100, carbs: 200, fat: 50)],
        topFoods: [const TopFood(name: 'Apple', frequency: 5, totalCalories: 400)],
        micros: const MicronutrientData(fiber: 25, sodium: 2000, sugar: 50, potassium: 3500),
      );

      expect(result, 'Insightful advice.');
      verify(mockGeminiClient.generateContent(
        apiKey: anyNamed('apiKey'),
        modelName: anyNamed('modelName'),
        content: anyNamed('content'),
      )).called(1);
    });

    test('generateWeeklyInsights returns error if no API key', () async {
      when(mockKeyService.getKey()).thenAnswer((_) async => null);

      final result = await service.generateWeeklyInsights(
        calories: [],
        macros: [],
        topFoods: [],
        micros: emptyMicros,
      );

      expect(result, contains('No API key found'));
    });

    test('generateWeeklyInsights handles empty input lists gracefully', () async {
      when(mockKeyService.getKey()).thenAnswer((_) async => validKey);
      
      when(mockGeminiClient.generateContent(
        apiKey: anyNamed('apiKey'),
        modelName: anyNamed('modelName'),
        content: anyNamed('content'),
      )).thenAnswer((_) async => 'No data advice.');

      final result = await service.generateWeeklyInsights(
        calories: [],
        macros: [],
        topFoods: [],
        micros: emptyMicros,
      );

      expect(result, 'No data advice.');
    });

    test('generateWeeklyInsights returns error on exception', () async {
      when(mockKeyService.getKey()).thenAnswer((_) async => validKey);
      when(mockGeminiClient.generateContent(
        apiKey: anyNamed('apiKey'),
        modelName: anyNamed('modelName'),
        content: anyNamed('content'),
      )).thenThrow(Exception('API Down'));

      final result = await service.generateWeeklyInsights(
        calories: [],
        macros: [],
        topFoods: [],
        micros: emptyMicros,
      );

      expect(result, contains('Error generating insights'));
    });
  });
}

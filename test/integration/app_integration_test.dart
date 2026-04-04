import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:sorutrack_pro/app.dart';
import 'package:sorutrack_pro/core/di/injection.dart';
import 'package:sorutrack_pro/features/meal_log/data/gemini_meal_service.dart';
import 'package:sorutrack_pro/features/meal_log/domain/models/parsed_meal.dart';
import 'package:sorutrack_pro/core/database/database_helper.dart';
import '../helpers/mock_hydrated_storage.dart';
import 'app_integration_test.mocks.dart';

@GenerateMocks([GeminiMealService])
void main() {
  

  late MockGeminiMealService mockGeminiService;

  final sampleMeal = ParsedMeal(
    mealName: 'Test Meal',
    mealTime: 'morning',
    mealType: 'breakfast',
    confidenceScore: 0.9,
    totalCalories: 300,
    totalProteinG: 10,
    totalCarbsG: 40,
    totalFatG: 5,
    totalFiberG: 2,
    items: [
      const ParsedMealItem(
        name: 'Apple',
        quantity: 1,
        unit: 'piece',
        weightG: 150,
        calories: 95,
        proteinG: 0.5,
        carbsG: 25,
        fatG: 0.3,
        fiberG: 4.4,
        sodiumMg: 2,
        sugarG: 19,
        glycemicIndex: 38,
        servingDescription: '1 medium apple',
        notes: 'Fresh fruit',
      ),
    ],
    warnings: [],
    alternativesSuggested: [],
  );

  setUpAll(() async {
    // Initialize mock storage for HydratedBloc
    mockHydratedStorage();
    
    // Initialize standard dependencies
    getIt.allowReassignment = true;
    if (!getIt.isRegistered<DatabaseHelper>()) {
      await configureDependencies();
    }
  });

  setUp(() async {
    mockGeminiService = MockGeminiMealService();
    
    // Stub Gemini
    when(mockGeminiService.parseNaturalLanguageMeal(any, any))
        .thenAnswer((_) async => Right(sampleMeal));
  });

  testWidgets('End-to-end meal logging flow', (WidgetTester tester) async {
    // 1. Initialize and Start the app
    await tester.pumpWidget(const SoruTrackProApp());
    await tester.pump(const Duration(seconds: 2));

    // 2. Override mocking after app.main() has initialized DI
    getIt.registerSingleton<GeminiMealService>(mockGeminiService);
    
    // Switch to test database
    final dbHelper = getIt<DatabaseHelper>();
    await dbHelper.openTestDatabase();

    // 3. Verify Dashboard
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.textContaining('0 kcal'), findsOneWidget); // Assuming fresh DB

    // 4. Navigate to Quick Add
    await tester.tap(find.byIcon(Icons.add)); // Assuming there's an add button or fab
    await tester.pump(const Duration(seconds: 1));

    // 5. Enter Meal Description
    await tester.enterText(find.byType(TextField), 'I ate an apple');
    await tester.tap(find.text('ANALYZE MEAL'));
    await tester.pump(const Duration(seconds: 1));

    // 6. Review Data (ParsedResultsScreen)
    expect(find.text('Test Meal'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('SAVE TO LOG'), findsOneWidget);

    // 7. Save to Log
    await tester.tap(find.text('SAVE TO LOG'));
    await tester.pump(const Duration(seconds: 1));

    // 8. Verify back on Dashboard and calories updated
    expect(find.text('SoruTrack Pro'), findsOneWidget);
    expect(find.text('300 kcal'), findsOneWidget);
  });
}

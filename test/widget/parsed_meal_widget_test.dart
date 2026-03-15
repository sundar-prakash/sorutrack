import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sorutrack_pro/features/meal_log/presentation/bloc/meal_log_bloc.dart';
import 'package:sorutrack_pro/features/meal_log/presentation/bloc/meal_log_event.dart';
import 'package:sorutrack_pro/features/meal_log/presentation/bloc/meal_log_state.dart';
import 'package:sorutrack_pro/features/meal_log/presentation/screens/parsed_results_screen.dart';
import 'package:sorutrack_pro/features/meal_log/domain/models/parsed_meal.dart';

import 'parsed_meal_widget_test.mocks.dart';

@GenerateMocks([MealLogBloc])
void main() {
  late MockMealLogBloc mockMealLogBloc;

  final sampleMeal = ParsedMeal(
    mealName: 'Healthy Lunch',
    mealTime: 'afternoon',
    mealType: 'lunch',
    confidenceScore: 0.95,
    totalCalories: 450,
    totalProteinG: 25,
    totalCarbsG: 60,
    totalFatG: 12,
    totalFiberG: 8,
    items: [
      const ParsedMealItem(
        name: 'Quinoa Salad',
        quantity: 1,
        unit: 'bowl',
        weightG: 250,
        calories: 350,
        proteinG: 10,
        carbsG: 50,
        fatG: 8,
        fiberG: 6,
        sodiumMg: 300,
        sugarG: 4,
        glycemicIndex: 53,
        servingDescription: '1 medium bowl of quinoa salad',
        notes: 'High in fiber and protein',
      ),
      const ParsedMealItem(
        name: 'Guacamole',
        quantity: 2,
        unit: 'tbsp',
        weightG: 30,
        calories: 100,
        proteinG: 15, // Total item protein
        carbsG: 10,  // Total item carbs
        fatG: 4,    // Total item fat
        fiberG: 2,
        sodiumMg: 50,
        sugarG: 0,
        glycemicIndex: 15,
        servingDescription: '2 tablespoons of guacamole',
        notes: 'Healthy fats',
      ),
    ],
    warnings: [],
    alternativesSuggested: ['Add points for avocado', 'Reduce salt'],
  );

  setUp(() {
    mockMealLogBloc = MockMealLogBloc();
    when(mockMealLogBloc.state).thenReturn(const MealLogState.initial());
    when(mockMealLogBloc.stream).thenAnswer((_) => const Stream<MealLogState>.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<MealLogBloc>.value(
        value: mockMealLogBloc,
        child: ParsedResultsScreen(meal: sampleMeal),
      ),
    );
  }

  testWidgets('renders meal name and confidence score', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Healthy Lunch'), findsOneWidget);
    expect(find.text('Confidence: 95%'), findsOneWidget);
  });

  testWidgets('renders all food items with calories', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Quinoa Salad'), findsOneWidget);
    expect(find.text('Guacamole'), findsOneWidget);
    expect(find.text('350 cal'), findsOneWidget);
    expect(find.text('100 cal'), findsOneWidget);
  });

  testWidgets('renders nutrition summary bar', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('450'), findsOneWidget); // Total Calories
    expect(find.text('25'), findsOneWidget);  // Total Protein
    expect(find.text('60'), findsOneWidget);  // Total Carbs
  });

  testWidgets('calls saveMeal when SAVE TO LOG pressed', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('SAVE TO LOG'));
    verify(mockMealLogBloc.add(any)).called(1);
  });
}

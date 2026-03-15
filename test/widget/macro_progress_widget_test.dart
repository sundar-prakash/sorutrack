import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/widgets/macro_bars_widget.dart';
import 'package:sorutrack_pro/features/dashboard/domain/models/dashboard_data.dart';

void main() {
  group('MacroBarsWidget Tests', () {
    const summary = DailyNutritionSummary(
      consumedCalories: 1500,
      targetCalories: 2000,
      burnedCalories: 200,
      proteinG: 100,
      proteinTargetG: 150,
      carbsG: 200,
      carbsTargetG: 250,
      fatG: 50,
      fatTargetG: 70,
      fiberG: 20,
      fiberTargetG: 30,
    );

    testWidgets('renders all macro bars with correct labels and values', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MacroBarsWidget(summary: summary),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check labels
      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('Carbs'), findsOneWidget);
      expect(find.text('Fat'), findsOneWidget);
      expect(find.text('Fiber'), findsOneWidget);

      // Check values
      expect(find.text('100 / 150g'), findsOneWidget);
      expect(find.text('200 / 250g'), findsOneWidget);
      expect(find.text('50 / 70g'), findsOneWidget);
      expect(find.text('20 / 30g'), findsOneWidget);
    });

    testWidgets('calculates and displays correct percentages', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MacroBarsWidget(summary: summary),
          ),
        ),
      );
      // Wait for FadeInLeft animations (100ms * index + animation duration)
      await tester.pumpAndSettle(const Duration(milliseconds: 1000));

      // Protein: 100/150 = 66.6% -> 67%
      expect(find.text('67%'), findsOneWidget);
      // Carbs: 200/250 = 80%
      expect(find.text('80%'), findsOneWidget);
      // Fat: 50/70 = 71.4% -> 71%
      expect(find.text('71%'), findsOneWidget);
      // Fiber: 20/30 = 66.6% -> 67%
      expect(find.text('67%'), findsNWidgets(2)); // Protein and Fiber are both 67%
    });
  });
}

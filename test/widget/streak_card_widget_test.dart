import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/widgets/streak_card_widget.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('StreakCardWidget', () {
    testWidgets('displays start message when streak is 0', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: StreakCardWidget()),
      ));
      await tester.pump(); // Start load
      await tester.pump(const Duration(milliseconds: 100)); // Complete load and advance frame

      // Assert
      expect(find.text('Start your streak today!'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department_outlined), findsOneWidget);
    });

    testWidgets('displays correct streak and label when streak is 5', (WidgetTester tester) async {
      // Arrange
      final today = DateTime.now();
      final todayStr = DateTime(today.year, today.month, today.day).toIso8601String();
      SharedPreferences.setMockInitialValues({
        'currentStreak': 5,
        'streakLastLogDate': todayStr,
      });

      // Act
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: StreakCardWidget()),
      ));
      await tester.pump(); // Start load
      await tester.pump(const Duration(milliseconds: 100)); // Complete load and advance frame

      // Assert
      expect(find.text('5'), findsOneWidget);
      expect(find.text('5 day streak 🔥'), findsOneWidget);
      expect(find.text('Logged'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('displays "Log today!" badge when streak is active but not logged today', (WidgetTester tester) async {
      // Arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayStr = DateTime(yesterday.year, yesterday.month, yesterday.day).toIso8601String();
      SharedPreferences.setMockInitialValues({
        'currentStreak': 3,
        'streakLastLogDate': yesterdayStr,
      });

      // Act
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: StreakCardWidget()),
      ));
      await tester.pump(); // Start load
      await tester.pump(const Duration(milliseconds: 100)); // Complete load and advance frame

      // Assert
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Log today!'), findsOneWidget);
    });

    test('recordActivity should increment streak from 0 to 1', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      await StreakCardWidget.recordActivity();

      // Assert
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('currentStreak'), 1);
      expect(prefs.getString('streakLastLogDate'), isNotNull);
    });

    test('recordActivity should increment streak from 1 to 2 when called next day', () async {
      // Arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayStr = DateTime(yesterday.year, yesterday.month, yesterday.day).toIso8601String();
      SharedPreferences.setMockInitialValues({
        'currentStreak': 1,
        'streakLastLogDate': yesterdayStr,
      });

      // Act
      await StreakCardWidget.recordActivity();

      // Assert
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('currentStreak'), 2);
    });
  });
}

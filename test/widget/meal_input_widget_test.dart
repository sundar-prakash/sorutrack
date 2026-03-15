import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sorutrack_pro/features/meal_log/presentation/bloc/meal_log_bloc.dart';
import 'package:sorutrack_pro/features/meal_log/presentation/bloc/meal_log_event.dart';
import 'package:sorutrack_pro/features/meal_log/presentation/bloc/meal_log_state.dart';
import 'package:sorutrack_pro/features/meal_log/presentation/screens/quick_add_screen.dart';
import 'dart:async';

import 'meal_input_widget_test.mocks.dart';

@GenerateMocks([MealLogBloc])
void main() {
  late MockMealLogBloc mockMealLogBloc;

  setUp(() {
    mockMealLogBloc = MockMealLogBloc();
    // Default stubs for BLoC
    when(mockMealLogBloc.state).thenReturn(const MealLogState.initial());
    when(mockMealLogBloc.stream).thenAnswer((_) => const Stream<MealLogState>.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<MealLogBloc>.value(
        value: mockMealLogBloc,
        child: const QuickAddScreen(),
      ),
    );
  }

  testWidgets('renders input field and analyze button', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('What did you eat?'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('ANALYZE MEAL'), findsOneWidget);
  });

  testWidgets('shows analyzing state when state is analyzing', (WidgetTester tester) async {
    when(mockMealLogBloc.state).thenReturn(const MealLogState.analyzing());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(seconds: 1)); // Finish fade in animation

    expect(find.text('Analyzing your meal...'), findsOneWidget);
  });

  testWidgets('adds ParseMeal event when analyze button pressed', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField), '4 idly');
    await tester.tap(find.text('ANALYZE MEAL'));

    verify(mockMealLogBloc.add(any)).called(1);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/widgets/header_section.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/cubit/dashboard_state.dart';

import 'streak_badge_widget_test.mocks.dart';

@GenerateMocks([DashboardCubit])
void main() {
  late MockDashboardCubit mockDashboardCubit;

  setUp(() {
    mockDashboardCubit = MockDashboardCubit();
    // Stub the stream and state
    when(mockDashboardCubit.stream).thenAnswer((_) => const Stream.empty());
    when(mockDashboardCubit.state).thenReturn(const DashboardState.initial());
    
    // Stub methods that return void
    when(mockDashboardCubit.previousDay()).thenReturn(null);
    when(mockDashboardCubit.nextDay()).thenReturn(null);
    when(mockDashboardCubit.loadDashboard(
      date: anyNamed('date'),
      isRefresh: anyNamed('isRefresh'),
    )).thenAnswer((_) async {});
  });

  testWidgets('renders greeting and streak correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<DashboardCubit>.value(
            value: mockDashboardCubit,
            child: HeaderSection(
              greeting: 'Good morning, Test!',
              streak: 5,
              selectedDate: DateTime.now(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Good morning, Test!'), findsOneWidget);
    expect(find.text('5 day streak!'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('renders specific date when not today', (WidgetTester tester) async {
    final date = DateTime(2023, 10, 20);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<DashboardCubit>.value(
            value: mockDashboardCubit,
            child: HeaderSection(
              greeting: 'Hello',
              streak: 0,
              selectedDate: date,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Oct 20, 2023'), findsOneWidget);
  });

  testWidgets('calls previousDay when left icon pressed', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<DashboardCubit>.value(
            value: mockDashboardCubit,
            child: HeaderSection(
              greeting: 'Hello',
              streak: 0,
              selectedDate: DateTime.now(),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.chevron_left));
    verify(mockDashboardCubit.previousDay()).called(1);
  });
}

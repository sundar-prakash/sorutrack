import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:sorutrack_pro/features/auth/presentation/cubit/profile_cubit.dart';

class MockDashboardCubit extends MockCubit<DashboardState> implements DashboardCubit {}
class MockProfileCubit extends MockCubit<ProfileState> implements ProfileCubit {}
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockDashboardCubit mockDashboardCubit;
  late MockProfileCubit mockProfileCubit;
  late MockGoRouter mockGoRouter;

  setUp(() {
    mockDashboardCubit = MockDashboardCubit();
    mockProfileCubit = MockProfileCubit();
    mockGoRouter = MockGoRouter();
    
    // Stub required methods
    when(() => mockDashboardCubit.loadDashboard(
      date: any(named: 'date'),
      isRefresh: any(named: 'isRefresh'),
    )).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<DashboardCubit>.value(value: mockDashboardCubit),
          BlocProvider<ProfileCubit>.value(value: mockProfileCubit),
        ],
        child: InheritedGoRouter(
          goRouter: mockGoRouter,
          child: const DashboardScreen(),
        ),
      ),
    );
  }

  testWidgets('renders loading state', (WidgetTester tester) async {
    when(() => mockDashboardCubit.state).thenReturn(const DashboardState.loading());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders error state with retry button', (WidgetTester tester) async {
    const errorMsg = 'Failed to load dashboard';
    when(() => mockDashboardCubit.state).thenReturn(const DashboardState.error(errorMsg));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text(errorMsg), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    verify(() => mockDashboardCubit.loadDashboard()).called(2);
  });
}

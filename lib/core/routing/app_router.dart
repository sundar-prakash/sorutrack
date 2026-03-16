import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/onboarding_screen.dart';
import '../../features/auth/presentation/pages/profile_screen.dart';
import '../../features/auth/presentation/pages/edit_profile_screen.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/food/presentation/pages/food_search_screen.dart';
import '../../features/food/presentation/pages/barcode_scanner_screen.dart';
import '../../features/food/presentation/pages/custom_food_screen.dart';
import '../../features/food/presentation/pages/recipe_builder_screen.dart';
import '../../features/meal_log/presentation/screens/meal_log_list_screen.dart';
import '../../features/meal_log/presentation/screens/quick_add_screen.dart';
import '../../features/reports/presentation/screens/reports_main_screen.dart';
import '../../features/goals/presentation/pages/goals_screen.dart';
import '../../features/goals/presentation/pages/goal_settings_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/data_management/presentation/pages/data_management_screen.dart';
import '../../shared/widgets/responsive_scaffold.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../../features/meal_log/presentation/bloc/meal_log_bloc.dart';
import '../../features/reports/presentation/bloc/reports_cubit.dart';
import '../../features/reports/presentation/bloc/report_filter_cubit.dart';
import '../../features/data_management/presentation/bloc/data_management_bloc.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ResponsiveScaffold(body: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: const DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/log',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: BlocProvider(
                create: (_) => getIt<MealLogBloc>(),
                child: const MealLogListScreen(),
              ),
            ),
          ),
          GoRoute(
            path: '/reports',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => getIt<ReportsCubit>()),
                  BlocProvider(create: (_) => ReportFilterCubit()),
                ],
                child: const ReportsMainScreen(),
              ),
            ),
          ),
          GoRoute(
            path: '/goals',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: const GoalsScreen(),
            ),
          ),
          GoRoute(
            path: '/more',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: const SettingsScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/goal-settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GoalSettingsScreen(),
      ),
      GoRoute(
        path: '/quick-add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<MealLogBloc>(),
          child: const QuickAddScreen(),
        ),
      ),
      GoRoute(
        path: '/data-management',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<DataManagementBloc>(),
          child: const DataManagementScreen(),
        ),
      ),
      GoRoute(
        path: '/food-search',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FoodSearchScreen(),
      ),
      GoRoute(
        path: '/barcode-scanner',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BarcodeScannerScreen(),
      ),
      GoRoute(
        path: '/custom-food',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CustomFoodScreen(),
      ),
      GoRoute(
        path: '/recipe-builder',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RecipeBuilderScreen(),
      ),
    ],
  );

  static CustomTransitionPage _buildPageWithTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Custom Slide + Fade transition
        const begin = Offset(0.05, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

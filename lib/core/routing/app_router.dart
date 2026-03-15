import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/onboarding_screen.dart';
import '../../features/auth/presentation/pages/profile_screen.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/food/presentation/pages/food_search_screen.dart';
import '../../features/food/presentation/pages/barcode_scanner_screen.dart';
import '../../features/food/presentation/pages/custom_food_screen.dart';
import '../../features/food/presentation/pages/recipe_builder_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../shared/widgets/placeholder_screen.dart';
import '../../shared/widgets/responsive_scaffold.dart';

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
              child: const PlaceholderScreen(title: 'Meal Log'),
            ),
          ),
          GoRoute(
            path: '/reports',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: const PlaceholderScreen(title: 'Reports'),
            ),
          ),
          GoRoute(
            path: '/goals',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: const PlaceholderScreen(title: 'Goals'),
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

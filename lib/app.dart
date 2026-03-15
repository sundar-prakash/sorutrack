import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'features/auth/presentation/cubit/onboarding_cubit.dart';
import 'features/auth/presentation/cubit/profile_cubit.dart';
import 'features/auth/presentation/pages/onboarding_screen.dart';
import 'features/auth/presentation/pages/profile_screen.dart';
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'features/dashboard/presentation/pages/dashboard_screen.dart';
import 'features/food/presentation/bloc/food_search/food_search_bloc.dart';
import 'features/food/presentation/bloc/barcode_scanner/barcode_scanner_bloc.dart';
import 'features/food/presentation/bloc/recipe_builder/recipe_builder_bloc.dart';
import 'features/food/presentation/pages/food_search_screen.dart';
import 'features/food/presentation/pages/barcode_scanner_screen.dart';
import 'features/food/presentation/pages/custom_food_screen.dart';
import 'features/food/presentation/pages/recipe_builder_screen.dart';
import 'shared/theme/app_theme.dart';
import 'core/routing/app_router.dart';

class SoruTrackProApp extends StatelessWidget {
  const SoruTrackProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<OnboardingCubit>()),
        BlocProvider(create: (context) => getIt<ProfileCubit>()..loadProfile('default_user')),
        BlocProvider(create: (context) => getIt<DashboardCubit>()),
        BlocProvider(create: (context) => getIt<FoodSearchBloc>()),
        BlocProvider(create: (context) => getIt<BarcodeScannerBloc>()),
        BlocProvider(create: (context) => getIt<RecipeBuilderBloc>()),
      ],
      child: MaterialApp.router(
        title: 'SoruTrack Pro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

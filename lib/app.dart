import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sorutrack_pro/features/auth/presentation/cubit/onboarding_cubit.dart';
import 'package:sorutrack_pro/features/auth/presentation/cubit/profile_cubit.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:sorutrack_pro/features/food/presentation/bloc/food_search/food_search_bloc.dart';
import 'package:sorutrack_pro/features/food/presentation/bloc/barcode_scanner/barcode_scanner_bloc.dart';
import 'package:sorutrack_pro/features/food/presentation/bloc/recipe_builder/recipe_builder_bloc.dart';
import 'package:sorutrack_pro/core/di/injection.dart';
import 'package:sorutrack_pro/shared/theme/app_theme.dart';
import 'package:sorutrack_pro/shared/theme/theme_cubit.dart';
import 'package:sorutrack_pro/core/routing/app_router.dart';
import 'package:sorutrack_pro/features/notifications/data/services/notification_service.dart';

class SoruTrackProApp extends StatefulWidget {
  const SoruTrackProApp({super.key});

  @override
  State<SoruTrackProApp> createState() => _SoruTrackProAppState();
}

class _SoruTrackProAppState extends State<SoruTrackProApp> {
  @override
  void initState() {
    super.initState();
    // Request notification permission on very first app launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<NotificationService>().requestPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<OnboardingCubit>()),
        BlocProvider(
            create: (context) =>
                getIt<ProfileCubit>()..loadProfile('default_user')),
        BlocProvider(create: (context) => getIt<DashboardCubit>()),
        BlocProvider(create: (context) => getIt<FoodSearchBloc>()),
        BlocProvider(create: (context) => getIt<BarcodeScannerBloc>()),
        BlocProvider(create: (context) => getIt<RecipeBuilderBloc>()),
        BlocProvider(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'SoruTrack Pro',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}

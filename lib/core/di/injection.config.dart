// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/repositories/user_repository_impl.dart'
    as _i687;
import '../../features/auth/domain/repositories/user_repository.dart' as _i926;
import '../../features/auth/domain/usecases/profile_use_cases.dart' as _i200;
import '../../features/auth/presentation/cubit/onboarding_cubit.dart' as _i348;
import '../../features/auth/presentation/cubit/profile_cubit.dart' as _i421;
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i509;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i665;
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart'
    as _i24;
import '../../features/data_management/data/services/backup_service.dart'
    as _i95;
import '../../features/data_management/data/services/export_service.dart'
    as _i367;
import '../../features/data_management/data/services/import_service.dart'
    as _i113;
import '../../features/data_management/presentation/bloc/data_management_bloc.dart'
    as _i70;
import '../../features/food/data/datasources/food_local_data_source.dart'
    as _i1004;
import '../../features/food/data/datasources/food_remote_data_source.dart'
    as _i81;
import '../../features/food/data/repositories/food_repository_impl.dart'
    as _i860;
import '../../features/food/domain/repositories/food_repository.dart' as _i780;
import '../../features/food/presentation/bloc/barcode_scanner/barcode_scanner_bloc.dart'
    as _i996;
import '../../features/food/presentation/bloc/food_search/food_search_bloc.dart'
    as _i214;
import '../../features/food/presentation/bloc/recipe_builder/recipe_builder_bloc.dart'
    as _i27;
import '../../features/gamification/data/repositories/gamification_repository_impl.dart'
    as _i358;
import '../../features/gamification/domain/repositories/gamification_repository.dart'
    as _i97;
import '../../features/gamification/domain/services/gamification_service.dart'
    as _i3;
import '../../features/gamification/presentation/bloc/gamification_bloc.dart'
    as _i638;
import '../../features/meal_log/data/gemini_meal_service.dart' as _i549;
import '../../features/meal_log/data/meal_repository_impl.dart' as _i115;
import '../../features/meal_log/domain/repositories/meal_repository.dart'
    as _i118;
import '../../features/meal_log/presentation/bloc/meal_log_bloc.dart' as _i149;
import '../../features/notifications/data/services/notification_service.dart'
    as _i860;
import '../../features/notifications/domain/managers/notification_manager.dart'
    as _i490;
import '../../features/notifications/domain/repositories/notification_repository.dart'
    as _i367;
import '../../features/reports/data/repositories/reports_repository_impl.dart'
    as _i227;
import '../../features/reports/data/services/gemini_reports_service.dart'
    as _i982;
import '../../features/reports/domain/repositories/reports_repository.dart'
    as _i808;
import '../../features/reports/presentation/bloc/reports_cubit.dart' as _i833;
import '../database/database_helper.dart' as _i64;
import '../services/gemini_key_service.dart' as _i171;
import '../services/home_widget_service.dart' as _i299;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i64.DatabaseHelper>(() => _i64.DatabaseHelper());
    gh.lazySingleton<_i171.GeminiKeyService>(() => _i171.GeminiKeyService());
    gh.lazySingleton<_i299.HomeWidgetService>(() => _i299.HomeWidgetService());
    gh.lazySingleton<_i95.BackupService>(() => _i95.BackupService());
    gh.lazySingleton<_i860.NotificationService>(
        () => _i860.NotificationService());
    gh.factory<_i549.GeminiMealService>(
        () => _i549.GeminiMealService(gh<_i171.GeminiKeyService>()));
    gh.factory<_i982.GeminiReportsService>(
        () => _i982.GeminiReportsService(gh<_i171.GeminiKeyService>()));
    gh.factory<_i70.DataManagementBloc>(() => _i70.DataManagementBloc(
          gh<InvalidType>(),
          gh<InvalidType>(),
          gh<InvalidType>(),
        ));
    gh.factory<_i996.BarcodeScannerBloc>(
        () => _i996.BarcodeScannerBloc(gh<InvalidType>()));
    gh.factory<_i214.FoodSearchBloc>(
        () => _i214.FoodSearchBloc(gh<InvalidType>()));
    gh.factory<_i27.RecipeBuilderBloc>(
        () => _i27.RecipeBuilderBloc(gh<InvalidType>()));
    gh.lazySingleton<_i81.FoodRemoteDataSource>(
        () => _i81.FoodRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i367.ExportService>(
        () => _i367.ExportService(gh<_i64.DatabaseHelper>()));
    gh.lazySingleton<_i113.ImportService>(
        () => _i113.ImportService(gh<_i64.DatabaseHelper>()));
    gh.lazySingleton<_i358.GamificationRepositoryImpl>(
        () => _i358.GamificationRepositoryImpl(gh<_i64.DatabaseHelper>()));
    gh.lazySingleton<_i227.ReportsRepositoryImpl>(
        () => _i227.ReportsRepositoryImpl(gh<_i64.DatabaseHelper>()));
    gh.lazySingleton<_i3.GamificationService>(() => _i3.GamificationService(
          gh<_i97.GamificationRepository>(),
          gh<_i299.HomeWidgetService>(),
        ));
    gh.lazySingleton<_i926.UserRepository>(
        () => _i687.UserRepositoryImpl(gh<_i64.DatabaseHelper>()));
    gh.lazySingleton<_i665.DashboardRepository>(
        () => _i509.DashboardRepositoryImpl(
              gh<_i64.DatabaseHelper>(),
              gh<_i926.UserRepository>(),
            ));
    gh.lazySingleton<_i367.NotificationRepository>(
        () => _i367.NotificationRepositoryImpl(gh<_i64.DatabaseHelper>()));
    gh.factory<_i638.GamificationBloc>(
        () => _i638.GamificationBloc(gh<_i97.GamificationRepository>()));
    gh.lazySingleton<_i1004.FoodLocalDataSource>(
        () => _i1004.FoodLocalDataSourceImpl(gh<_i64.DatabaseHelper>()));
    gh.factory<_i833.ReportsCubit>(() => _i833.ReportsCubit(
          gh<_i808.ReportsRepository>(),
          gh<_i982.GeminiReportsService>(),
        ));
    gh.factory<_i24.DashboardCubit>(() => _i24.DashboardCubit(
          gh<_i665.DashboardRepository>(),
          gh<_i299.HomeWidgetService>(),
        ));
    gh.lazySingleton<_i780.FoodRepository>(() => _i860.FoodRepositoryImpl(
          gh<_i1004.FoodLocalDataSource>(),
          gh<_i81.FoodRemoteDataSource>(),
        ));
    gh.lazySingleton<_i118.MealRepository>(() => _i115.MealRepositoryImpl(
          gh<_i64.DatabaseHelper>(),
          gh<_i549.GeminiMealService>(),
          gh<_i3.GamificationService>(),
        ));
    gh.lazySingleton<_i200.SaveUserProfile>(
        () => _i200.SaveUserProfile(gh<_i926.UserRepository>()));
    gh.lazySingleton<_i200.GetUserProfile>(
        () => _i200.GetUserProfile(gh<_i926.UserRepository>()));
    gh.lazySingleton<_i200.CheckOnboardingStatus>(
        () => _i200.CheckOnboardingStatus(gh<_i926.UserRepository>()));
    gh.lazySingleton<_i200.UpdateUserGoals>(
        () => _i200.UpdateUserGoals(gh<_i926.UserRepository>()));
    gh.factory<_i348.OnboardingCubit>(() => _i348.OnboardingCubit(
          gh<_i200.SaveUserProfile>(),
          gh<InvalidType>(),
        ));
    gh.lazySingleton<_i490.NotificationManager>(() => _i490.NotificationManager(
          gh<_i860.NotificationService>(),
          gh<_i367.NotificationRepository>(),
        ));
    gh.factory<_i421.ProfileCubit>(() => _i421.ProfileCubit(
          gh<_i200.GetUserProfile>(),
          gh<_i200.SaveUserProfile>(),
        ));
    gh.factory<_i149.MealLogBloc>(
        () => _i149.MealLogBloc(gh<_i118.MealRepository>()));
    return this;
  }
}

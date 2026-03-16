import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/dashboard_repository.dart';
import 'dashboard_state.dart';
import '../../../../core/services/home_widget_service.dart';

@injectable
class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repository;
  final HomeWidgetService _homeWidgetService;

  DashboardCubit(this._repository, this._homeWidgetService) : super(const DashboardState.initial());

  Future<void> loadDashboard({DateTime? date, bool isRefresh = false}) async {
    final targetDate = date ?? DateTime.now();
    
    if (isRefresh) {
      state.maybeWhen(
        loaded: (data, d, _) => emit(DashboardState.loaded(
          data: data,
          selectedDate: d,
          isRefreshing: true,
        )),
        orElse: () => emit(const DashboardState.loading()),
      );
    } else {
      emit(const DashboardState.loading());
    }

    final result = await _repository.getDashboardData('default_user', targetDate);

    result.fold(
      (failure) => emit(DashboardState.error(failure.message)),
      (data) {
        emit(DashboardState.loaded(
          data: data,
          selectedDate: targetDate,
          isRefreshing: false,
        ));
        
        // Update home widget
        _homeWidgetService.updateWidget(
          caloriesConsumed: data.nutritionSummary.consumedCalories,
          calorieTarget: data.nutritionSummary.targetCalories,
          streak: data.currentStreak,
        );
      },
    );
  }

  Future<void> addWater(int mlToAdd) async {
    state.maybeWhen(
      loaded: (data, date, _) async {
        try {
          await _repository.logWater('default_user', date, mlToAdd);
          loadDashboard(date: date); // Reload to reflect changes
        } catch (e) {
          emit(DashboardState.error(e.toString()));
        }
      },
      orElse: () {},
    );
  }

  void nextDay() {
    state.maybeWhen(
      loaded: (_, date, __) => loadDashboard(date: date.add(const Duration(days: 1))),
      orElse: () => loadDashboard(date: DateTime.now().add(const Duration(days: 1))),
    );
  }

  void previousDay() {
    state.maybeWhen(
      loaded: (_, date, __) => loadDashboard(date: date.subtract(const Duration(days: 1))),
      orElse: () => loadDashboard(date: DateTime.now().subtract(const Duration(days: 1))),
    );
  }
}

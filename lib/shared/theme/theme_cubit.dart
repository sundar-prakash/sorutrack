import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  void toggleTheme() {
    emit(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }

  void setTheme(ThemeMode mode) {
    emit(mode);
  }

  bool get isDarkMode => state == ThemeMode.dark;

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    final index = json['themeMode'] as int?;
    if (index == null) return ThemeMode.light;
    return ThemeMode.values[index];
  }

  @override
  Map<String, dynamic>? toJson(ThemeMode state) {
    return {'themeMode': state.index};
  }
}

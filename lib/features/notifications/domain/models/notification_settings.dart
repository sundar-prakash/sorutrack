import 'package:equatable/equatable.dart';

class NotificationSettings extends Equatable {
  final bool masterEnabled;
  final bool mealRemindersEnabled;
  final bool smartRemindersEnabled;
  final bool streakProtectionEnabled;
  final bool waterRemindersEnabled;
  final bool achievementsEnabled;
  final bool weeklySummaryEnabled;
  final bool goalRemindersEnabled;

  final String breakfastTime; // HH:mm
  final String lunchTime;    // HH:mm
  final String dinnerTime;   // HH:mm
  
  final int waterIntervalHours; // 1, 2, 3
  final String sleepStartTime;  // HH:mm
  final String sleepEndTime;    // HH:mm

  const NotificationSettings({
    this.masterEnabled = true,
    this.mealRemindersEnabled = true,
    this.smartRemindersEnabled = true,
    this.streakProtectionEnabled = true,
    this.waterRemindersEnabled = true,
    this.achievementsEnabled = true,
    this.weeklySummaryEnabled = true,
    this.goalRemindersEnabled = true,
    this.breakfastTime = '08:00',
    this.lunchTime = '13:00',
    this.dinnerTime = '19:30',
    this.waterIntervalHours = 2,
    this.sleepStartTime = '22:00',
    this.sleepEndTime = '08:30', // Changed from 07:00 to 08:30 to offset from breakfast
  });

  factory NotificationSettings.defaultSettings() => const NotificationSettings();

  Map<String, dynamic> toMap() {
    return {
      'masterEnabled': masterEnabled ? 1 : 0,
      'mealRemindersEnabled': mealRemindersEnabled ? 1 : 0,
      'smartRemindersEnabled': smartRemindersEnabled ? 1 : 0,
      'streakProtectionEnabled': streakProtectionEnabled ? 1 : 0,
      'waterRemindersEnabled': waterRemindersEnabled ? 1 : 0,
      'achievementsEnabled': achievementsEnabled ? 1 : 0,
      'weeklySummaryEnabled': weeklySummaryEnabled ? 1 : 0,
      'goalRemindersEnabled': goalRemindersEnabled ? 1 : 0,
      'breakfastTime': breakfastTime,
      'lunchTime': lunchTime,
      'dinnerTime': dinnerTime,
      'waterIntervalHours': waterIntervalHours,
      'sleepStartTime': sleepStartTime,
      'sleepEndTime': sleepEndTime,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      masterEnabled: map['masterEnabled'] == 1,
      mealRemindersEnabled: map['mealRemindersEnabled'] == 1,
      smartRemindersEnabled: map['smartRemindersEnabled'] == 1,
      streakProtectionEnabled: map['streakProtectionEnabled'] == 1,
      waterRemindersEnabled: map['waterRemindersEnabled'] == 1,
      achievementsEnabled: map['achievementsEnabled'] == 1,
      weeklySummaryEnabled: map['weeklySummaryEnabled'] == 1,
      goalRemindersEnabled: map['goalRemindersEnabled'] == 1,
      breakfastTime: map['breakfastTime'] as String? ?? '08:00',
      lunchTime: map['lunchTime'] as String? ?? '13:00',
      dinnerTime: map['dinnerTime'] as String? ?? '19:30',
      waterIntervalHours: map['waterIntervalHours'] as int? ?? 2,
      sleepStartTime: map['sleepStartTime'] as String? ?? '22:00',
      sleepEndTime: map['sleepEndTime'] as String? ?? '07:00',
    );
  }

  NotificationSettings copyWith({
    bool? masterEnabled,
    bool? mealRemindersEnabled,
    bool? smartRemindersEnabled,
    bool? streakProtectionEnabled,
    bool? waterRemindersEnabled,
    bool? achievementsEnabled,
    bool? weeklySummaryEnabled,
    bool? goalRemindersEnabled,
    String? breakfastTime,
    String? lunchTime,
    String? dinnerTime,
    int? waterIntervalHours,
    String? sleepStartTime,
    String? sleepEndTime,
  }) {
    return NotificationSettings(
      masterEnabled: masterEnabled ?? this.masterEnabled,
      mealRemindersEnabled: mealRemindersEnabled ?? this.mealRemindersEnabled,
      smartRemindersEnabled: smartRemindersEnabled ?? this.smartRemindersEnabled,
      streakProtectionEnabled: streakProtectionEnabled ?? this.streakProtectionEnabled,
      waterRemindersEnabled: waterRemindersEnabled ?? this.waterRemindersEnabled,
      achievementsEnabled: achievementsEnabled ?? this.achievementsEnabled,
      weeklySummaryEnabled: weeklySummaryEnabled ?? this.weeklySummaryEnabled,
      goalRemindersEnabled: goalRemindersEnabled ?? this.goalRemindersEnabled,
      breakfastTime: breakfastTime ?? this.breakfastTime,
      lunchTime: lunchTime ?? this.lunchTime,
      dinnerTime: dinnerTime ?? this.dinnerTime,
      waterIntervalHours: waterIntervalHours ?? this.waterIntervalHours,
      sleepStartTime: sleepStartTime ?? this.sleepStartTime,
      sleepEndTime: sleepEndTime ?? this.sleepEndTime,
    );
  }

  @override
  List<Object?> get props => [
        masterEnabled,
        mealRemindersEnabled,
        smartRemindersEnabled,
        streakProtectionEnabled,
        waterRemindersEnabled,
        achievementsEnabled,
        weeklySummaryEnabled,
        goalRemindersEnabled,
        breakfastTime,
        lunchTime,
        dinnerTime,
        waterIntervalHours,
        sleepStartTime,
        sleepEndTime,
      ];
}

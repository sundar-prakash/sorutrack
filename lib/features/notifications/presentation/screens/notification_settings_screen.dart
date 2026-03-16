import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import '../../domain/models/notification_settings.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/managers/notification_manager.dart';
import '../../data/services/notification_service.dart';
import '../../../../core/di/injection.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late NotificationSettings _settings;
  bool _isLoading = true;
  final String _userId = 'current_user'; // Should be dynamic

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repository = getIt<NotificationRepository>();
    final settings = await repository.getSettings(_userId);
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings(NotificationSettings newSettings) async {
    setState(() => _settings = newSettings);
    final repository = getIt<NotificationRepository>();
    final manager = getIt<NotificationManager>();

    await repository.saveSettings(_userId, newSettings);
    await manager.rescheduleAll(_userId);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications & Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () => _previewNotification(),
            tooltip: 'Preview Notification',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: _buildMasterToggle(theme),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: _buildSection(
                title: 'Meal Reminders',
                icon: Icons.restaurant,
                enabled: _settings.mealRemindersEnabled,
                onToggle: (val) => _saveSettings(
                    _settings.copyWith(mealRemindersEnabled: val)),
                children: [
                  _buildTimeTile('Breakfast', _settings.breakfastTime, (time) {
                    _saveSettings(_settings.copyWith(breakfastTime: time));
                  }),
                  _buildTimeTile('Lunch', _settings.lunchTime, (time) {
                    _saveSettings(_settings.copyWith(lunchTime: time));
                  }),
                  _buildTimeTile('Dinner', _settings.dinnerTime, (time) {
                    _saveSettings(_settings.copyWith(dinnerTime: time));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _buildSection(
                title: 'Water Reminders',
                icon: Icons.water_drop,
                enabled: _settings.waterRemindersEnabled,
                onToggle: (val) => _saveSettings(
                    _settings.copyWith(waterRemindersEnabled: val)),
                children: [
                  ListTile(
                    title: const Text('Reminder Interval'),
                    trailing: DropdownButton<int>(
                      value: _settings.waterIntervalHours,
                      items: [1, 2, 3]
                          .map((h) => DropdownMenuItem(
                              value: h,
                              child: Text('$h hour${h > 1 ? 's' : ''}')))
                          .toList(),
                      onChanged: (val) => val != null
                          ? _saveSettings(
                              _settings.copyWith(waterIntervalHours: val))
                          : null,
                    ),
                  ),
                  _buildTimeTile('Wake Up Time', _settings.sleepEndTime,
                      (time) {
                    _saveSettings(_settings.copyWith(sleepEndTime: time));
                  }),
                  _buildTimeTile('Sleep Time', _settings.sleepStartTime,
                      (time) {
                    _saveSettings(_settings.copyWith(sleepStartTime: time));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _buildSettingsToggle(
                'Smart Reminders',
                'Context-aware alerts for goals and missing logs',
                Icons.smart_toy_outlined,
                _settings.smartRemindersEnabled,
                (val) => _saveSettings(
                    _settings.copyWith(smartRemindersEnabled: val)),
              ),
            ),
            _buildSettingsToggle(
              'Streak Protection',
              'Don\'t let your streak break!',
              Icons.fireplace,
              _settings.streakProtectionEnabled,
              (val) => _saveSettings(
                  _settings.copyWith(streakProtectionEnabled: val)),
            ),
            _buildSettingsToggle(
              'Achievements',
              'Badge unlocks and level ups',
              Icons.emoji_events,
              _settings.achievementsEnabled,
              (val) =>
                  _saveSettings(_settings.copyWith(achievementsEnabled: val)),
            ),
            _buildSettingsToggle(
              'Weekly Summary',
              'A wrap-up of your progress every Sunday',
              Icons.assessment,
              _settings.weeklySummaryEnabled,
              (val) =>
                  _saveSettings(_settings.copyWith(weeklySummaryEnabled: val)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterToggle(ThemeData theme) {
    return Card(
      elevation: 0,
      color: _settings.masterEnabled
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      child: SwitchListTile(
        title: const Text('Master Notification Toggle',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Enable or disable all app notifications'),
        value: _settings.masterEnabled,
        onChanged: (val) =>
            _saveSettings(_settings.copyWith(masterEnabled: val)),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required bool enabled,
    required ValueChanged<bool> onToggle,
    required List<Widget> children,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SwitchListTile(
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            secondary: Icon(icon, color: enabled ? Colors.green : null),
            value: enabled,
            onChanged: onToggle,
          ),
          if (enabled) ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsToggle(String title, String subtitle, IconData icon,
      bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: value ? Colors.blue : null),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildTimeTile(
      String title, String time, ValueChanged<String> onTimeSelected) {
    return ListTile(
      title: Text(title),
      trailing: TextButton(
        onPressed: () async {
          final parts = time.split(':');
          final selectedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(
                hour: int.parse(parts[0]), minute: int.parse(parts[1])),
          );
          if (selectedTime != null && context.mounted) {
            final formattedTime =
                '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
            onTimeSelected(formattedTime);
          }
        },
        child: Text(time,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _previewNotification() async {
    final service = getIt<NotificationService>();
    final hasPermission = await service.requestPermissions();
    if (hasPermission) {
      await service.showNotification(
        id: 999,
        title: "SoruTrack Pro Preview! 🚀",
        body: "Checking if notifications are working beautifully.",
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification permissions are disabled.')),
        );
      }
    }
  }
}

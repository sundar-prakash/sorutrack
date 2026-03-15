import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for kDebugMode
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _useMetric = true;
  bool _mealReminders = true;
  bool _waterReminders = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSectionHeader('Profile & Goals'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit Profile'),
            subtitle: const Text('Personal details, gender, age'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Goal Settings'),
            subtitle: const Text('Weight goals, macro targets'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          
          const Divider(),
          _buildSectionHeader('Display & Units'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            subtitle: const Text('Follows system by default'),
            value: _isDarkMode,
            onChanged: (val) => setState(() => _isDarkMode = val),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.square_foot_outlined),
            title: const Text('Use Metric System'),
            subtitle: Text(_useMetric ? 'kg, cm, ml' : 'lbs, ft/in, oz'),
            value: _useMetric,
            onChanged: (val) => setState(() => _useMetric = val),
          ),

          const Divider(),
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.restaurant_outlined),
            title: const Text('Meal Reminders'),
            value: _mealReminders,
            onChanged: (val) => setState(() => _mealReminders = val),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.water_drop_outlined),
            title: const Text('Water Reminders'),
            value: _waterReminders,
            onChanged: (val) => setState(() => _waterReminders = val),
          ),

          const Divider(),
          _buildSectionHeader('Data Management'),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Backup Data'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.restore_outlined),
            title: const Text('Restore Data'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.import_export_outlined),
            title: const Text('Export CSV/PDF'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            title: Text('Clear All Data', style: TextStyle(color: theme.colorScheme.error)),
            onTap: () {},
          ),

          const Divider(),
          _buildSectionHeader('About SoruTrack'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            trailing: const Text('1.0.0 (1)'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: const Text('Licenses'),
            onTap: () => showLicensePage(context: context),
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Rate App'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Send Feedback'),
            onTap: () {},
          ),

          if (kDebugMode) ...[
            const Divider(),
            _buildSectionHeader('Developer Options'),
            ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: const Text('Reset Database'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.data_object_outlined),
              title: const Text('Fill Test Data'),
              onTap: () {},
            ),
          ],
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

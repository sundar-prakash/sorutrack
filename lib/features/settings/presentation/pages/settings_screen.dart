import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sorutrack_pro/shared/theme/theme_cubit.dart';
import 'package:sorutrack_pro/features/data_management/presentation/bloc/data_management_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _useMetric = true;
  bool _mealReminders = true;
  bool _waterReminders = false;
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _useMetric = prefs.getBool('useMetric') ?? true;
      _mealReminders = prefs.getBool('mealReminders') ?? true;
      _waterReminders = prefs.getBool('waterReminders') ?? false;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will delete all your meals, weight history, and settings. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              context.read<DataManagementBloc>().add(ClearAllDataRequested());
              Navigator.pop(context);
            },
            child: Text('CLEAR', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

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
            onTap: () => context.push('/edit-profile'),
          ),
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Goal Settings'),
            subtitle: const Text('Weight goals, macro targets'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/goal-settings'),
          ),
          
          const Divider(),
          _buildSectionHeader('Display & Units'),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle between light and dark themes'),
                value: themeMode == ThemeMode.dark,
                onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
              );
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.square_foot_outlined),
            title: const Text('Use Metric System'),
            subtitle: Text(_useMetric ? 'kg, cm, ml' : 'lbs, ft/in, oz'),
            value: _useMetric,
            onChanged: (val) {
              setState(() => _useMetric = val);
              _savePreference('useMetric', val);
            },
          ),

          const Divider(),
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.restaurant_outlined),
            title: const Text('Meal Reminders'),
            value: _mealReminders,
            onChanged: (val) {
              setState(() => _mealReminders = val);
              _savePreference('mealReminders', val);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.water_drop_outlined),
            title: const Text('Water Reminders'),
            value: _waterReminders,
            onChanged: (val) {
              setState(() => _waterReminders = val);
              _savePreference('waterReminders', val);
            },
          ),

          const Divider(),
          _buildSectionHeader('Data Management'),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Backup Data'),
            onTap: () => context.push('/data-management'),
          ),
          ListTile(
            leading: const Icon(Icons.restore_outlined),
            title: const Text('Restore Data'),
            onTap: () => context.push('/data-management'),
          ),
          ListTile(
            leading: const Icon(Icons.import_export_outlined),
            title: const Text('Export CSV/PDF'),
            onTap: () => context.push('/data-management'),
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            title: Text('Clear All Data', style: TextStyle(color: theme.colorScheme.error)),
            onTap: _showClearDataDialog,
          ),

          const Divider(),
          _buildSectionHeader('About SoruTrack'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            trailing: const Text('1.0.0 (1)'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'SoruTrack Pro',
                applicationVersion: '1.0.0',
                applicationIcon: const FlutterLogo(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: const Text('Licenses'),
            onTap: () => showLicensePage(context: context),
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Rate App'),
            onTap: () => _launchUrl('https://play.google.com/store/apps/details?id=com.sorutrack.pro'),
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Send Feedback'),
            onTap: () => _launchUrl('mailto:support@sorutrack.com?subject=SoruTrack Feedback'),
          ),

          if (kDebugMode) ...[
            const Divider(),
            _buildSectionHeader('Developer Options'),
            ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: const Text('Reset Database'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Database reset requested')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.data_object_outlined),
              title: const Text('Fill Test Data'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test data filled')),
                );
              },
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


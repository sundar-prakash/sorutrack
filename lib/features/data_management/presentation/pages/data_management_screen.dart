import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:animate_do/animate_do.dart';
import '../bloc/data_management_bloc.dart';
import '../../../../shared/widgets/app_card.dart'; // Assuming common widgets exist

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  final TextEditingController _passwordController = TextEditingController();

  void _showPasswordDialog(BuildContext context, {required Function(String) onConfirm}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Password'),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter password for encryption',
            helperText: 'Required to restore this backup later',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm(_passwordController.text);
              _passwordController.clear();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data & Portability'),
        elevation: 0,
      ),
      body: BlocConsumer<DataManagementBloc, DataManagementState>(
        listener: (context, state) {
          if (state is DataManagementSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is DataManagementFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state is DataManagementLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor)),
                  ),

                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  child: _buildSection(
                    title: 'Auto Backup',
                    subtitle: 'Keep your data safe automatically',
                    children: [
                      SwitchListTile(
                        title: const Text('Daily Auto-Backup'),
                        subtitle: const Text('Backs up to local storage every midnight'),
                        value: true,
                        onChanged: (val) {},
                        secondary: const Icon(Icons.auto_history),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: _buildSection(
                    title: 'Backups',
                    subtitle: 'Create and restore full app database',
                    children: [
                      _buildActionTile(
                        icon: Icons.backup,
                        title: 'Create Full Backup',
                        subtitle: 'Raw SQLite binary file',
                        onTap: () => context.read<DataManagementBloc>().add(CreateBackupRequested()),
                      ),
                      _buildActionTile(
                        icon: Icons.security,
                        title: 'Create Secure Backup',
                        subtitle: 'Encrypted .SoruTackbackup file',
                        onTap: () => _showPasswordDialog(context, onConfirm: (pw) {
                          context.read<DataManagementBloc>().add(CreateBackupRequested(password: pw));
                        }),
                      ),
                      _buildActionTile(
                        icon: Icons.restore,
                        title: 'Restore from File',
                        subtitle: 'Restore database from .db or .SoruTackbackup',
                        onTap: () async {
                          final result = await FilePicker.platform.pickFiles();
                          if (result != null) {
                            final file = File(result.files.single.path!);
                            if (file.path.endsWith('.SoruTackbackup')) {
                               // Request password
                            } else {
                               context.read<DataManagementBloc>().add(RestoreBackupRequested(file));
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: _buildSection(
                    title: 'Export History',
                    subtitle: 'Download your data in various formats',
                    children: [
                      _buildExportRow(context, 'CSV', Icons.table_chart, 'csv'),
                      _buildExportRow(context, 'Excel', Icons.explicit, 'excel'),
                      _buildExportRow(context, 'PDF Report', Icons.picture_as_pdf, 'pdf'),
                      _buildExportRow(context, 'JSON', Icons.code, 'json'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                FadeInUp(
                  duration: const Duration(milliseconds: 700),
                  child: _buildSection(
                    title: 'Import Logs',
                    subtitle: 'Bring your data from other apps',
                    children: [
                      _buildActionTile(
                        icon: Icons.upload_file,
                        title: 'HealthifyMe Import',
                        subtitle: 'Import from HealthifyMe CSV export',
                        onTap: () => _pickAndImport(context, 'healthifyme'),
                      ),
                      _buildActionTile(
                        icon: Icons.fitness_center,
                        title: 'MyFitnessPal Import',
                        subtitle: 'Import from MyFitnessPal CSV',
                        onTap: () => _pickAndImport(context, 'mfp'),
                      ),
                      _buildActionTile(
                        icon: Icons.settings_applications,
                        title: 'Generic CSV Import',
                        subtitle: 'Map your own CSV columns',
                        onTap: () => _pickAndImport(context, 'generic'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({required String title, required String subtitle, required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildExportRow(BuildContext context, String label, IconData icon, String format) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(label),
      trailing: ElevatedButton(
        onPressed: () => context.read<DataManagementBloc>().add(ExportDataRequested('user_123', format)),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.grey[100],
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Export'),
      ),
    );
  }

  Future<void> _pickAndImport(BuildContext context, String type) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (result != null) {
      final file = File(result.files.single.path!);
      context.read<DataManagementBloc>().add(ImportDataRequested('user_123', file, type));
    }
  }
}

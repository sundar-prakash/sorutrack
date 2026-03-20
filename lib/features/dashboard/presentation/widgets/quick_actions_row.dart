import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildAction(context, Icons.qr_code_scanner, 'Scan', () => context.push('/barcode-scanner')),
        _buildAction(context, Icons.mic, 'Voice', () => context.push('/quick-add')),
        _buildAction(context, Icons.add_circle_outline, 'Quick Add', () => context.push('/food-search')),
        _buildAction(context, Icons.directions_run, 'Exercise', () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exercise tracking coming soon!')),
          );
        }),
      ],
    );
  }

  Widget _buildAction(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

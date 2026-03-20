import 'package:flutter/material.dart';


class ImportPreviewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> previewData;
  final String importType;

  const ImportPreviewScreen(
      {super.key, required this.previewData, required this.importType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Import'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.amber.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.amber),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Found ${previewData.length} logs in your $importType export. Please review before proceeding.',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: previewData.length > 10 ? 10 : previewData.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = previewData[index];
                return ListTile(
                  title: Text(item['food_name'] ?? 'Unknown Item'),
                  subtitle: Text('${item['date']} • ${item['meal_type']}'),
                  trailing: Text('${item['calories']} kcal',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
          if (previewData.length > 10)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('+ ${previewData.length - 10} more items...',
                  style: TextStyle(
                      color: Colors.grey[600], fontStyle: FontStyle.italic)),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5))
              ],
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Conflict Resolution:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ChoiceChip(label: Text('Skip Duplicates'), selected: true),
                    ChoiceChip(label: Text('Overwrite'), selected: false),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Perform import
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Proceed with Import',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

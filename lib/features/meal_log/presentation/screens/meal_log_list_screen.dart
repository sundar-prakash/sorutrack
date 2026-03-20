import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';


class MealLogListScreen extends StatelessWidget {
  const MealLogListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Log'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3, // Placeholder for today's meals
        itemBuilder: (context, index) {
          return FadeInLeft(
            delay: Duration(milliseconds: index * 100),
            child: _buildMealTypeGroup(context, index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/quick-add');
        },
        label: const Text('Add Meal'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMealTypeGroup(BuildContext context, int index) {
    final types = ['Breakfast', 'Lunch', 'Dinner'];
    final type = types[index % types.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            type,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: const Text('Idly Sambar', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('4 pieces idly, 1 bowl sambar'),
            trailing: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('385 cal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                Text('08:30 AM', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            onTap: () {
                // Show details
            },
          ),
        ),
      ],
    );
  }
}

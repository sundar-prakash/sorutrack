import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:animate_do/animate_do.dart';
import '../bloc/meal_log_bloc.dart';
import '../bloc/meal_log_event.dart';
import '../bloc/meal_log_state.dart';
import 'parsed_results_screen.dart';

class QuickAddScreen extends StatefulWidget {
  const QuickAddScreen({super.key});

  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  final _inputController = TextEditingController();
  String _selectedMealType = 'Breakfast';
  DateTime _selectedTime = DateTime.now();

  final List<String> _mealTypes = [
    'Breakfast',
    'Morning Snack',
    'Lunch',
    'Afternoon Snack',
    'Dinner',
    'Late Night',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _onAnalyze() {
    if (_inputController.text.trim().isEmpty) return;
    context.read<MealLogBloc>().add(
          MealLogEvent.parseMeal(
            _inputController.text.trim(),
            _selectedMealType,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MealLogBloc, MealLogState>(
      listener: (context, state) {
        state.maybeWhen(
          reviewing: (meal) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ParsedResultsScreen(meal: meal)),
            );
          },
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Quick Add Meal'),
            centerTitle: true,
          ),
          body: state.maybeWhen(
            analyzing: () => _buildAnalyzingState(),
            orElse: () => _buildInputState(),
          ),
        );
      },
    );
  }

  Widget _buildAnalyzingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
            'https://assets9.lottiefiles.com/packages/lf20_m6cu9rqa.json', // Healthy food animation
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 24),
          FadeInUp(
            child: const Text(
              'Analyzing your meal...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Identifying foods and calculating nutrition'),
        ],
      ),
    );
  }

  Widget _buildInputState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What did you eat?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inputController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'e.g., "I ate 4 idly and sambar this morning"',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              suffixIcon: IconButton(
                icon: const Icon(Icons.mic),
                onPressed: () {
                    // Speech to text placeholder
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Meal Type', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _mealTypes.map((type) {
              final isSelected = _selectedMealType == type;
              return ChoiceChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedMealType = type);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Time', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedTime),
                  );
                  if (time != null) {
                    setState(() {
                      _selectedTime = DateTime(
                        _selectedTime.year,
                        _selectedTime.month,
                        _selectedTime.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                },
                icon: const Icon(Icons.access_time),
                label: Text(TimeOfDay.fromDateTime(_selectedTime).format(context)),
              ),
            ],
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _onAnalyze,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: const Text('ANALYZE MEAL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:animate_do/animate_do.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../bloc/meal_log_bloc.dart';
import '../bloc/meal_log_event.dart';
import '../bloc/meal_log_state.dart';
import 'parsed_results_screen.dart';

class QuickAddScreen extends StatefulWidget {
  final String? initialMealType;
  const QuickAddScreen({super.key, this.initialMealType});

  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  final _inputController = TextEditingController();
  late String _selectedMealType;
  DateTime _selectedTime = DateTime.now();
  
  // Speech to text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.initialMealType ?? 'Breakfast';
  }

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

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
           if (val == 'done' || val == 'notListening') {
             setState(() => _isListening = false);
           }
        },
        onError: (val) => debugPrint('STT Error: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _inputController.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MealLogBloc, MealLogState>(
      listener: (context, state) {
        state.maybeWhen(
          reviewing: (meal) {
            final bloc = context.read<MealLogBloc>();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: bloc,
                  child: ParsedResultsScreen(meal: meal),
                ),
              ),
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
          Lottie.asset(
            'assets/loading-animation.json',
            width: 200,
            height: 200,
            repeat: true,
            frameRate: FrameRate.max,
            errorBuilder: (context, error, stackTrace) {
              return SizedBox(
                width: 200,
                height: 200,
                child: Center(
                  child: ZoomIn(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              );
            },
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
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? Colors.red : null,
                ),
                onPressed: _listen,
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

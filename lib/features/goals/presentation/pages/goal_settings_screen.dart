import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sorutrack_pro/features/auth/domain/models/auth_enums.dart';
import 'package:sorutrack_pro/features/auth/presentation/cubit/profile_cubit.dart';

class GoalSettingsScreen extends StatefulWidget {
  const GoalSettingsScreen({super.key});

  @override
  State<GoalSettingsScreen> createState() => _GoalSettingsScreenState();
}

class _GoalSettingsScreenState extends State<GoalSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _targetWeightController;
  late TextEditingController _weeklyGoalController;
  
  GoalType _goalType = GoalType.maintain;
  WeightUnit _weightUnit = WeightUnit.kg;
  
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final state = context.read<ProfileCubit>().state;
      state.maybeWhen(
        loaded: (profile, _, __, ___, ____, _____, ______) {
          _targetWeightController = TextEditingController(text: profile.targetWeight.toString());
          _weeklyGoalController = TextEditingController(text: profile.weeklyGoal.toString());
          _goalType = profile.goal;
          _weightUnit = profile.weightUnit;
        },
        orElse: () {
          _targetWeightController = TextEditingController();
          _weeklyGoalController = TextEditingController();
        },
      );
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    _weeklyGoalController.dispose();
    super.dispose();
  }

  void _saveGoals() {
    if (_formKey.currentState?.validate() ?? false) {
      final state = context.read<ProfileCubit>().state;
      state.maybeWhen(
        loaded: (profile, _, __, ___, ____, _____, ______) {
          final target = double.parse(_targetWeightController.text.trim());
          final current = profile.weight;
          
          if (_goalType == GoalType.loseWeight && target >= current) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Target weight must be less than current weight to lose weight.')),
            );
            return;
          }
          if (_goalType == GoalType.gainMuscle && target <= current) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Target weight must be greater than current weight to gain muscle.')),
            );
            return;
          }
          
          final updatedProfile = profile.copyWith(
            goal: _goalType,
            targetWeight: target,
            weeklyGoal: double.parse(_weeklyGoalController.text.trim()),
          );
          
          context.read<ProfileCubit>().updateProfile(updatedProfile);
          context.pop();
        },
        orElse: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not load profile to update.')),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveGoals,
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => Center(child: Text(message)),
            loaded: (profile, bmr, tdee, target, macros, bmi, bmiStatus) {
              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'What is your primary goal?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<GoalType>(
                      initialValue: _goalType,
                      decoration: const InputDecoration(labelText: 'Primary Goal'),
                      items: GoalType.values.map((gt) {
                        return DropdownMenuItem(
                          value: gt,
                          child: Text(_formatEnumName(gt.name)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _goalType = val);
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Targets',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _targetWeightController,
                      decoration: InputDecoration(
                        labelText: 'Target Weight',
                        suffixText: _weightUnit.name,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final weight = double.tryParse(value);
                        if (weight == null || weight <= 0) return 'Invalid target weight';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _weeklyGoalController,
                      decoration: InputDecoration(
                        labelText: 'Weekly Change Rate',
                        suffixText: '${_weightUnit.name} / week',
                        helperText: 'Recommended max safe rate is 0.5-1.0 kg/week',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final rate = double.tryParse(value);
                        if (rate == null || rate < 0) return 'Invalid rate';
                        if (rate > 2.0 && _goalType != GoalType.maintain) {
                          return 'Rate too high! Max recommended is 1.0';
                        }
                        if (_goalType == GoalType.maintain && rate != 0) {
                          return 'Maintenance goal should have 0 weekly change';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: _saveGoals,
                      child: const Text('SAVE GOALS'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatEnumName(String name) {
    return name
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .trimLeft()
        .replaceFirstMapped(RegExp(r'^[a-z]'), (match) => match.group(0)!.toUpperCase());
  }
}

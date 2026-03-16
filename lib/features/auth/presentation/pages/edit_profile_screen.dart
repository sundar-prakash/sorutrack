import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sorutrack_pro/features/auth/domain/models/auth_enums.dart';
import 'package:sorutrack_pro/features/auth/presentation/cubit/profile_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  
  Gender _gender = Gender.male;
  HeightUnit _heightUnit = HeightUnit.cm;
  WeightUnit _weightUnit = WeightUnit.kg;
  ActivityLevel _activityLevel = ActivityLevel.sedentary;
  DietaryPreference _dietaryPreference = DietaryPreference.nonVeg;
  
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final state = context.read<ProfileCubit>().state;
      state.maybeWhen(
        loaded: (profile, _, __, ___, ____, _____, ______) {
          _nameController = TextEditingController(text: profile.name);
          _ageController = TextEditingController(text: profile.age.toString());
          _heightController = TextEditingController(text: profile.height.toString());
          _weightController = TextEditingController(text: profile.weight.toString());
          _gender = profile.gender;
          _heightUnit = profile.heightUnit;
          _weightUnit = profile.weightUnit;
          _activityLevel = profile.activityLevel;
          _dietaryPreference = profile.dietaryPreference;
        },
        orElse: () {
          _nameController = TextEditingController();
          _ageController = TextEditingController();
          _heightController = TextEditingController();
          _weightController = TextEditingController();
        },
      );
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      final state = context.read<ProfileCubit>().state;
      state.maybeWhen(
        loaded: (profile, _, __, ___, ____, _____, ______) {
          final updatedProfile = profile.copyWith(
            name: _nameController.text.trim(),
            age: int.parse(_ageController.text.trim()),
            height: double.parse(_heightController.text.trim()),
            weight: double.parse(_weightController.text.trim()),
            gender: _gender,
            heightUnit: _heightUnit,
            weightUnit: _weightUnit,
            activityLevel: _activityLevel,
            dietaryPreference: _dietaryPreference,
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
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveProfile,
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
                    _buildSectionHeader('Personal Details'),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            decoration: const InputDecoration(labelText: 'Age'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              final age = int.tryParse(value);
                              if (age == null || age < 13 || age > 120) {
                                return 'Invalid age (13-120)';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<Gender>(
                            initialValue: _gender,
                            decoration: const InputDecoration(labelText: 'Gender'),
                            items: Gender.values.map((g) {
                              return DropdownMenuItem(
                                value: g,
                                child: Text(g.name.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _gender = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    _buildSectionHeader('Body Metrics'),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _heightController,
                            decoration: const InputDecoration(labelText: 'Height'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              final height = double.tryParse(value);
                              if (height == null || height <= 0) return 'Invalid height';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<HeightUnit>(
                            initialValue: _heightUnit,
                            decoration: const InputDecoration(labelText: 'Unit'),
                            items: HeightUnit.values.map((u) {
                              return DropdownMenuItem(
                                value: u,
                                child: Text(u.name.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _heightUnit = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _weightController,
                            decoration: const InputDecoration(labelText: 'Weight'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              final weight = double.tryParse(value);
                              if (weight == null || weight <= 0) return 'Invalid weight';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<WeightUnit>(
                            initialValue: _weightUnit,
                            decoration: const InputDecoration(labelText: 'Unit'),
                            items: WeightUnit.values.map((u) {
                              return DropdownMenuItem(
                                value: u,
                                child: Text(u.name.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _weightUnit = val);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    _buildSectionHeader('Lifestyle'),
                    DropdownButtonFormField<ActivityLevel>(
                      initialValue: _activityLevel,
                      decoration: const InputDecoration(labelText: 'Activity Level'),
                      items: ActivityLevel.values.map((lvl) {
                        return DropdownMenuItem(
                          value: lvl,
                          child: Text(_formatEnumName(lvl.name)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _activityLevel = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<DietaryPreference>(
                      initialValue: _dietaryPreference,
                      decoration: const InputDecoration(labelText: 'Dietary Preference'),
                      items: DietaryPreference.values.map((pref) {
                        return DropdownMenuItem(
                          value: pref,
                          child: Text(_formatEnumName(pref.name)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _dietaryPreference = val);
                      },
                    ),
                    
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('SAVE CHANGES'),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  String _formatEnumName(String name) {
    return name
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .trim();
  }
}

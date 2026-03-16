import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../domain/models/auth_enums.dart';

class OnboardingStep6 extends StatelessWidget {
  final DietaryPreference dietaryPreference;
  final List<String> selectedAllergies;
  final Function(DietaryPreference) onPrefChanged;
  final Function(List<String>) onAllergiesChanged;

  const OnboardingStep6({
    super.key,
    required this.dietaryPreference,
    required this.selectedAllergies,
    required this.onPrefChanged,
    required this.onAllergiesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInRight(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dietary Preferences',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "Tell us about your eating habits.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              DropdownButtonFormField<DietaryPreference>(
                initialValue: dietaryPreference,
                onChanged: (val) => onPrefChanged(val!),
                decoration: const InputDecoration(
                  labelText: 'Diet Type',
                  border: OutlineInputBorder(),
                ),
                items: DietaryPreference.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name.toUpperCase()),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 32),
              const Text('Allergies / Restrictions', 
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['Peanuts', 'Dairy', 'Gluten', 'Soy', 'Shellfish', 'Eggs'].map((allergy) {
                  final isSelected = selectedAllergies.contains(allergy);
                  return FilterChip(
                    label: Text(allergy),
                    selected: isSelected,
                    onSelected: (selected) {
                      final newList = List<String>.from(selectedAllergies);
                      if (selected) {
                        newList.add(allergy);
                      } else {
                        newList.remove(allergy);
                      }
                      onAllergiesChanged(newList);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

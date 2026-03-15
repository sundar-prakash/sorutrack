import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../domain/models/auth_enums.dart';

class OnboardingStep1 extends StatelessWidget {
  final String name;
  final int age;
  final Gender gender;
  final Function(String) onNameChanged;
  final Function(int) onAgeChanged;
  final Function(Gender) onGenderChanged;

  const OnboardingStep1({
    super.key,
    required this.name,
    required this.age,
    required this.gender,
    required this.onNameChanged,
    required this.onAgeChanged,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInRight(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to SoruTrack!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Let's get to know you better.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            TextField(
              onChanged: onNameChanged,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (val) => onAgeChanged(int.tryParse(val) ?? age),
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      prefixIcon: Icon(Icons.cake),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: DropdownButtonFormField<Gender>(
                    value: gender,
                    onChanged: (val) => onGenderChanged(val!),
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    items: Gender.values
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.name.toUpperCase()),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

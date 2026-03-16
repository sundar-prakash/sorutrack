import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../domain/models/auth_enums.dart';

class OnboardingStep1 extends StatelessWidget {
  final String name;
  final DateTime? dateOfBirth;
  final Gender gender;
  final String? error;
  final Function(String) onNameChanged;
  final Function(DateTime) onDateOfBirthChanged;
  final Function(Gender) onGenderChanged;

  const OnboardingStep1({
    super.key,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    this.error,
    required this.onNameChanged,
    required this.onDateOfBirthChanged,
    required this.onGenderChanged,
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
                'Welcome to SoruTrack!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
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
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                  errorText: error?.contains('name') == true ? error : null,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dateOfBirth ?? DateTime(2000, 1, 1),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) onDateOfBirthChanged(picked);
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          prefixIcon: const Icon(Icons.cake),
                          border: const OutlineInputBorder(),
                          errorText: error?.toLowerCase().contains('birth') == true ? error : null,
                        ),
                        child: Text(
                          dateOfBirth == null
                              ? 'Select Date'
                              : "${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: DropdownButtonFormField<Gender>(
                      initialValue: gender,
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
      ),
    );
  }
}

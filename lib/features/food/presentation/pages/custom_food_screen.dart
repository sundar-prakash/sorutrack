import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/unit_helper.dart';
import '../../../../features/auth/presentation/cubit/profile_cubit.dart';
import '../../../../features/auth/domain/models/auth_enums.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/repositories/food_repository.dart';

class CustomFoodScreen extends StatefulWidget {
  final String? initialBarcode;
  const CustomFoodScreen({super.key, this.initialBarcode});

  @override
  State<CustomFoodScreen> createState() => _CustomFoodScreenState();
}

class _CustomFoodScreenState extends State<CustomFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _brand = '';
  double _calories = 0;
  double _protein = 0;
  double _carbs = 0;
  double _fat = 0;
  double _servingSize = 100;
  String _servingUnit = 'g';
  String _category = 'Home Recipe';

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Calorie Validation: caloriesroughly = 4*protein + 4*carbs + 9*fat (warn if >20% off)
      final calculatedCals = (_protein * 4) + (_carbs * 4) + (_fat * 9);
      final difference = (_calories - calculatedCals).abs();
      final percentOff = calculatedCals > 0 ? (difference / calculatedCals) : 0;

      if (percentOff > 0.2) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Calorie Discrepancy'),
            content: Text(
              'The calories entered ($_calories) vary by ${ (percentOff * 100).toInt()}% from the calculated macros (${calculatedCals.toInt()}). Do you want to proceed anyway?'
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
            ],
          ),
        );
        if (!context.mounted) return;
        if (proceed != true) return;
      }

      final food = FoodItem(
        id: widget.initialBarcode ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _name,
        brand: _brand.isNotEmpty ? _brand : null,
        calories: _calories,
        protein: _protein,
        carbs: _carbs,
        fat: _fat,
        servingSize: _servingSize,
        servingUnit: _servingUnit,
        category: _category,
        isCustom: true,
      );

      final scaffold = context;
      final repo = scaffold.read<FoodRepository>();
      final result = await repo.saveCustomFood(food);
      if (!scaffold.mounted) return;
      result.fold(
        (failure) => ScaffoldMessenger.of(scaffold).showSnackBar(SnackBar(content: Text(failure.message))),
        (_) {
          ScaffoldMessenger.of(scaffold).showSnackBar(const SnackBar(content: Text('Food saved successfully!')));
          Navigator.of(scaffold).pop();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Custom Food')),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          final useMetric = profileState.maybeWhen(
            loaded: (p, _, __, ___, ____, _____, ______) => p.weightUnit == WeightUnit.kg,
            orElse: () => true,
          );
          final unitHelper = UnitHelper(useMetric: useMetric);

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Food Name*', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    onSaved: (v) => _name = v!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Brand (Optional)', border: OutlineInputBorder()),
                    onSaved: (v) => _brand = v ?? '',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                              labelText: 'Serving Size*', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          initialValue: '100',
                          onSaved: (v) =>
                              _servingSize = double.tryParse(v ?? '100') ?? 100,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _servingUnit,
                          decoration: const InputDecoration(
                              labelText: 'Unit', border: OutlineInputBorder()),
                          items: ['g', 'ml', 'piece', 'serving', 'cup']
                              .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                              .toList(),
                          onChanged: (v) => setState(() => _servingUnit = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Nutritional Info (per serving)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Calories (${unitHelper.energyUnit})*',
                        border: const OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    onSaved: (v) => _calories = double.tryParse(v ?? '0') ?? 0,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildMacroField('Protein (${unitHelper.weightUnit})*',
                              (v) => _protein = double.tryParse(v!) ?? 0)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildMacroField('Carbs (${unitHelper.weightUnit})*',
                              (v) => _carbs = double.tryParse(v!) ?? 0)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildMacroField('Fat (${unitHelper.weightUnit})*',
                              (v) => _fat = double.tryParse(v!) ?? 0)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(
                        labelText: 'Tag As', border: OutlineInputBorder()),
                    items: ['Home Recipe', 'Restaurant', 'Packaged']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save Food',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMacroField(String label, FormFieldSetter<String> onSaved) {
    return TextFormField(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      keyboardType: TextInputType.number,
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      onSaved: onSaved,
    );
  }
}

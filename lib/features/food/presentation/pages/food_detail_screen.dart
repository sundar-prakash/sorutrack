import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/auth/presentation/cubit/profile_cubit.dart';
import '../../../../features/auth/domain/models/auth_enums.dart';
import '../../../../core/utils/unit_helper.dart';
import '../../domain/entities/food_item.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem foodItem;
  const FoodDetailScreen({super.key, required this.foodItem});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  late double _quantity;
  late String _selectedUnit;

  @override
  void initState() {
    super.initState();
    _quantity = widget.foodItem.servingSize;
    _selectedUnit = widget.foodItem.servingUnit;
  }

  double _calculate(double baseValue) {
    return (baseValue * _quantity) / widget.foodItem.servingSize;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.foodItem.name),
        actions: [
          IconButton(
            icon: Icon(widget.foodItem.isFavorite
                ? Icons.favorite
                : Icons.favorite_border),
            color: widget.foodItem.isFavorite ? Colors.red : null,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          final useMetric = profileState.maybeWhen(
            loaded: (p, _, _, _, _, _, _) => p.weightUnit == WeightUnit.kg,
            orElse: () => true,
          );
          final unitHelper = UnitHelper(useMetric: useMetric);

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(theme, unitHelper),
                _buildServingAdjuster(theme),
                _buildMacroBreakdown(theme, unitHelper),
                _buildMicroBreakdown(theme, unitHelper),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _showMealSelector(context),
            child: const Text('Add to Meal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, UnitHelper unitHelper) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.1),
      ),
      child: Column(
        children: [
          Text(
            widget.foodItem.name,
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (widget.foodItem.brand != null)
            Text(widget.foodItem.brand!, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          Text(
            '${_calculate(widget.foodItem.calories).toInt()} ${unitHelper.energyUnit}',
            style: theme.textTheme.displaySmall?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServingAdjuster(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _quantity.toString()),
              onChanged: (value) {
                setState(() {
                  _quantity = double.tryParse(value) ?? 0;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedUnit,
              decoration: const InputDecoration(
                labelText: 'Unit',
                border: OutlineInputBorder(),
              ),
              items: {widget.foodItem.servingUnit, 'g', 'cup', 'piece'}
                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedUnit = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBreakdown(ThemeData theme, UnitHelper unitHelper) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _MacroItem(
              label: 'Protein',
              value: _calculate(widget.foodItem.protein),
              unit: unitHelper.weightUnit,
              color: Colors.blue),
          _MacroItem(
              label: 'Carbs',
              value: _calculate(widget.foodItem.carbs),
              unit: unitHelper.weightUnit,
              color: Colors.green),
          _MacroItem(
              label: 'Fat',
              value: _calculate(widget.foodItem.fat),
              unit: unitHelper.weightUnit,
              color: Colors.orange),
        ],
      ),
    );
  }

  Widget _buildMicroBreakdown(ThemeData theme, UnitHelper unitHelper) {
    final micros = {
      'Fiber': '${_calculate(widget.foodItem.fiber).toStringAsFixed(1)}${unitHelper.weightUnit}',
      'Sugar': '${_calculate(widget.foodItem.sugar).toStringAsFixed(1)}${unitHelper.weightUnit}',
      'Sodium': '${_calculate(widget.foodItem.sodium).toStringAsFixed(0)}mg',
      'Iron': '${_calculate(widget.foodItem.iron).toStringAsFixed(1)}mg',
      'Calcium': '${_calculate(widget.foodItem.calcium).toStringAsFixed(0)}mg',
    };

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Micronutrients',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...micros.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key),
                    Text(e.value,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showMealSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Select Meal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...['Breakfast', 'Lunch', 'Dinner', 'Snacks'].map((meal) => ListTile(
                title: Text(meal),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added to $meal')),
                  );
                },
              )),
        ],
      ),
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;

  const _MacroItem(
      {required this.label, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text('${value.toStringAsFixed(1)}$unit',
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: LinearProgressIndicator(
            value: 0.5, // Simplified
            backgroundColor: color.withValues(alpha: 0.2),
            color: color,
          ),
        ),
      ],
    );
  }
}

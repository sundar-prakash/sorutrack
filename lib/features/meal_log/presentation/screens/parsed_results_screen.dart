import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import '../bloc/meal_log_bloc.dart';
import '../bloc/meal_log_event.dart';
import '../bloc/meal_log_state.dart';
import '../../domain/models/parsed_meal.dart';
import '../../../../features/dashboard/presentation/widgets/streak_card_widget.dart';
import '../../../../core/services/home_widget_service.dart';
import '../../../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../../../core/di/injection.dart';
import '../../../../features/dashboard/presentation/cubit/dashboard_state.dart';
import '../../../../features/auth/presentation/cubit/profile_cubit.dart';
import '../../../../features/auth/domain/models/auth_enums.dart';
import '../../../../core/utils/unit_helper.dart';

class ParsedResultsScreen extends StatefulWidget {
  final ParsedMeal meal;

  const ParsedResultsScreen({super.key, required this.meal});

  @override
  State<ParsedResultsScreen> createState() => _ParsedResultsScreenState();
}

class _ParsedResultsScreenState extends State<ParsedResultsScreen> {
  late List<ParsedMealItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List<ParsedMealItem>.from(widget.meal.items);
  }

  // ─── Derived totals ───────────────────────────────────────
  double get _totalCalories => _items.fold(0, (s, i) => s + i.calories);
  double get _totalProtein => _items.fold(0, (s, i) => s + i.proteinG);
  double get _totalCarbs => _items.fold(0, (s, i) => s + i.carbsG);
  double get _totalFat => _items.fold(0, (s, i) => s + i.fatG);

  /// Returns a new item with quantity changed, scaling all macros proportionally.
  ParsedMealItem _scaleItem(ParsedMealItem item, double newQty) {
    if (newQty <= 0) return item;
    final ratio = newQty / item.quantity;
    return ParsedMealItem(
      name: item.name,
      quantity: newQty,
      unit: item.unit,
      weightG: item.weightG * ratio,
      calories: item.calories * ratio,
      proteinG: item.proteinG * ratio,
      carbsG: item.carbsG * ratio,
      fatG: item.fatG * ratio,
      fiberG: item.fiberG * ratio,
      sodiumMg: item.sodiumMg * ratio,
      sugarG: item.sugarG * ratio,
      glycemicIndex: item.glycemicIndex,
      servingDescription: item.servingDescription,
      notes: item.notes,
    );
  }

  void _incrementQuantity(int index) {
    setState(() {
      final item = _items[index];
      _items[index] = _scaleItem(item, item.quantity + 1);
    });
  }

  void _decrementQuantity(int index) {
    final item = _items[index];
    if (item.quantity <= 1) return;
    setState(() {
      _items[index] = _scaleItem(item, item.quantity - 1);
    });
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  // ─── Edit Inline Bottom Sheet ─────────────────────────────
  void _showEditSheet(int index) {
    final item = _items[index];

    final nameCtrl = TextEditingController(text: item.name);
    final qtyCtrl =
        TextEditingController(text: item.quantity.toStringAsFixed(0));
    final unitCtrl = TextEditingController(text: item.unit);
    final calCtrl =
        TextEditingController(text: item.calories.toStringAsFixed(1));
    final protCtrl =
        TextEditingController(text: item.proteinG.toStringAsFixed(1));
    final carbCtrl =
        TextEditingController(text: item.carbsG.toStringAsFixed(1));
    final fatCtrl = TextEditingController(text: item.fatG.toStringAsFixed(1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            final useMetric = profileState.maybeWhen(
              loaded: (p, _, __, ___, ____, _____, ______) => p.weightUnit == WeightUnit.kg,
              orElse: () => true,
            );
            final unitHelper = UnitHelper(useMetric: useMetric);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Edit Food Item',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _EditField(controller: nameCtrl, label: 'Food Name'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: _EditField(
                                  controller: qtyCtrl,
                                  label: 'Quantity',
                                  numeric: true)),
                          const SizedBox(width: 12),
                          Expanded(
                              child:
                                  _EditField(controller: unitCtrl, label: 'Unit')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Nutrition (per entry)',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                              child: _EditField(
                                  controller: calCtrl,
                                  label: 'Calories (${unitHelper.energyUnit})',
                                  decimal: true)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _EditField(
                                  controller: protCtrl,
                                  label: 'Protein (${unitHelper.weightUnit})',
                                  decimal: true)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: _EditField(
                                  controller: carbCtrl,
                                  label: 'Carbs (${unitHelper.weightUnit})',
                                  decimal: true)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _EditField(
                                  controller: fatCtrl,
                                  label: 'Fat (${unitHelper.weightUnit})',
                                  decimal: true)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final newQty =
                                    double.tryParse(qtyCtrl.text) ?? item.quantity;
                                final updated = ParsedMealItem(
                                  name: nameCtrl.text.trim().isEmpty
                                      ? item.name
                                      : nameCtrl.text.trim(),
                                  quantity: newQty,
                                  unit: unitCtrl.text.trim().isEmpty
                                      ? item.unit
                                      : unitCtrl.text.trim(),
                                  weightG: item.weightG,
                                  calories:
                                      double.tryParse(calCtrl.text) ?? item.calories,
                                  proteinG:
                                      double.tryParse(protCtrl.text) ?? item.proteinG,
                                  carbsG:
                                      double.tryParse(carbCtrl.text) ?? item.carbsG,
                                  fatG: double.tryParse(fatCtrl.text) ?? item.fatG,
                                  fiberG: item.fiberG,
                                  sodiumMg: item.sodiumMg,
                                  sugarG: item.sugarG,
                                  glycemicIndex: item.glycemicIndex,
                                  servingDescription: item.servingDescription,
                                  notes: item.notes,
                                );
                                setState(() => _items[index] = updated);
                                Navigator.pop(ctx);
                              },
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── Add Custom Item Dialog ───────────────────────────────
  void _showAddCustomItemDialog(UnitHelper unitHelper) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final unitCtrl = TextEditingController(text: 'serving');
    final calCtrl = TextEditingController();
    final protCtrl = TextEditingController(text: '0');
    final carbCtrl = TextEditingController(text: '0');
    final fatCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Custom Item'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _EditField(controller: nameCtrl, label: 'Food Name *'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: _EditField(
                            controller: qtyCtrl,
                            label: 'Qty',
                            numeric: true)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _EditField(controller: unitCtrl, label: 'Unit')),
                  ],
                ),
                const SizedBox(height: 10),
                _EditField(
                    controller: calCtrl,
                    label: 'Calories (${unitHelper.energyUnit}) *',
                    decimal: true),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: _EditField(
                            controller: protCtrl,
                            label: 'Protein (${unitHelper.weightUnit})',
                            decimal: true)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _EditField(
                            controller: carbCtrl,
                            label: 'Carbs (${unitHelper.weightUnit})',
                            decimal: true)),
                  ],
                ),
                const SizedBox(height: 10),
                _EditField(
                    controller: fatCtrl, label: 'Fat (${unitHelper.weightUnit})', decimal: true),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final cal = double.tryParse(calCtrl.text);
                if (name.isEmpty || cal == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Please fill in name and calories fields.')),
                  );
                  return;
                }
                final qty = double.tryParse(qtyCtrl.text) ?? 1.0;
                final newItem = ParsedMealItem(
                  name: name,
                  quantity: qty,
                  unit: unitCtrl.text.trim().isEmpty
                      ? 'serving'
                      : unitCtrl.text.trim(),
                  weightG: 0,
                  calories: cal,
                  proteinG: double.tryParse(protCtrl.text) ?? 0,
                  carbsG: double.tryParse(carbCtrl.text) ?? 0,
                  fatG: double.tryParse(fatCtrl.text) ?? 0,
                  servingDescription:
                      '${qty.toStringAsFixed(0)} ${unitCtrl.text.trim().isEmpty ? 'serving' : unitCtrl.text.trim()}',
                );
                setState(() => _items.add(newItem));
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // ─── Save ─────────────────────────────────────────────────
  void _onSave() {
    final updatedMeal = ParsedMeal(
      mealId: widget.meal.mealId,
      mealName: widget.meal.mealName,
      mealTime: widget.meal.mealTime,
      mealType: widget.meal.mealType,
      confidenceScore: widget.meal.confidenceScore,
      totalCalories: _totalCalories,
      totalProteinG: _totalProtein,
      totalCarbsG: _totalCarbs,
      totalFatG: _totalFat,
      totalFiberG: _items.fold(0, (s, i) => s + i.fiberG),
      items: _items,
      warnings: widget.meal.warnings,
      alternativesSuggested: widget.meal.alternativesSuggested,
    );
    context.read<MealLogBloc>().add(MealLogEvent.saveMeal(updatedMeal));
  }

  // ─── Build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocListener<MealLogBloc, MealLogState>(
      listener: (context, state) {
        state.maybeWhen(
          success: () async {
            // Update streak
            await StreakCardWidget.recordActivity();
            
            // Get dashboard data to update widget
            if (context.mounted) {
              final dashboardCubit = context.read<DashboardCubit>();
              dashboardCubit.loadDashboard(isRefresh: true);
              
              final dashboardState = dashboardCubit.state;
              dashboardState.maybeWhen(
                loaded: (data, selectedDate, isRefreshing) {
                  getIt<HomeWidgetService>().updateWidget(
                    streak: data.currentStreak,
                    remainingCalories: data.nutritionSummary.remainingCalories.toStringAsFixed(0),
                  );
                },
                orElse: () {
                  getIt<HomeWidgetService>().updateWidget(
                    streak: 1, 
                  );
                },
              );
            }

            if (context.mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Meal logged successfully!')),
              );
            }
          },
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },
          orElse: () {},
        );
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          final useMetric = profileState.maybeWhen(
            loaded: (p, _, __, ___, ____, _____, ______) => p.weightUnit == WeightUnit.kg,
            orElse: () => true,
          );
          final unitHelper = UnitHelper(useMetric: useMetric);

          return Scaffold(
            appBar: AppBar(
              title: const Text('Review Meal'),
              actions: [
                if (widget.meal.confidenceScore < 0.8)
                  const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      FadeInDown(
                        child: Text(
                          widget.meal.mealName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Confidence: ${(widget.meal.confidenceScore * 100).toInt()}%',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 24),
                      ..._items.asMap().entries.map((entry) {
                        return FadeInLeft(
                          delay: Duration(milliseconds: entry.key * 80),
                          child: _buildFoodItemCard(entry.value, entry.key, unitHelper),
                        );
                      }),
                      const SizedBox(height: 8),
                      // ── Add Custom Item button ──
                      TextButton.icon(
                        onPressed: () => _showAddCustomItemDialog(unitHelper),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Add custom item'),
                      ),
                      if (widget.meal.warnings.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text('Warnings',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.red)),
                        ...widget.meal.warnings.map((w) =>
                            Text('• $w', style: const TextStyle(color: Colors.red))),
                      ],
                      if (widget.meal.alternativesSuggested.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text('Suggestions',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.blue)),
                        ...widget.meal.alternativesSuggested.map((s) => Text('• $s',
                            style: const TextStyle(color: Colors.blue))),
                      ],
                    ],
                  ),
                ),
                _buildSummaryBar(unitHelper),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoodItemCard(ParsedMealItem item, int index, UnitHelper unitHelper) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header row
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: const Text('🥗'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(item.servingDescription,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                Text('${item.calories.toInt()} ${unitHelper.energyUnit}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green)),
                // Remove item
                IconButton(
                  icon: Icon(Icons.close,
                      size: 18, color: Colors.grey.shade400),
                  onPressed: () => _removeItem(index),
                  tooltip: 'Remove item',
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Macro pills
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroPill(
                    'P', unitHelper.formatMacro(item.proteinG), Colors.blue),
                _buildMacroPill(
                    'C', unitHelper.formatMacro(item.carbsG), Colors.orange),
                _buildMacroPill(
                    'F', unitHelper.formatMacro(item.fatG), Colors.red),
              ],
            ),
            const Divider(height: 28),
            // Quantity row + Edit inline
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity stepper
                Row(
                  children: [
                    _StepperButton(
                      icon: Icons.remove_circle_outline,
                      onPressed: item.quantity > 1
                          ? () => _decrementQuantity(index)
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity.toStringAsFixed(1)} ${item.unit}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    _StepperButton(
                      icon: Icons.add_circle_outline,
                      onPressed: () => _incrementQuantity(index),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _showEditSheet(index),
                  child: const Text('Edit inline'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text('$label: $value',
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildSummaryBar(UnitHelper unitHelper) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                  'Calories', '${_totalCalories.toInt()}', unitHelper.energyUnit),
              _buildSummaryItem('Protein', '${_totalProtein.toInt()}', unitHelper.weightUnit),
              _buildSummaryItem('Carbs', '${_totalCarbs.toInt()}', unitHelper.weightUnit),
              _buildSummaryItem('Fat', '${_totalFat.toInt()}', unitHelper.weightUnit),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: BlocBuilder<MealLogBloc, MealLogState>(
              builder: (context, state) {
                final isSaving = state.maybeWhen(
                  saving: () => true,
                  orElse: () => false,
                );
                return ElevatedButton(
                  onPressed: _items.isEmpty || isSaving ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('SAVE TO LOG',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Looks wrong? Re-parse meal',
                style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(width: 2),
            Text(unit,
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}

// ─── Helper Widgets ────────────────────────────────────────────────────────────

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool numeric;
  final bool decimal;

  const _EditField({
    required this.controller,
    required this.label,
    this.numeric = false,
    this.decimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : numeric
              ? TextInputType.number
              : TextInputType.text,
      inputFormatters: decimal
          ? [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))]
          : numeric
              ? [FilteringTextInputFormatter.digitsOnly]
              : [],
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _StepperButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon,
          color: onPressed != null
              ? Theme.of(context).primaryColor
              : Colors.grey.shade400),
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/recipe_builder/recipe_builder_bloc.dart';
import 'food_search_screen.dart';

class RecipeBuilderScreen extends StatefulWidget {
  const RecipeBuilderScreen({super.key});

  @override
  State<RecipeBuilderScreen> createState() => _RecipeBuilderScreenState();
}

class _RecipeBuilderScreenState extends State<RecipeBuilderScreen> {
  final _nameController = TextEditingController();
  final _yieldController = TextEditingController(text: '1');
  String _yieldUnit = 'serving';

  @override
  void dispose() {
    _nameController.dispose();
    _yieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecipeBuilderBloc, RecipeBuilderState>(
      listener: (context, state) {
        if (state.success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recipe saved!')));
          Navigator.pop(context);
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Recipe Builder')),
          body: Column(
            children: [
              _buildRecipeHeader(context),
              const Divider(),
              Expanded(child: _buildIngredientsList(context, state)),
              _buildNutritionSummary(state),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: state.isSaving ? null : () => _showSaveDialog(context, state),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: state.isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Recipe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecipeHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Recipe Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _yieldController,
                  decoration: const InputDecoration(labelText: 'Total Yield', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    final amount = double.tryParse(v) ?? 1;
                    context.read<RecipeBuilderBloc>().add(UpdateRecipeYield(yieldAmount: amount, yieldUnit: _yieldUnit));
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _yieldUnit,
                  decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
                  items: ['serving', 'grams', 'bowl', 'portion']
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      _yieldUnit = v;
                      final amount = double.tryParse(_yieldController.text) ?? 1;
                      context.read<RecipeBuilderBloc>().add(UpdateRecipeYield(yieldAmount: amount, yieldUnit: v));
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList(BuildContext context, RecipeBuilderState state) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add'),
                onPressed: () => _openIngredientSearch(context),
              ),
            ],
          ),
        ),
        if (state.ingredients.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No ingredients added yet.', style: TextStyle(color: Colors.grey)),
            ),
          ),
        ...state.ingredients.map((ingredient) => ListTile(
              title: Text(ingredient.foodItem.name),
              subtitle: Text('${ingredient.quantity}${ingredient.unit} • ${ingredient.calories.toInt()} kcal'),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => context.read<RecipeBuilderBloc>().add(RemoveIngredient(ingredient.id)),
              ),
            )),
      ],
    );
  }

  Widget _buildNutritionSummary(RecipeBuilderState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        border: const Border(top: BorderSide(color: Colors.divider)),
      ),
      child: Column(
        children: [
          const Text('Nutrition per serving', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(label: 'Calories', value: '${state.caloriesPerServing.toInt()} kcal'),
              _SummaryItem(label: 'Protein', value: '${state.proteinPerServing.toStringAsFixed(1)}g'),
              _SummaryItem(label: 'Carbs', value: '${state.carbsPerServing.toStringAsFixed(1)}g'),
              _SummaryItem(label: 'Fat', value: '${state.fatPerServing.toStringAsFixed(1)}g'),
            ],
          ),
        ],
      ),
    );
  }

  void _openIngredientSearch(BuildContext context) {
    // In a real implementation, we'd navigate to FoodSearchScreen and return the selection
    // For now, let's show a simple mocked selection flow
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FoodSearchScreen(mealType: 'Recipe Ingredient'),
      ),
    );
  }

  void _showSaveDialog(BuildContext context, RecipeBuilderState state) {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a recipe name')));
      return;
    }
    context.read<RecipeBuilderBloc>().add(SaveRecipe(name: _nameController.text));
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/food_search/food_search_bloc.dart';
import '../bloc/barcode_scanner/barcode_scanner_bloc.dart';
import 'barcode_scanner_screen.dart';
import 'food_detail_screen.dart';
import 'recipe_builder_screen.dart';
import 'custom_food_screen.dart';

class FoodSearchScreen extends StatefulWidget {
  final String? mealType;
  const FoodSearchScreen({super.key, this.mealType});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<FoodSearchBloc>().add(LoadRecentFoods());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mealType != null ? 'Add to ${widget.mealType}' : 'Food Database'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for foods...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<FoodSearchBloc>().add(const SearchQueryChanged(''));
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                context.read<FoodSearchBloc>().add(SearchQueryChanged(value));
              },
            ),
          ),
          _buildFilters(),
          const Divider(),
          Expanded(
            child: BlocBuilder<FoodSearchBloc, FoodSearchState>(
              builder: (context, state) {
                if (state is FoodSearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is FoodSearchLoaded) {
                  if (state.results.isEmpty && _searchController.text.isNotEmpty) {
                    return _buildNoResults();
                  }
                  
                  if (_searchController.text.isEmpty) {
                    return _buildRecentAndFrequent(state);
                  }

                  return _buildResultsList(state.results);
                } else if (state is FoodSearchError) {
                  return Center(child: Text(state.message));
                }
                return const Center(child: Text('Start typing to search'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateOptions(context),
        label: const Text('Create'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FilterChip(label: 'Indian', onSelected: (_) {}),
          const SizedBox(width: 8),
          _FilterChip(label: 'Western', onSelected: (_) {}),
          const SizedBox(width: 8),
          _FilterChip(label: 'High Protein', onSelected: (_) {}),
          const SizedBox(width: 8),
          _FilterChip(label: 'Veg', onSelected: (_) {}),
        ],
      ),
    );
  }

  Widget _buildRecentAndFrequent(FoodSearchLoaded state) {
    return ListView(
      children: [
        if (state.recentFoods.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Recent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          ...state.recentFoods.map((food) => _FoodTile(food: food)),
        ],
        if (state.frequentFoods.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Frequent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          ...state.frequentFoods.map((food) => _FoodTile(food: food)),
        ],
      ],
    );
  }

  Widget _buildResultsList(List<dynamic> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final food = results[index];
        return _FoodTile(food: food);
      },
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No foods found.'),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomFoodScreen()),
            ),
            child: const Text('Create Custom Food'),
          ),
        ],
      ),
    );
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.restaurant),
            title: const Text('New Custom Food'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomFoodScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.blender),
            title: const Text('New Recipe'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeBuilderScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final Function(bool) onSelected;
  const _FilterChip({required this.label, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      onSelected: onSelected,
      labelStyle: const TextStyle(fontSize: 12),
      padding: EdgeInsets.zero,
    );
  }
}

class _FoodTile extends StatelessWidget {
  final dynamic food;
  const _FoodTile({required this.food});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(food.name),
      subtitle: Text('${food.brand ?? ""} • ${food.calories.toInt()} kcal per ${food.servingSize}${food.servingUnit}'),
      trailing: const Icon(Icons.add_circle_outline),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FoodDetailScreen(foodItem: food)),
      ),
    );
  }
}

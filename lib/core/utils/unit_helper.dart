
class UnitHelper {
  final bool useMetric;

  UnitHelper({required this.useMetric});

  String get weightUnit => useMetric ? 'g' : 'oz';
  String get weightLargeUnit => useMetric ? 'kg' : 'lbs';
  String get weightUnitLabel => useMetric ? 'kg' : 'lbs';
  String get energyUnit => 'kcal';
  String get volumeUnit => useMetric ? 'ml' : 'fl oz';

  /// Formats a macro value with its unit.
  /// Protein, Carbs, Fat are typically measured in grams even in imperial systems,
  /// but food weight can be in ounces.
  String formatMacro(double grams) {
    return '${grams.toStringAsFixed(1)}g';
  }

  /// Formats food weight based on unit system.
  String formatFoodWeight(double grams) {
    if (useMetric) {
      return '${grams.toStringAsFixed(1)}g';
    } else {
      final oz = grams * 0.035274;
      return '${oz.toStringAsFixed(1)}oz';
    }
  }

  /// Formats energy (calories).
  String formatEnergy(double kcal) {
    return '${kcal.toInt()} $energyUnit';
  }

  /// Formats body weight.
  String formatBodyWeight(double kg) {
    if (useMetric) {
      return '${kg.toStringAsFixed(1)} kg';
    } else {
      final lbs = kg * 2.20462;
      return '${lbs.toStringAsFixed(1)} lbs';
    }
  }
}

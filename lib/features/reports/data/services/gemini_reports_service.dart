import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/gemini_key_service.dart';
import '../../domain/models/report_models.dart';

@injectable
class GeminiReportsService {
  final GeminiKeyService _keyService;

  GeminiReportsService(this._keyService);

  Future<String> generateWeeklyInsights({
    required List<ReportTrendData> calories,
    required List<MacroDistribution> macros,
    required List<TopFood> topFoods,
    required MicronutrientData micros,
  }) async {
    final apiKey = await _keyService.getKey();
    if (apiKey == null) return "No API key found. Please add it in settings.";

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    final prompt = """
    Act as a professional nutritionist. Analyze this user nutrition data for the last 7-30 days and provide:
    1. A brief narrative of their weekly performance.
    2. Pattern detection (e.g., high calorie days, timing consistency).
    3. Actionable recommendations (e.g., "Increase protein by 15g").
    4. Nutrient gap summary.

    DATA:
    - Calories Trend: ${calories.map((e) => "${e.date}: ${e.value}kcal").join(", ")}
    - Top Foods: ${topFoods.map((e) => "${e.name} (${e.frequency} times)").join(", ")}
    - Macro Avg: Protein: ${macros.map((e) => e.protein).reduce((a, b) => a + b) / macros.length}g, 
                Carbs: ${macros.map((e) => e.carbs).reduce((a, b) => a + b) / macros.length}g, 
                Fat: ${macros.map((e) => e.fat).reduce((a, b) => a + b) / macros.length}g
    - Micronutrients: Fiber: ${micros.fiber}g, Sodium: ${micros.sodium}mg, Potassium: ${micros.potassium}mg

    Format the response as beautiful markdown with emojis. Be encouraging but scientific.
    """;

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      return response.text ?? "Failed to generate insights.";
    } catch (e) {
      return "Error generating insights: $e";
    }
  }
}

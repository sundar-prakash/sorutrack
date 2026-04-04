import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';
import 'package:sorutrack_pro/core/services/gemini_key_service.dart';
import 'package:sorutrack_pro/features/reports/domain/models/report_models.dart';
import 'package:sorutrack_pro/core/services/gemini_client.dart';

@injectable
class GeminiReportsService {
  final GeminiKeyService _keyService;
  final GeminiClient _geminiClient;

  GeminiReportsService(this._keyService, this._geminiClient);

  Future<String> generateWeeklyInsights({
    required List<ReportTrendData> calories,
    required List<MacroDistribution> macros,
    required List<TopFood> topFoods,
    required MicronutrientData micros,
  }) async {
    final apiKey = await _keyService.getKey();
    if (apiKey == null) return "No API key found. Please add it in settings.";

    final proteinAvg = macros.isEmpty ? 0 : macros.map((e) => e.protein).reduce((a, b) => a + b) / macros.length;
    final carbsAvg = macros.isEmpty ? 0 : macros.map((e) => e.carbs).reduce((a, b) => a + b) / macros.length;
    final fatAvg = macros.isEmpty ? 0 : macros.map((e) => e.fat).reduce((a, b) => a + b) / macros.length;

    final prompt = """
    Act as a professional nutritionist. Analyze this user nutrition data for the last 7-30 days and provide:
    1. A brief narrative of their weekly performance.
    2. Pattern detection (e.g., high calorie days, timing consistency).
    3. Actionable recommendations (e.g., "Increase protein by 15g").
    4. Nutrient gap summary.

    DATA:
    - Calories Trend: ${calories.isEmpty ? "No data" : calories.map((e) => "${e.date}: ${e.value}kcal").join(", ")}
    - Top Foods: ${topFoods.isEmpty ? "No data" : topFoods.map((e) => "${e.name} (${e.frequency} times)").join(", ")}
    - Macro Avg: Protein: ${proteinAvg.toStringAsFixed(1)}g, 
                Carbs: ${carbsAvg.toStringAsFixed(1)}g, 
                Fat: ${fatAvg.toStringAsFixed(1)}g
    - Micronutrients: Fiber: ${micros.fiber}g, Sodium: ${micros.sodium}mg, Potassium: ${micros.potassium}mg

    Format the response as beautiful markdown with emojis. Be encouraging but scientific.
    """;

    try {
      final responseText = await _geminiClient.generateContent(
        apiKey: apiKey,
        modelName: 'gemini-2.0-flash',
        content: [Content.text(prompt)],
      );
      return responseText ?? "Failed to generate insights.";
    } catch (e) {
      return "Error generating insights: $e";
    }
  }
}

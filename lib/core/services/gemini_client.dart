import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';

abstract class GeminiClient {
  Future<String?> generateContent({
    required String apiKey,
    required String modelName,
    required Iterable<Content> content,
    GenerationConfig? generationConfig,
    List<SafetySetting>? safetySettings,
    List<Tool>? tools,
    ToolConfig? toolConfig,
  });
}

@LazySingleton(as: GeminiClient)
class GeminiClientImpl implements GeminiClient {
  @override
  Future<String?> generateContent({
    required String apiKey,
    required String modelName,
    required Iterable<Content> content,
    GenerationConfig? generationConfig,
    List<SafetySetting>? safetySettings,
    List<Tool>? tools,
    ToolConfig? toolConfig,
  }) async {
    final model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      generationConfig: generationConfig,
      safetySettings: safetySettings ?? const [],
      tools: tools,
      toolConfig: toolConfig,
    );
    final response = await model.generateContent(content);
    return response.text;
  }
}

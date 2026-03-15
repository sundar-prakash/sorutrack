import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

enum ApiKeyValidationResult { valid, invalid, rateLimited, networkError }

class InvalidApiKeyException implements Exception {
  final String message;
  InvalidApiKeyException(this.message);
}

@lazySingleton
class GeminiKeyService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  static const _keyName = 'gemini_api_key';

  Future<void> saveKey(String apiKey) async {
    // Validate format first
    if (!apiKey.startsWith('AIza') || apiKey.length < 30) {
      throw InvalidApiKeyException('Invalid Gemini API key format');
    }
    await _storage.write(key: _keyName, value: apiKey);
  }

  Future<String?> getKey() async {
    return await _storage.read(key: _keyName);
  }

  Future<bool> hasKey() async {
    final key = await getKey();
    return key != null && key.isNotEmpty;
  }

  Future<void> deleteKey() async {
    await _storage.delete(key: _keyName);
  }

  Future<ApiKeyValidationResult> validateKey(String apiKey) async {
    try {
      // Make a minimal test call to Gemini
      final response = await Dio().post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
        data: {
          "contents": [
            {
              "parts": [
                {"text": "Reply with just the word: valid"}
              ]
            }
          ],
          "generationConfig": {"maxOutputTokens": 10}
        },
        options: Options(
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      if (response.statusCode == 200) return ApiKeyValidationResult.valid;
      return ApiKeyValidationResult.invalid;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) return ApiKeyValidationResult.invalid;
      if (e.response?.statusCode == 429) return ApiKeyValidationResult.rateLimited;
      return ApiKeyValidationResult.networkError;
    } catch (_) {
      return ApiKeyValidationResult.networkError;
    }
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sorutrack_pro/core/services/gemini_key_service.dart';

import 'gemini_key_service_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage, Dio])
void main() {
  late MockFlutterSecureStorage mockStorage;
  late MockDio mockDio;
  late GeminiKeyService service;

  const keyName = 'gemini_api_key';
  const validKey = 'AIzaSyA_TestKey_12345678901234567890';

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    mockDio = MockDio();
    service = GeminiKeyService(mockStorage, mockDio);
  });

  group('GeminiKeyService', () {
    test('saveKey writes to storage if format is valid', () async {
      await service.saveKey(validKey);
      verify(mockStorage.write(key: keyName, value: validKey)).called(1);
    });

    test('saveKey throws InvalidApiKeyException if format is invalid', () async {
      expect(() => service.saveKey('short'), throwsA(isA<InvalidApiKeyException>()));
      expect(() => service.saveKey('invalid_prefix'), throwsA(isA<InvalidApiKeyException>()));
    });

    test('getKey reads from storage', () async {
      when(mockStorage.read(key: keyName)).thenAnswer((_) async => validKey);
      final result = await service.getKey();
      expect(result, validKey);
    });

    test('hasKey returns true if key exists', () async {
      when(mockStorage.read(key: keyName)).thenAnswer((_) async => validKey);
      final result = await service.hasKey();
      expect(result, isTrue);
    });

    test('hasKey returns false if key is missing', () async {
      when(mockStorage.read(key: keyName)).thenAnswer((_) async => null);
      final result = await service.hasKey();
      expect(result, isFalse);
    });

    test('deleteKey deletes from storage', () async {
      await service.deleteKey();
      verify(mockStorage.delete(key: keyName)).called(1);
    });

    test('validateKey returns valid for 200 response', () async {
      when(mockDio.post(any, data: anyNamed('data'), options: anyNamed('options')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 200,
                data: {'status': 'ok'},
              ));

      final result = await service.validateKey(validKey);
      expect(result, ApiKeyValidationResult.valid);
    });

    test('validateKey returns invalid for 401 response', () async {
      when(mockDio.post(any, data: anyNamed('data'), options: anyNamed('options')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(requestOptions: RequestOptions(path: ''), statusCode: 401),
      ));

      final result = await service.validateKey(validKey);
      expect(result, ApiKeyValidationResult.invalid);
    });

    test('validateKey returns rateLimited for 429 response', () async {
      when(mockDio.post(any, data: anyNamed('data'), options: anyNamed('options')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(requestOptions: RequestOptions(path: ''), statusCode: 429),
      ));

      final result = await service.validateKey(validKey);
      expect(result, ApiKeyValidationResult.rateLimited);
    });

    test('validateKey returns networkError for other errors', () async {
      when(mockDio.post(any, data: anyNamed('data'), options: anyNamed('options')))
          .thenThrow(Exception('Network fail'));

      final result = await service.validateKey(validKey);
      expect(result, ApiKeyValidationResult.networkError);
    });
  });
}

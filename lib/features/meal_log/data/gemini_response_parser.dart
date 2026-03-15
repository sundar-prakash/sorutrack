import 'dart:convert';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/models/parsed_meal.dart';

class GeminiResponseParser {
  static Either<Failure, ParsedMeal> parse(String response) {
    try {
      if (response.isEmpty) {
        return Left(ServerFailure('Empty response'));
      }
      
      final jsonData = jsonDecode(response);
      
      // Basic validation for required fields if needed, 
      // but ParsedMeal.fromJson might already handle it.
      if (jsonData['items'] == null) {
        return Left(ServerFailure('Missing items in response'));
      }
      
      return Right(ParsedMeal.fromJson(jsonData));
    } on FormatException catch (_) {
      return Left(ServerFailure('Malformed JSON'));
    } catch (e) {
      return Left(ServerFailure('Parse Error: ${e.toString()}'));
    }
  }
}

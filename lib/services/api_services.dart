import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class ApiService {
  static Future<List<Question>> fetchQuestions({
    required int amount,
    required String category,
    required String difficulty,
    required String type,
  }) async {
    final response = await http.get(
      Uri.parse(
        'https://opentdb.com/api.php?amount=$amount&category=$category&difficulty=$difficulty&type=$type',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Question> questions = (data['results'] as List)
          .map((questionData) => Question.fromJson(questionData))
          .toList();
      return questions;
    } else {
      throw Exception('Failed to load questions');
    }
  }
}

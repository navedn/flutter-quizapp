import 'dart:convert';
import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import 'package:http/http.dart' as http;

class QuizSetupScreen extends StatefulWidget {
  @override
  _QuizSetupScreenState createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  final List<int> _questionCounts = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
  int _selectedQuestionCount = 10;
  String? _selectedCategory; // Nullable to handle initialization
  String _selectedDifficulty = 'easy';
  String _selectedType = 'multiple';

  List<Map<String, String>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final response =
        await http.get(Uri.parse('https://opentdb.com/api_category.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _categories = (data['trivia_categories'] as List<dynamic>)
            .map((category) => {
                  'id': category['id'].toString(),
                  'name': category['name'] as String,
                })
            .toList();
        // Set _selectedCategory to the first category ID
        if (_categories.isNotEmpty) {
          _selectedCategory = _categories.first['id'];
        }
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  void _startQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          questionCount: _selectedQuestionCount,
          category: _selectedCategory!,
          difficulty: _selectedDifficulty,
          type: _selectedType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Select Number of Questions'),
            DropdownButton<int>(
              value: _selectedQuestionCount,
              onChanged: (value) =>
                  setState(() => _selectedQuestionCount = value!),
              items: _questionCounts.map((count) {
                return DropdownMenuItem(
                  value: count,
                  child: Text('$count Questions'),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text('Select Category'),
            if (_categories.isEmpty) Text('Loading categories...'),
            if (_categories.isNotEmpty)
              DropdownButton<String>(
                value: _selectedCategory,
                onChanged: (value) =>
                    setState(() => _selectedCategory = value!),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category['id'],
                    child: Text(category['name'] ?? ''),
                  );
                }).toList(),
              ),
            SizedBox(height: 16),
            Text('Select Difficulty'),
            DropdownButton<String>(
              value: _selectedDifficulty,
              onChanged: (value) =>
                  setState(() => _selectedDifficulty = value!),
              items: ['easy', 'medium', 'hard'].map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level.toUpperCase()),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text('Select Question Type'),
            DropdownButton<String>(
              value: _selectedType,
              onChanged: (value) => setState(() => _selectedType = value!),
              items: ['multiple', 'boolean'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                      type == 'multiple' ? 'Multiple Choice' : 'True/False'),
                );
              }).toList(),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _categories.isNotEmpty ? _startQuiz : null,
              child: Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}

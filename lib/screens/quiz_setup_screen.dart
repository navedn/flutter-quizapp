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
  String _selectedCategory = 'Mythology'; // Nullable to handle initialization
  String _selectedDifficulty = 'easy';
  String _selectedType = 'multiple';

  List<Map<String, String>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
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
          if (_categories.isNotEmpty) {
            _selectedCategory = _categories.first['id']!;
          } else {
            _selectedCategory = ''; // Handle empty categories gracefully
          }
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        _categories = [];
        _selectedCategory = ''; // Clear selection on error
      });
    }
  }

  void _startQuiz() {
    Navigator.pushReplacement(
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
      appBar: AppBar(
        title: Text(
          'Quiz Setup',
          style: TextStyle(
            fontSize: 20,
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Colors.cyanAccent,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 10,
        shadowColor: Colors.cyanAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.blue.shade900],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitle('Select Number of Questions'),
              _buildDropdown<int>(
                value: _selectedQuestionCount,
                items: _questionCounts,
                display: (count) => '$count Questions',
                onChanged: (value) =>
                    setState(() => _selectedQuestionCount = value!),
              ),
              SizedBox(height: 16),
              _buildTitle('Select Category'),
              if (_categories.isEmpty)
                Center(child: CircularProgressIndicator(color: Colors.cyan))
              else
                _buildDropdown<String>(
                  value: _selectedCategory,
                  items: _categories.map((cat) => cat['id']!).toList(),
                  display: (id) =>
                      _categories.firstWhere((cat) => cat['id'] == id)['name']!,
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value!),
                ),
              SizedBox(height: 16),
              _buildTitle('Select Difficulty'),
              _buildDropdown<String>(
                value: _selectedDifficulty,
                items: ['easy', 'medium', 'hard'],
                display: (difficulty) => difficulty.toUpperCase(),
                onChanged: (value) =>
                    setState(() => _selectedDifficulty = value!),
              ),
              SizedBox(height: 16),
              _buildTitle('Select Question Type'),
              _buildDropdown<String>(
                value: _selectedType,
                items: ['multiple', 'boolean'],
                display: (type) =>
                    type == 'multiple' ? 'Multiple Choice' : 'True/False',
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: _categories.isNotEmpty ? _startQuiz : null,
                child: Text('Start Quiz'),
                style: _tronButtonStyle(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        color: Colors.cyanAccent,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            blurRadius: 10,
            color: Colors.cyanAccent,
            offset: Offset(0, 0),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) display,
    required void Function(T?) onChanged,
  }) {
    return DropdownButton<T>(
      value: value,
      dropdownColor: Colors.black,
      onChanged: onChanged,
      style: TextStyle(color: Colors.cyanAccent),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            display(item),
            style: TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  ButtonStyle _tronButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.cyanAccent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.cyanAccent, width: 2),
      ),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      elevation: 8,
      shadowColor: Colors.cyanAccent,
    );
  }
}

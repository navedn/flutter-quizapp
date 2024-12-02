import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quizapp/screens/quiz_setup_screen.dart';
import '../../models/question.dart';
import '../../services/api_services.dart';

class QuizScreen extends StatefulWidget {
  final int questionCount;
  final String category;
  final String difficulty;
  final String type;

  QuizScreen({
    required this.questionCount,
    required this.category,
    required this.difficulty,
    required this.type,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _loading = true;
  bool _answered = false;
  String _selectedAnswer = "";
  String _feedbackText = "";
  int _timeRemaining = 15;
  Timer? _timer;
  late final PageController _pageController;
  late final List<bool>
      _correctAnswers; // Tracks correct/incorrect for each question

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _pageController = PageController();
    _correctAnswers = List.generate(widget.questionCount, (_) => false);
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await ApiService.fetchQuestions(
        amount: widget.questionCount,
        category: widget.category,
        difficulty: widget.difficulty,
        type: widget.type,
      );
      setState(() {
        _questions = questions;
        _loading = false;
      });
      _startTimer();
    } catch (e) {
      print(e);
      // Handle error appropriately
    }
  }

  void _startTimer() {
    _timeRemaining = 15;
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_answered || _timeRemaining == 0) {
        timer.cancel();
        if (_timeRemaining == 0 && !_answered) {
          _submitAnswer(""); // Auto-submit as incorrect
        }
      } else if (mounted) {
        // Ensure widget is still mounted
        setState(() => _timeRemaining--);
      }
    });
  }

  void _submitAnswer(String selectedAnswer) {
    setState(() {
      _answered = true;
      _selectedAnswer = selectedAnswer;
      final correctAnswer = _questions[_currentQuestionIndex].correctAnswer;
      if (selectedAnswer == correctAnswer) {
        _score++;
        _feedbackText = "Correct! The answer is $correctAnswer.";
        _correctAnswers[_currentQuestionIndex] = true;
      } else if (selectedAnswer.isEmpty) {
        _feedbackText = "Time's up! The correct answer is $correctAnswer.";
      } else {
        _feedbackText = "Incorrect. The correct answer is $correctAnswer.";
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _answered = false;
        _selectedAnswer = "";
        _feedbackText = "";
        _currentQuestionIndex++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startTimer();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizSummaryScreen(
            totalScore: _score,
            totalQuestions: _questions.length,
            correctAnswers: _correctAnswers,
            questions: _questions,
          ),
        ),
      ).then((_) {
        _timer?.cancel(); // Ensure the timer is canceled when navigating
      });
    }
  }

  Widget _buildOptionButton(String option) {
    return ElevatedButton(
      onPressed: _answered ? null : () => _submitAnswer(option),
      child: Text(option),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text('Score: $_score')),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Time remaining: $_timeRemaining seconds'),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final question = _questions[index];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 16),
                      Text(
                        question.question,
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 16),
                      ...question.options
                          .map((option) => _buildOptionButton(option)),
                      SizedBox(height: 20),
                      if (_answered)
                        Text(
                          _feedbackText,
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedAnswer == question.correctAnswer
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      if (_answered)
                        ElevatedButton(
                          onPressed: _nextQuestion,
                          child: Text('Next Question'),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class QuizSummaryScreen extends StatelessWidget {
  final int totalScore;
  final int totalQuestions;
  final List<bool> correctAnswers;
  final List<Question> questions;

  QuizSummaryScreen({
    required this.totalScore,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'You scored $totalScore out of $totalQuestions!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return ListTile(
                    title: Text(question.question),
                    subtitle: Text(
                      correctAnswers[index]
                          ? "Correct"
                          : "Incorrect (Answer: ${question.correctAnswer})",
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizSetupScreen(),
                ),
              ),
              child: Text('Try Another Quiz?'),
            ),
          ],
        ),
      ),
    );
  }
}

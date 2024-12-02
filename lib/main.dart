import 'package:flutter/material.dart';
import 'screens/quiz_screen.dart';
import 'screens/quiz_setup_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trivia Quiz App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: QuizSetupScreen(),
    );
  }
}

import 'package:flutter/material.dart';

void main() {
  runApp(const AppraisalApp());
}

class AppraisalApp extends StatelessWidget {
  const AppraisalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Operator Terminal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Operator System Initialized. Run "flutter pub get" to start.'),
        ),
      ),
    );
  }
}

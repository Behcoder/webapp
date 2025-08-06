import 'package:flutter/material.dart';

class StaticContentPage extends StatelessWidget {
  final String title;
  final String content;

  const StaticContentPage({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ),
    );
  }
} 
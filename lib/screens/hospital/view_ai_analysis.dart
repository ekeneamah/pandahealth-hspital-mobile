import 'package:flutter/material.dart';

class ViewAIAnalysis extends StatelessWidget {
  final String notesText;

  const ViewAIAnalysis({super.key, required this.notesText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analysis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Hero(
          tag: 'aiAnalysis',
          child: Material(
            type: MaterialType.transparency,
            child: TextField(
              controller: TextEditingController(text: notesText),
              maxLines: null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'AI Analysis Notes',
              ),
              readOnly: true,
            ),
          ),
        ),
      ),
    );
  }
}

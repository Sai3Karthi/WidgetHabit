import 'package:flutter/material.dart';

class HabitDetailScreen extends StatelessWidget {
  final String habitTitle;

  const HabitDetailScreen({super.key, required this.habitTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(habitTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(child: Text('Details for $habitTitle')),
    );
  }
}

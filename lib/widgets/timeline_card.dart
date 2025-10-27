import 'package:flutter/material.dart';
import '../models/task_step.dart';

class TimelineCard extends StatelessWidget {
  final List<TaskStep> steps;
  const TimelineCard({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (steps.isEmpty)
              const Text('No steps added yet.'),
            for (final s in steps)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 10),
                    const SizedBox(width: 8),
                    Text(s.label),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

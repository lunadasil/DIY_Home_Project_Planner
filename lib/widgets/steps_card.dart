import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_step.dart';
import '../services/project_repository.dart';

class StepsCard extends StatefulWidget {
  final String projectId;
  final List<TaskStep> steps;
  const StepsCard({super.key, required this.projectId, required this.steps});

  @override
  State<StepsCard> createState() => _StepsCardState();
}

class _StepsCardState extends State<StepsCard> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ProjectStore>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Checklist',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Add Step'),
                        content: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'e.g., Sand surfaces',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () {
                              final text = _controller.text.trim();
                              if (text.isNotEmpty) {
                                store.addStep(widget.projectId, text);
                                _controller.clear();
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_task),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...widget.steps.map(
              (s) => CheckboxListTile(
                value: s.done,
                title: Text(s.label),
                onChanged: (_) => store.toggleStep(widget.projectId, s.id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

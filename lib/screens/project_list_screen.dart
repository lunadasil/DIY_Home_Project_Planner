import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/project_repository.dart';
import '../models/models.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ProjectStore>();
    final projects = store.projects;

    return Scaffold(
      appBar: AppBar(title: const Text('DIY Home Project Planner')),
      body: projects.isEmpty
    ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/no_projects.png',
              height: 180,
            ),
            const SizedBox(height: 12),
            const Text(
              'No projects yet — start one!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      )
    : ListView.builder(
        itemCount: projects.length,
        itemBuilder: (_, i) => _ProjectTile(projects[i]),
      ),


      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('New Project'),
              content: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'e.g., Build Bookshelf',
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
                      store.addProject(text);
                      _controller.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            ),
          );
        },
        label: const Text('Add Project'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  final ProjectModel p;
  const _ProjectTile(this.p);

  @override
  Widget build(BuildContext context) {
    final completed = p.steps.where((s) => s.done).length;
    final total = p.steps.length;
    return ListTile(
      title: Text(p.title),
      subtitle: Text('Steps: $completed/$total  •  Budget: \$${p.totalCost.toStringAsFixed(2)}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/project/${p.id}'),
    );
  }
}

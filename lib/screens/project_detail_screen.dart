import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/project_repository.dart';
import '../models/models.dart';
import '../widgets/materials_card.dart';
import '../widgets/steps_card.dart';
import '../widgets/photos_card.dart';
import '../widgets/timeline_card.dart'; // <- make sure this file exists

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ProjectStore>();

    // DB-backed repo: get() is async. Use FutureBuilder.
    return FutureBuilder<ProjectModel?>(
      future: store.get(projectId),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final p = snap.data;
        if (p == null) {
          return const Scaffold(
            body: Center(child: Text('Project not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(p.title)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 🖼️ How-to image before steps
              Image.asset(
                'assets/images/how_to_steps.png',
                height: 120,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),

              // 🧩 Steps checklist
              StepsCard(projectId: p.id, steps: p.steps),
              const SizedBox(height: 12),

              // 🧱 Materials section
              MaterialsCard(
                projectId: p.id,
                materials: p.materials,
                total: p.totalCost,
              ),
              const SizedBox(height: 12),

              // 📸 Photos section
              PhotosCard(projectId: p.id, photoPaths: p.photoPaths),
              const SizedBox(height: 12),

              // 🗓️ Timeline section
              TimelineCard(steps: p.steps),

              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}

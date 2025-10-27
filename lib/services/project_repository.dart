import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/models.dart';

class ProjectRepository {
  // In-memory for Milestone 1. Replace with SQLite in Milestone 2.
  final Map<String, ProjectModel> _db = {};

  static Future<ProjectRepository> bootstrap() async {
    final repo = ProjectRepository();

    // seed example project
    final id = _uuid();
    repo._db[id] = ProjectModel(
      id: id,
      title: 'Paint Bedroom',
      description: 'Repaint walls and trim in eggshell white.',
      steps: [
        TaskStep(id: _uuid(), label: 'Buy paint & tape'),
        TaskStep(id: _uuid(), label: 'Prep walls (patch/sand)'),
        TaskStep(id: _uuid(), label: 'Cut-in edges'),
        TaskStep(id: _uuid(), label: 'Roll walls'),
      ],
      materials: [
        MaterialItem(id: _uuid(), name: 'Interior Paint (1 gal)', cost: 34.99, quantity: 2),
        MaterialItem(id: _uuid(), name: 'Painter\'s Tape', cost: 6.49, quantity: 2),
        MaterialItem(id: _uuid(), name: 'Rollers', cost: 4.50, quantity: 3),
      ],
    );

    return repo;
  }

  List<ProjectModel> list() =>
      _db.values.toList()..sort((a, b) => a.title.compareTo(b.title));

  ProjectModel? get(String id) => _db[id];

  ProjectModel create(String title) {
    final id = _uuid();
    final p = ProjectModel(id: id, title: title);
    _db[id] = p;
    return p;
  }

  void update(ProjectModel p) => _db[p.id] = p;
  void remove(String id) => _db.remove(id);
}

String _uuid() =>
    List.generate(12, (_) => _alphabet[_rand.nextInt(_alphabet.length)]).join();

const _alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
final _rand = Random();

class ProjectStore extends ChangeNotifier {
  final ProjectRepository repo;
  ProjectStore(this.repo);

  List<ProjectModel> get projects => repo.list();

  void addProject(String title) {
    repo.create(title);
    notifyListeners();
  }

  void toggleStep(String projectId, String stepId) {
    final p = repo.get(projectId);
    if (p == null) return;
    final i = p.steps.indexWhere((s) => s.id == stepId);
    if (i == -1) return;
    p.steps[i].done = !p.steps[i].done;
    repo.update(p);
    notifyListeners();
  }

  void addStep(String projectId, String label) {
    final p = repo.get(projectId);
    if (p == null) return;
    p.steps.add(TaskStep(id: _uuid(), label: label));
    repo.update(p);
    notifyListeners();
  }

  void addMaterial(
    String projectId,
    String name,
    double cost, {
    double quantity = 1,
    String? unit,
  }) {
    final p = repo.get(projectId);
    if (p == null) return;
    p.materials.add(MaterialItem(
      id: _uuid(),
      name: name,
      cost: cost,
      quantity: quantity,
      unit: unit,
    ));
    repo.update(p);
    notifyListeners();
  }
}

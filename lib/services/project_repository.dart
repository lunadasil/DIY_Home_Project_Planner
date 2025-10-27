import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';
import 'db.dart';

String _uuid() => List.generate(12, (_) => _alphabet[_rand.nextInt(_alphabet.length)]).join();
const _alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
final _rand = Random();

class ProjectRepository {
  Database? _db;

  static Future<ProjectRepository> bootstrap() async {
    final repo = ProjectRepository();
    repo._db = await AppDb.instance();

    // Seed once if empty
    final count = Sqflite.firstIntValue(
      await repo._db!.rawQuery('SELECT COUNT(*) FROM projects'),
    ) ?? 0;

    if (count == 0) {
      final id = _uuid();
      await repo._db!.insert('projects', {
        'id': id,
        'title': 'Paint Bedroom',
        'description': 'Repaint walls and trim in eggshell white.',
        'due_date': null,
      });
      // steps
      for (final s in [
        'Buy paint & tape',
        'Prep walls (patch/sand)',
        'Cut-in edges',
        'Roll walls',
      ]) {
        await repo._db!.insert('steps', {
          'id': _uuid(),
          'project_id': id,
          'label': s,
          'done': 0,
          'deadline': null,
        });
      }
      // materials
      await repo._db!.insert('materials', {
        'id': _uuid(), 'project_id': id, 'name': 'Interior Paint (1 gal)', 'cost': 34.99, 'quantity': 2.0, 'unit': null,
      });
      await repo._db!.insert('materials', {
        'id': _uuid(), 'project_id': id, 'name': "Painter's Tape", 'cost': 6.49, 'quantity': 2.0, 'unit': null,
      });
      await repo._db!.insert('materials', {
        'id': _uuid(), 'project_id': id, 'name': 'Rollers', 'cost': 4.50, 'quantity': 3.0, 'unit': null,
      });
    }
    return repo;
  }

  Future<List<ProjectModel>> list() async {
    final db = _db!;
    final rows = await db.query('projects', orderBy: 'title ASC');
    final result = <ProjectModel>[];
    for (final r in rows) {
      final id = r['id'] as String;
      result.add(await get(id) ?? _emptyProject());
    }
    return result;
  }

  Future<ProjectModel?> get(String id) async {
    final db = _db!;
    final p = (await db.query('projects', where: 'id=?', whereArgs: [id])).firstOrNull;
    if (p == null) return null;

    final stepsRows = await db.query('steps', where: 'project_id=?', whereArgs: [id], orderBy: 'deadline IS NULL, deadline ASC');
    final matRows = await db.query('materials', where: 'project_id=?', whereArgs: [id]);
    final photoRows = await db.query('photos', where: 'project_id=?', whereArgs: [id], orderBy: 'added_at DESC');

    final steps = stepsRows.map((s) => TaskStep(
      id: s['id'] as String,
      label: (s['label'] as String?) ?? '',
      done: (s['done'] as int? ?? 0) == 1,
      deadline: (s['deadline'] as int?) != null ? DateTime.fromMillisecondsSinceEpoch(s['deadline'] as int) : null,
    )).toList();

    final materials = matRows.map((m) => MaterialItem(
      id: m['id'] as String,
      name: (m['name'] as String?) ?? '',
      cost: (m['cost'] as num?)?.toDouble() ?? 0.0,
      quantity: (m['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: m['unit'] as String?,
    )).toList();

    final photos = photoRows.map((ph) => (ph['path'] as String)).toList();

    return ProjectModel(
      id: id,
      title: (p['title'] as String?) ?? '',
      description: p['description'] as String?,
      dueDate: (p['due_date'] as int?) != null ? DateTime.fromMillisecondsSinceEpoch(p['due_date'] as int) : null,
      steps: steps,
      materials: materials,
      photoPaths: photos,
    );
  }

  Future<ProjectModel> create(String title) async {
    final db = _db!;
    final id = _uuid();
    await db.insert('projects', {'id': id, 'title': title, 'description': null, 'due_date': null});
    final p = await get(id);
    return p!;
  }

  Future<void> update(ProjectModel p) async {
    final db = _db!;
    await db.update('projects', {
      'title': p.title,
      'description': p.description,
      'due_date': p.dueDate?.millisecondsSinceEpoch,
    }, where: 'id=?', whereArgs: [p.id]);
  }

  Future<void> remove(String id) async {
    final db = _db!;
    await db.delete('photos', where: 'project_id=?', whereArgs: [id]);
    await db.delete('materials', where: 'project_id=?', whereArgs: [id]);
    await db.delete('steps', where: 'project_id=?', whereArgs: [id]);
    await db.delete('projects', where: 'id=?', whereArgs: [id]);
  }

  // Steps
  Future<void> addStep(String projectId, String label, {DateTime? deadline}) async {
    final db = _db!;
    await db.insert('steps', {
      'id': _uuid(),
      'project_id': projectId,
      'label': label,
      'done': 0,
      'deadline': deadline?.millisecondsSinceEpoch,
    });
  }

  Future<void> toggleStep(String projectId, String stepId) async {
    final db = _db!;
    final s = (await db.query('steps', where: 'id=?', whereArgs: [stepId])).first;
    final done = (s['done'] as int? ?? 0) == 1 ? 0 : 1;
    await db.update('steps', {'done': done}, where: 'id=?', whereArgs: [stepId]);
  }

  Future<void> setStepDeadline(String stepId, DateTime? deadline) async {
    final db = _db!;
    await db.update('steps', {
      'deadline': deadline?.millisecondsSinceEpoch
    }, where: 'id=?', whereArgs: [stepId]);
  }

  // Materials
  Future<void> addMaterial(String projectId, String name, double cost, {double quantity = 1, String? unit}) async {
    final db = _db!;
    await db.insert('materials', {
      'id': _uuid(),
      'project_id': projectId,
      'name': name,
      'cost': cost,
      'quantity': quantity,
      'unit': unit,
    });
  }

  // Photos
  Future<void> addPhoto(String projectId, String path) async {
    final db = _db!;
    await db.insert('photos', {
      'id': _uuid(),
      'project_id': projectId,
      'path': path,
      'added_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Helpers
  ProjectModel _emptyProject() => ProjectModel(id: _uuid(), title: 'Untitled');
}

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

class ProjectStore extends ChangeNotifier {
  final ProjectRepository repo;
  ProjectStore(this.repo);

  List<ProjectModel> _cache = [];

  List<ProjectModel> get projects => _cache;

  Future<void> refresh() async {
    _cache = await repo.list();
    notifyListeners();
  }

  Future<void> addProject(String title) async {
    await repo.create(title);
    await refresh();
  }

  Future<ProjectModel?> get(String id) => repo.get(id);

  Future<void> toggleStep(String projectId, String stepId) async {
    await repo.toggleStep(projectId, stepId);
    await refresh();
  }

  Future<void> addStep(String projectId, String label, {DateTime? deadline}) async {
    await repo.addStep(projectId, label, deadline: deadline);
    await refresh();
  }

  Future<void> addMaterial(String projectId, String name, double cost, {double quantity = 1, String? unit}) async {
    await repo.addMaterial(projectId, name, cost, quantity: quantity, unit: unit);
    await refresh();
  }

  Future<void> addPhoto(String projectId, String path) async {
    await repo.addPhoto(projectId, path);
    await refresh();
  }

  Future<void> setStepDeadline(String stepId, DateTime? deadline) async {
    await repo.setStepDeadline(stepId, deadline);
    await refresh();
  }
}

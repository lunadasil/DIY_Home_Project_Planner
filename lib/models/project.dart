import 'material_item.dart';
import 'task_step.dart';

class ProjectModel {
  final String id; // uuid string
  String title;
  String? description;
  DateTime? dueDate;
  List<TaskStep> steps;
  List<MaterialItem> materials;
  double get totalCost => materials.fold(0, (sum, m) => sum + (m.cost * m.quantity));
  List<String> photoPaths; // local file paths

  ProjectModel({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    List<TaskStep>? steps,
    List<MaterialItem>? materials,
    List<String>? photoPaths,
  })  : steps = steps ?? [],
        materials = materials ?? [],
        photoPaths = photoPaths ?? [];
}

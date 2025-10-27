class TaskStep {
String id;
String label;
bool done;
DateTime? deadline;


TaskStep({required this.id, required this.label, this.done = false, this.deadline});
}
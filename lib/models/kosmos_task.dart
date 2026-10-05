enum TaskIntent { pursuing, parked, dropped, completed }

enum TaskCondition { ready, active, waiting, blocked, unavailable }

enum ProgressType {
  none,
  quantity,
  checklist,
  milestone,
  capability,
  metric,
  time,
}

class KosmosTask {
  final String id;
  final String title;
  final String? description;

  final DateTime createdAt;
  final DateTime updatedAt;

  final TaskIntent intent;
  final TaskCondition condition;

  final ProgressType progressType;
  final double? progress;
  final double? target;

  final List<String> notes;

  const KosmosTask({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.intent = TaskIntent.pursuing,
    this.condition = TaskCondition.ready,
    this.progressType = ProgressType.none,
    this.progress,
    this.target,
    this.notes = const [],
  });
}

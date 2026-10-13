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

  KosmosTask copyWith({
    String? title,
    Object? description = _unchanged,
    DateTime? updatedAt,
    TaskIntent? intent,
    TaskCondition? condition,
    ProgressType? progressType,
    Object? progress = _unchanged,
    Object? target = _unchanged,
    List<String>? notes,
  }) {
    return KosmosTask(
      id: id,
      title: title ?? this.title,
      description: identical(description, _unchanged)
          ? this.description
          : description as String?,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      intent: intent ?? this.intent,
      condition: condition ?? this.condition,
      progressType: progressType ?? this.progressType,
      progress: identical(progress, _unchanged)
          ? this.progress
          : progress as double?,
      target: identical(target, _unchanged)
          ? this.target
          : target as double?,
      notes: notes ?? this.notes,
    );
  }
}

const _unchanged = Object();

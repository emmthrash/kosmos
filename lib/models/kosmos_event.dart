enum KosmosEventType {
  created,
  changed,
  started,
  paused,
  resumed,
  completed,
  parked,
  unparked,
  noteAdded,
}

class KosmosEvent {
  final String id;
  final String taskId;
  final KosmosEventType type;
  final DateTime timestamp;
  final String? description;

  const KosmosEvent({
    required this.id,
    required this.taskId,
    required this.type,
    required this.timestamp,
    this.description,
  });
}

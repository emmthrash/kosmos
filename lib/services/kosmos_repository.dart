import '../models/kosmos_event.dart';
import '../models/kosmos_task.dart';

class KosmosRepository {
  final List<KosmosTask> _tasks = [];
  final List<KosmosEvent> _events = [];

  List<KosmosTask> get tasks => List.unmodifiable(_tasks);

  List<KosmosEvent> get events => List.unmodifiable(_events);

  void addTask(KosmosTask task) {
    _tasks.add(task);

    _events.add(
      KosmosEvent(
        id: 'event-${_events.length + 1}',
        taskId: task.id,
        type: KosmosEventType.created,
        timestamp: DateTime.now(),
        description: 'Task created',
      ),
    );
  }

  void startTask(String taskId) {
    _updateCondition(
      taskId,
      TaskCondition.active,
      KosmosEventType.started,
      'Task started',
    );
  }

  void pauseTask(String taskId) {
    _updateCondition(
      taskId,
      TaskCondition.waiting,
      KosmosEventType.paused,
      'Task paused',
    );
  }

  void resumeTask(String taskId) {
    _updateCondition(
      taskId,
      TaskCondition.active,
      KosmosEventType.resumed,
      'Task resumed',
    );
  }

  void _updateCondition(
    String taskId,
    TaskCondition condition,
    KosmosEventType eventType,
    String description,
  ) {
    final index = _tasks.indexWhere((task) => task.id == taskId);

    if (index == -1) {
      return;
    }

    final task = _tasks[index];
    final now = DateTime.now();

    _tasks[index] = KosmosTask(
      id: task.id,
      title: task.title,
      description: task.description,
      createdAt: task.createdAt,
      updatedAt: now,
      intent: task.intent,
      condition: condition,
      progressType: task.progressType,
      progress: task.progress,
      target: task.target,
      notes: task.notes,
    );

    _events.add(
      KosmosEvent(
        id: 'event-${_events.length + 1}',
        taskId: taskId,
        type: eventType,
        timestamp: now,
        description: description,
      ),
    );
  }

  List<KosmosEvent> historyFor(String taskId) {
    return List.unmodifiable(
      _events.where((event) => event.taskId == taskId),
    );
  }
}

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

  void changeCondition(
    String taskId,
    TaskCondition condition, {
    KosmosEventType eventType = KosmosEventType.changed,
    String? description,
  }) {
    _updateCondition(
      taskId,
      condition,
      eventType,
      description ?? 'Condition changed to ${condition.name}',
    );
  }

  void startTask(String taskId) {
    changeCondition(
      taskId,
      TaskCondition.active,
      eventType: KosmosEventType.started,
      description: 'Task started',
    );
  }

  void pauseTask(String taskId) {
    changeCondition(
      taskId,
      TaskCondition.waiting,
      eventType: KosmosEventType.paused,
      description: 'Task paused',
    );
  }

  void resumeTask(String taskId) {
    changeCondition(
      taskId,
      TaskCondition.active,
      eventType: KosmosEventType.resumed,
      description: 'Task resumed',
    );
  }

  void completeTask(String taskId) {
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
      intent: TaskIntent.completed,
      condition: task.condition,
      progressType: task.progressType,
      progress: task.progress,
      target: task.target,
      notes: task.notes,
    );

    _events.add(
      KosmosEvent(
        id: 'event-${_events.length + 1}',
        taskId: taskId,
        type: KosmosEventType.completed,
        timestamp: now,
        description: 'Task completed',
      ),
    );
  }

  void parkTask(String taskId) {
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
      intent: TaskIntent.parked,
      condition: task.condition,
      progressType: task.progressType,
      progress: task.progress,
      target: task.target,
      notes: task.notes,
    );

    _events.add(
      KosmosEvent(
        id: 'event-${_events.length + 1}',
        taskId: taskId,
        type: KosmosEventType.parked,
        timestamp: now,
        description: 'Task parked',
      ),
    );
  }

  void unparkTask(String taskId) {
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
      intent: TaskIntent.pursuing,
      condition: task.condition,
      progressType: task.progressType,
      progress: task.progress,
      target: task.target,
      notes: task.notes,
    );

    _events.add(
      KosmosEvent(
        id: 'event-${_events.length + 1}',
        taskId: taskId,
        type: KosmosEventType.unparked,
        timestamp: now,
        description: 'Task unparked',
      ),
    );
  }

  void updateTask(
    String taskId, {
    String? title,
    String? description,
    ProgressType? progressType,
    double? target,
  }) {
    final index = _tasks.indexWhere((task) => task.id == taskId);

    if (index == -1) {
      return;
    }

    final task = _tasks[index];
    final now = DateTime.now();

    _tasks[index] = KosmosTask(
      id: task.id,
      title: title ?? task.title,
      description: description ?? task.description,
      createdAt: task.createdAt,
      updatedAt: now,
      intent: task.intent,
      condition: task.condition,
      progressType: progressType ?? task.progressType,
      progress: task.progress,
      target: target ?? task.target,
      notes: task.notes,
    );

    _events.add(
      KosmosEvent(
        id: 'event-${_events.length + 1}',
        taskId: taskId,
        type: KosmosEventType.changed,
        timestamp: now,
        description: 'Task updated',
      ),
    );
  }

  void updateProgress(String taskId, double progress) {
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
      condition: task.condition,
      progressType: task.progressType,
      progress: progress,
      target: task.target,
      notes: task.notes,
    );

    _events.add(
      KosmosEvent(
        id: 'event-${_events.length + 1}',
        taskId: taskId,
        type: KosmosEventType.changed,
        timestamp: now,
        description: 'Progress updated from ${task.progress} to $progress',
      ),
    );
  }

  void addNote(String taskId, String note) {
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
      condition: task.condition,
      progressType: task.progressType,
      progress: task.progress,
      target: task.target,
      notes: [...task.notes, note],
    );

    _events.add(
      KosmosEvent(
        id: 'event-${_events.length + 1}',
        taskId: taskId,
        type: KosmosEventType.noteAdded,
        timestamp: now,
        description: note,
      ),
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

  KosmosTask? taskById(String taskId) {
    for (final task in _tasks) {
      if (task.id == taskId) {
        return task;
      }
    }

    return null;
  }

  List<KosmosTask> tasksByIntent(TaskIntent intent) {
    return List.unmodifiable(_tasks.where((task) => task.intent == intent));
  }

  List<KosmosTask> tasksByCondition(TaskCondition condition) {
    return List.unmodifiable(
      _tasks.where((task) => task.condition == condition),
    );
  }

  List<KosmosTask> tasksNeedingAttention() {
    return List.unmodifiable(
      _tasks.where(
        (task) =>
            task.intent == TaskIntent.pursuing &&
            (task.condition == TaskCondition.ready ||
                task.condition == TaskCondition.active),
      ),
    );
  }

  List<KosmosEvent> historyFor(String taskId) {
    return List.unmodifiable(_events.where((event) => event.taskId == taskId));
  }
}

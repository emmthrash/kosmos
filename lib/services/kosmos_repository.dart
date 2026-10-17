import '../models/attention_decision.dart';
import '../models/kosmos_event.dart';
import '../models/kosmos_task.dart';
import '../models/task_eligibility.dart';

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
    _updateTaskState(
      taskId,
      intent: TaskIntent.completed,
      eventType: KosmosEventType.completed,
      description: 'Task completed',
    );
  }

  void parkTask(String taskId) {
    _updateTaskState(
      taskId,
      intent: TaskIntent.parked,
      eventType: KosmosEventType.parked,
      description: 'Task parked',
    );
  }

  void unparkTask(String taskId) {
    _updateTaskState(
      taskId,
      intent: TaskIntent.pursuing,
      eventType: KosmosEventType.unparked,
      description: 'Task unparked',
    );
  }

  void updateTask(
    String taskId, {
    String? title,
    String? description,
    ProgressType? progressType,
    double? target,
  }) {
    final task = taskById(taskId);

    if (task == null) {
      return;
    }

    _replaceTask(
      task,
      task.copyWith(
        title: title,
        description: description ?? task.description,
        progressType: progressType,
        target: target,
        updatedAt: DateTime.now(),
      ),
      eventType: KosmosEventType.changed,
      description: 'Task updated',
    );
  }

  void updateProgress(String taskId, double progress) {
    final task = taskById(taskId);

    if (task == null) {
      return;
    }

    _replaceTask(
      task,
      task.copyWith(progress: progress, updatedAt: DateTime.now()),
      eventType: KosmosEventType.changed,
      description: 'Progress updated from ${task.progress} to $progress',
    );
  }

  void addNote(String taskId, String note) {
    final task = taskById(taskId);

    if (task == null) {
      return;
    }

    _replaceTask(
      task,
      task.copyWith(notes: [...task.notes, note], updatedAt: DateTime.now()),
      eventType: KosmosEventType.noteAdded,
      description: note,
    );
  }

  void _updateCondition(
    String taskId,
    TaskCondition condition,
    KosmosEventType eventType,
    String description,
  ) {
    final task = taskById(taskId);

    if (task == null) {
      return;
    }

    _replaceTask(
      task,
      task.copyWith(condition: condition, updatedAt: DateTime.now()),
      eventType: eventType,
      description: description,
    );
  }

  void _updateTaskState(
    String taskId, {
    required TaskIntent intent,
    required KosmosEventType eventType,
    required String description,
  }) {
    final task = taskById(taskId);

    if (task == null) {
      return;
    }

    _replaceTask(
      task,
      task.copyWith(intent: intent, updatedAt: DateTime.now()),
      eventType: eventType,
      description: description,
    );
  }

  void _replaceTask(
    KosmosTask oldTask,
    KosmosTask newTask, {
    required KosmosEventType eventType,
    required String description,
  }) {
    final index = _tasks.indexWhere((task) => task.id == oldTask.id);

    if (index == -1) {
      return;
    }

    final now = newTask.updatedAt;
    _tasks[index] = newTask;

    _events.add(
      KosmosEvent(
        id: 'event-${_events.length + 1}',
        taskId: newTask.id,
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

  TaskEligibility evaluateTaskEligibility(KosmosTask task) {
    return TaskEligibility.evaluate(task);
  }

  List<KosmosTask> tasksNeedingAttention() {
    return List.unmodifiable(
      _tasks.where((task) => evaluateTaskEligibility(task).isEligible),
    );
  }

  AttentionDecision chooseAttentionDecision() {
    final candidates = tasksNeedingAttention();

    if (candidates.isEmpty) {
      return const AttentionDecision(
        task: null,
        reason: AttentionDecisionReason.noEligibleTasks,
      );
    }

    final selected = candidates.reduce((oldest, task) {
      final timestampComparison = task.updatedAt.compareTo(oldest.updatedAt);

      if (timestampComparison < 0) {
        return task;
      }

      if (timestampComparison == 0 && task.id.compareTo(oldest.id) < 0) {
        return task;
      }

      return oldest;
    });

    return AttentionDecision(
      task: selected,
      reason: AttentionDecisionReason.leastRecentlyUpdated,
    );
  }

  KosmosTask? chooseAttentionTask() {
    return chooseAttentionDecision().task;
  }

  List<KosmosEvent> historyFor(String taskId) {
    return List.unmodifiable(_events.where((event) => event.taskId == taskId));
  }
}

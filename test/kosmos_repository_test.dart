import 'package:flutter_test/flutter_test.dart';
import 'package:kosmos/models/kosmos_event.dart';
import 'package:kosmos/models/kosmos_task.dart';
import 'package:kosmos/models/attention_decision.dart';
import 'package:kosmos/services/kosmos_repository.dart';
import 'package:kosmos/models/task_eligibility.dart';

void main() {
  test('adding a task creates a creation history event', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    final task = KosmosTask(
      id: 'task-001',
      title: 'Learn Dart classes',
      createdAt: now,
      updatedAt: now,
    );

    repository.addTask(task);

    expect(repository.tasks.length, 1);
    expect(repository.tasks.first.id, 'task-001');

    final history = repository.historyFor('task-001');

    expect(history.length, 1);
    expect(history.first.type, KosmosEventType.created);
    expect(history.first.taskId, 'task-001');
  });

  test('updating a task changes its basic details and records history', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    final task = KosmosTask(
      id: 'task-010',
      title: 'Old title',
      description: 'Old description',
      createdAt: now,
      updatedAt: now,
      progressType: ProgressType.quantity,
      target: 10,
    );

    repository.addTask(task);

    repository.updateTask(
      'task-010',
      title: 'New title',
      description: 'New description',
      progressType: ProgressType.milestone,
      target: 5,
    );

    final updatedTask = repository.tasks.first;

    expect(updatedTask.title, 'New title');
    expect(updatedTask.description, 'New description');
    expect(updatedTask.progressType, ProgressType.milestone);
    expect(updatedTask.target, 5);

    expect(updatedTask.intent, TaskIntent.pursuing);
    expect(updatedTask.condition, TaskCondition.ready);
    expect(updatedTask.progress, isNull);
    expect(updatedTask.notes, isEmpty);

    final history = repository.historyFor('task-010');

    expect(history.length, 2);
    expect(history[0].type, KosmosEventType.created);
    expect(history[1].type, KosmosEventType.changed);
    expect(history[1].description, 'Task updated');
  });

  test('parking an active task preserves its condition for now', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    final task = KosmosTask(
      id: 'task-007',
      title: 'Experiment with task parking',
      createdAt: now,
      updatedAt: now,
    );

    repository.addTask(task);
    repository.startTask('task-007');
    repository.parkTask('task-007');

    expect(repository.tasks.first.intent, TaskIntent.parked);
    expect(repository.tasks.first.condition, TaskCondition.active);

    final history = repository.historyFor('task-007');

    expect(history.length, 3);
    expect(history[0].type, KosmosEventType.created);
    expect(history[1].type, KosmosEventType.started);
    expect(history[2].type, KosmosEventType.parked);
  });

  test('starting a task changes its condition and records history', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    final task = KosmosTask(
      id: 'task-002',
      title: 'Build KOSMOS',
      createdAt: now,
      updatedAt: now,
    );

    repository.addTask(task);
    repository.startTask('task-002');

    expect(repository.tasks.first.condition, TaskCondition.active);

    final history = repository.historyFor('task-002');

    expect(history.length, 2);
    expect(history[0].type, KosmosEventType.created);
    expect(history[1].type, KosmosEventType.started);
  });

  test('pausing and resuming a task preserves its history', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    final task = KosmosTask(
      id: 'task-003',
      title: 'Build history system',
      createdAt: now,
      updatedAt: now,
    );

    repository.addTask(task);
    repository.startTask('task-003');
    repository.pauseTask('task-003');

    expect(repository.tasks.first.condition, TaskCondition.waiting);

    repository.resumeTask('task-003');

    expect(repository.tasks.first.condition, TaskCondition.active);

    final history = repository.historyFor('task-003');

    expect(history.length, 4);
    expect(history[0].type, KosmosEventType.created);
    expect(history[1].type, KosmosEventType.started);
    expect(history[2].type, KosmosEventType.paused);
    expect(history[3].type, KosmosEventType.resumed);
  });

  test('adding a note stores it and records note history', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    final task = KosmosTask(
      id: 'task-004',
      title: 'Explore KOSMOS design',
      createdAt: now,
      updatedAt: now,
    );

    repository.addTask(task);

    repository.addNote(
      'task-004',
      'Waiting may need to be different from paused.',
    );

    expect(repository.tasks.first.notes.length, 1);
    expect(
      repository.tasks.first.notes.first,
      'Waiting may need to be different from paused.',
    );

    final history = repository.historyFor('task-004');

    expect(history.length, 2);
    expect(history[0].type, KosmosEventType.created);
    expect(history[1].type, KosmosEventType.noteAdded);
    expect(
      history[1].description,
      'Waiting may need to be different from paused.',
    );
  });
  test('completing a task changes its intent and records history', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    final task = KosmosTask(
      id: 'task-005',
      title: 'Finish KOSMOS lifecycle',
      createdAt: now,
      updatedAt: now,
    );

    repository.addTask(task);
    repository.startTask('task-005');
    repository.completeTask('task-005');

    expect(repository.tasks.first.intent, TaskIntent.completed);
    expect(repository.tasks.first.condition, TaskCondition.active);

    final history = repository.historyFor('task-005');

    expect(history.length, 3);
    expect(history[0].type, KosmosEventType.created);
    expect(history[1].type, KosmosEventType.started);
    expect(history[2].type, KosmosEventType.completed);
    expect(history[2].description, 'Task completed');
  });
  test('parking a task changes its intent and records history', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    final task = KosmosTask(
      id: 'task-006',
      title: 'Research future home lab',
      createdAt: now,
      updatedAt: now,
    );

    repository.addTask(task);
    repository.parkTask('task-006');

    expect(repository.tasks.first.intent, TaskIntent.parked);
    expect(repository.tasks.first.condition, TaskCondition.ready);

    final history = repository.historyFor('task-006');

    expect(history.length, 2);
    expect(history[0].type, KosmosEventType.created);
    expect(history[1].type, KosmosEventType.parked);
    expect(history[1].description, 'Task parked');
  });

  test('unparking a task returns its intent to pursuing', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    final task = KosmosTask(
      id: 'task-008',
      title: 'Return to KOSMOS experiment',
      createdAt: now,
      updatedAt: now,
    );

    repository.addTask(task);
    repository.parkTask('task-008');
    repository.unparkTask('task-008');

    expect(repository.tasks.first.intent, TaskIntent.pursuing);
    expect(repository.tasks.first.condition, TaskCondition.ready);

    final history = repository.historyFor('task-008');

    expect(history.length, 3);
    expect(history[0].type, KosmosEventType.created);
    expect(history[1].type, KosmosEventType.parked);
    expect(history[2].type, KosmosEventType.unparked);
    expect(history[2].description, 'Task unparked');
  });

  test('task survives a complete lifecycle with full history', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    final task = KosmosTask(
      id: 'task-009',
      title: 'Test complete KOSMOS lifecycle',
      createdAt: now,
      updatedAt: now,
    );

    repository.addTask(task);

    repository.startTask('task-009');
    repository.pauseTask('task-009');
    repository.resumeTask('task-009');
    repository.parkTask('task-009');
    repository.unparkTask('task-009');
    repository.startTask('task-009');
    repository.completeTask('task-009');

    final currentTask = repository.tasks.first;

    expect(currentTask.intent, TaskIntent.completed);
    expect(currentTask.condition, TaskCondition.active);

    final history = repository.historyFor('task-009');

    expect(history.length, 8);

    expect(history[0].type, KosmosEventType.created);
    expect(history[1].type, KosmosEventType.started);
    expect(history[2].type, KosmosEventType.paused);
    expect(history[3].type, KosmosEventType.resumed);
    expect(history[4].type, KosmosEventType.parked);
    expect(history[5].type, KosmosEventType.unparked);
    expect(history[6].type, KosmosEventType.started);
    expect(history[7].type, KosmosEventType.completed);
  });
  test('updating progress changes progress and records history', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    final task = KosmosTask(
      id: 'task-010',
      title: 'Learn Dart',
      createdAt: now,
      updatedAt: now,
      progressType: ProgressType.quantity,
      progress: 3,
      target: 10,
    );

    repository.addTask(task);
    repository.updateProgress('task-010', 5);

    final currentTask = repository.tasks.first;

    expect(currentTask.progress, 5);
    expect(currentTask.target, 10);
    expect(currentTask.progressType, ProgressType.quantity);
    expect(currentTask.intent, TaskIntent.pursuing);
    expect(currentTask.condition, TaskCondition.ready);

    final history = repository.historyFor('task-010');

    expect(history.length, 2);
    expect(history[0].type, KosmosEventType.created);
    expect(history[1].type, KosmosEventType.changed);
    expect(history[1].description, 'Progress updated from 3.0 to 5.0');
  });
  test('progress can exceed its target without completing the task', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    final task = KosmosTask(
      id: 'task-011',
      title: 'Build beyond the original target',
      createdAt: now,
      updatedAt: now,
      progressType: ProgressType.quantity,
      progress: 10,
      target: 10,
    );

    repository.addTask(task);

    repository.updateProgress('task-011', 12);

    final currentTask = repository.tasks.first;

    expect(currentTask.progress, 12);
    expect(currentTask.target, 10);
    expect(currentTask.intent, TaskIntent.pursuing);
    expect(currentTask.condition, TaskCondition.ready);

    final history = repository.historyFor('task-011');

    expect(history.length, 2);
    expect(history[1].type, KosmosEventType.changed);
    expect(history[1].description, 'Progress updated from 10.0 to 12.0');
  });

  test('progress can move backward without changing task completion state', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    final task = KosmosTask(
      id: 'task-012',
      title: 'Progress can go backward',
      createdAt: now,
      updatedAt: now,
      progressType: ProgressType.quantity,
      progress: 12,
      target: 10,
    );

    repository.addTask(task);

    repository.updateProgress('task-012', 8);

    final currentTask = repository.tasks.first;

    expect(currentTask.progress, 8);
    expect(currentTask.target, 10);
    expect(currentTask.intent, TaskIntent.pursuing);
    expect(currentTask.condition, TaskCondition.ready);

    final history = repository.historyFor('task-012');

    expect(history.length, 2);
    expect(history[1].type, KosmosEventType.changed);
    expect(history[1].description, 'Progress updated from 12.0 to 8.0');
  });

  test('a task can have zero progress without being completed', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    final task = KosmosTask(
      id: 'task-013',
      title: 'Start from zero',
      createdAt: now,
      updatedAt: now,
      progressType: ProgressType.quantity,
      progress: 0,
      target: 10,
    );

    repository.addTask(task);

    final currentTask = repository.tasks.first;

    expect(currentTask.progress, 0);
    expect(currentTask.target, 10);
    expect(currentTask.intent, TaskIntent.pursuing);
    expect(currentTask.condition, TaskCondition.ready);

    final history = repository.historyFor('task-013');

    expect(history.length, 1);
    expect(history[0].type, KosmosEventType.created);
  });
  test('a pursuing task can be blocked without being completed or parked', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    final task = KosmosTask(
      id: 'task-014',
      title: 'Set up home server',
      createdAt: now,
      updatedAt: now,
      intent: TaskIntent.pursuing,
      condition: TaskCondition.blocked,
    );

    repository.addTask(task);

    final currentTask = repository.tasks.first;

    expect(currentTask.intent, TaskIntent.pursuing);
    expect(currentTask.condition, TaskCondition.blocked);
    expect(currentTask.progress, isNull);
    expect(currentTask.target, isNull);

    final history = repository.historyFor('task-014');

    expect(history.length, 1);
    expect(history[0].type, KosmosEventType.created);
  });

  test('a blocked task can receive progress without becoming ready', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    final task = KosmosTask(
      id: 'task-015',
      title: 'Resume blocked work',
      createdAt: now,
      updatedAt: now,
      intent: TaskIntent.pursuing,
      condition: TaskCondition.blocked,
    );

    repository.addTask(task);

    repository.updateProgress('task-015', 1);

    final currentTask = repository.tasks.first;

    expect(currentTask.intent, TaskIntent.pursuing);
    expect(currentTask.condition, TaskCondition.blocked);
    expect(currentTask.progress, 1);
  });
  test('condition can be changed without changing intent', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    final task = KosmosTask(
      id: 'task-016',
      title: 'Task that becomes blocked',
      createdAt: now,
      updatedAt: now,
      intent: TaskIntent.pursuing,
      condition: TaskCondition.ready,
    );

    repository.addTask(task);

    repository.changeCondition('task-016', TaskCondition.blocked);

    final currentTask = repository.tasks.first;

    expect(currentTask.intent, TaskIntent.pursuing);
    expect(currentTask.condition, TaskCondition.blocked);

    final history = repository.historyFor('task-016');

    expect(history.length, 2);
    expect(history[1].type, KosmosEventType.changed);
    expect(history[1].description, 'Condition changed to blocked');
  });

  test('a blocked task can return to ready', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    final task = KosmosTask(
      id: 'task-017',
      title: 'Unblock task',
      createdAt: now,
      updatedAt: now,
      intent: TaskIntent.pursuing,
      condition: TaskCondition.blocked,
    );

    repository.addTask(task);

    repository.changeCondition('task-017', TaskCondition.ready);

    final currentTask = repository.tasks.first;

    expect(currentTask.intent, TaskIntent.pursuing);
    expect(currentTask.condition, TaskCondition.ready);

    final history = repository.historyFor('task-017');

    expect(history.length, 2);
    expect(history[0].type, KosmosEventType.created);
    expect(history[1].type, KosmosEventType.changed);
    expect(history[1].description, 'Condition changed to ready');
  });

  test('retrieving a task by id returns the correct task', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    repository.addTask(
      KosmosTask(
        id: 'task-011',
        title: 'Build KOSMOS',
        createdAt: now,
        updatedAt: now,
      ),
    );

    repository.addTask(
      KosmosTask(
        id: 'task-012',
        title: 'Study networking',
        createdAt: now,
        updatedAt: now,
      ),
    );

    final task = repository.taskById('task-012');

    expect(task, isNotNull);
    expect(task!.id, 'task-012');
    expect(task.title, 'Study networking');
  });

  test('retrieving an unknown task id returns null', () {
    final repository = KosmosRepository();

    final task = repository.taskById('does-not-exist');

    expect(task, isNull);
  });

  test('retrieving tasks by intent returns only matching tasks', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    repository.addTask(
      KosmosTask(
        id: 'task-013',
        title: 'Active mission',
        createdAt: now,
        updatedAt: now,
        intent: TaskIntent.pursuing,
      ),
    );

    repository.addTask(
      KosmosTask(
        id: 'task-014',
        title: 'Parked mission',
        createdAt: now,
        updatedAt: now,
        intent: TaskIntent.parked,
      ),
    );

    repository.addTask(
      KosmosTask(
        id: 'task-015',
        title: 'Completed mission',
        createdAt: now,
        updatedAt: now,
        intent: TaskIntent.completed,
      ),
    );

    final pursuing = repository.tasksByIntent(TaskIntent.pursuing);

    expect(pursuing.length, 1);
    expect(pursuing.first.id, 'task-013');
  });

  test('retrieving tasks by intent returns an empty list when none match', () {
    final repository = KosmosRepository();

    final completed = repository.tasksByIntent(TaskIntent.completed);

    expect(completed, isEmpty);
  });

  test('retrieving tasks by condition returns only matching tasks', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    repository.addTask(
      KosmosTask(
        id: 'task-016',
        title: 'Ready task',
        createdAt: now,
        updatedAt: now,
        condition: TaskCondition.ready,
      ),
    );

    repository.addTask(
      KosmosTask(
        id: 'task-017',
        title: 'Active task',
        createdAt: now,
        updatedAt: now,
        condition: TaskCondition.active,
      ),
    );

    repository.addTask(
      KosmosTask(
        id: 'task-018',
        title: 'Blocked task',
        createdAt: now,
        updatedAt: now,
        condition: TaskCondition.blocked,
      ),
    );

    final active = repository.tasksByCondition(TaskCondition.active);

    expect(active.length, 1);
    expect(active.first.id, 'task-017');
  });

  test(
    'retrieving tasks by condition returns an empty list when none match',
    () {
      final repository = KosmosRepository();

      final waiting = repository.tasksByCondition(TaskCondition.waiting);

      expect(waiting, isEmpty);
    },
  );

  test('tasks needing attention are pursuing and ready or active', () {
    final repository = KosmosRepository();
    final now = DateTime.now();

    repository.addTask(
      KosmosTask(
        id: 'task-019',
        title: 'Ready mission',
        createdAt: now,
        updatedAt: now,
        intent: TaskIntent.pursuing,
        condition: TaskCondition.ready,
      ),
    );

    repository.addTask(
      KosmosTask(
        id: 'task-020',
        title: 'Active mission',
        createdAt: now,
        updatedAt: now,
        intent: TaskIntent.pursuing,
        condition: TaskCondition.active,
      ),
    );

    repository.addTask(
      KosmosTask(
        id: 'task-021',
        title: 'Waiting mission',
        createdAt: now,
        updatedAt: now,
        intent: TaskIntent.pursuing,
        condition: TaskCondition.waiting,
      ),
    );

    repository.addTask(
      KosmosTask(
        id: 'task-022',
        title: 'Parked mission',
        createdAt: now,
        updatedAt: now,
        intent: TaskIntent.parked,
        condition: TaskCondition.ready,
      ),
    );

    final attention = repository.tasksNeedingAttention();

    expect(attention.length, 2);
    expect(attention[0].id, 'task-019');
    expect(attention[1].id, 'task-020');
  });

  test(
    'choosing an attention task selects the least recently updated task',
    () {
      final repository = KosmosRepository();

      final older = DateTime(2026, 10, 1);
      final newer = DateTime(2026, 10, 5);

      repository.addTask(
        KosmosTask(
          id: 'task-023',
          title: 'Older task',
          createdAt: older,
          updatedAt: older,
          intent: TaskIntent.pursuing,
          condition: TaskCondition.ready,
        ),
      );

      repository.addTask(
        KosmosTask(
          id: 'task-024',
          title: 'Newer task',
          createdAt: newer,
          updatedAt: newer,
          intent: TaskIntent.pursuing,
          condition: TaskCondition.ready,
        ),
      );

      final selected = repository.chooseAttentionTask();

      expect(selected, isNotNull);
      expect(selected!.id, 'task-023');
    },
  );

  test('attention selection breaks timestamp ties by task ID', () {
    final repository = KosmosRepository();
    final sameTime = DateTime(2026, 10, 1);

    // Add in reverse ID order to prove selection doesn't depend on insertion.
    for (final id in ['task-z', 'task-a', 'task-m']) {
      repository.addTask(
        KosmosTask(
          id: id,
          title: id,
          createdAt: sameTime,
          updatedAt: sameTime,
          intent: TaskIntent.pursuing,
          condition: TaskCondition.ready,
        ),
      );
    }

    final decision = repository.chooseAttentionDecision();

    expect(decision.task?.id, 'task-a');
    expect(decision.reason, AttentionDecisionReason.leastRecentlyUpdated);
  });

  test('choosing an attention task returns null when none need attention', () {
    final repository = KosmosRepository();

    final selected = repository.chooseAttentionTask();

    expect(selected, isNull);
  });

  test('chosen attention task can be started', () {
    final repository = KosmosRepository();

    final createdAt = DateTime(2026, 10, 1);
    final updatedAt = DateTime(2026, 10, 1);

    repository.addTask(
      KosmosTask(
        id: 'task-025',
        title: 'Task to start',
        createdAt: createdAt,
        updatedAt: updatedAt,
        intent: TaskIntent.pursuing,
        condition: TaskCondition.ready,
      ),
    );

    final selected = repository.chooseAttentionTask();

    expect(selected, isNotNull);
    expect(selected!.condition, TaskCondition.ready);

    repository.startTask(selected.id);

    final startedTask = repository.taskById(selected.id);

    expect(startedTask, isNotNull);
    expect(startedTask!.condition, TaskCondition.active);

    final history = repository.historyFor(selected.id);

    expect(history.length, 2);
    expect(history[0].type, KosmosEventType.created);
    expect(history[1].type, KosmosEventType.started);
  });

  test('a started task can receive a note in the loop', () {
    final repository = KosmosRepository();

    final createdAt = DateTime(2026, 10, 1);

    repository.addTask(
      KosmosTask(
        id: 'task-026',
        title: 'Loop task',
        createdAt: createdAt,
        updatedAt: createdAt,
        intent: TaskIntent.pursuing,
        condition: TaskCondition.ready,
      ),
    );

    final selected = repository.chooseAttentionTask();

    expect(selected, isNotNull);

    repository.startTask(selected!.id);
    repository.addNote(selected.id, 'Started working on the task.');

    final task = repository.taskById(selected.id);

    expect(task, isNotNull);
    expect(task!.condition, TaskCondition.active);
    expect(task.notes, ['Started working on the task.']);

    final history = repository.historyFor(selected.id);

    expect(history.length, 3);
    expect(history[0].type, KosmosEventType.created);
    expect(history[1].type, KosmosEventType.started);
    expect(history[2].type, KosmosEventType.noteAdded);
    expect(history[2].description, 'Started working on the task.');
  });

  test('after acting on one task, the next check can choose another task', () {
    final repository = KosmosRepository();

    final firstTime = DateTime(2026, 10, 1);
    final secondTime = DateTime(2026, 10, 2);

    repository.addTask(
      KosmosTask(
        id: 'task-027',
        title: 'First task',
        createdAt: firstTime,
        updatedAt: firstTime,
        intent: TaskIntent.pursuing,
        condition: TaskCondition.ready,
      ),
    );

    repository.addTask(
      KosmosTask(
        id: 'task-028',
        title: 'Second task',
        createdAt: secondTime,
        updatedAt: secondTime,
        intent: TaskIntent.pursuing,
        condition: TaskCondition.ready,
      ),
    );

    // First CHECK → CHOOSE.
    final firstChoice = repository.chooseAttentionTask();

    expect(firstChoice, isNotNull);
    expect(firstChoice!.id, 'task-027');

    // DO → NOTE.
    repository.startTask(firstChoice.id);
    repository.addNote(firstChoice.id, 'First cycle completed.');

    // REPEAT → CHECK → CHOOSE again.
    final secondChoice = repository.chooseAttentionTask();

    expect(secondChoice, isNotNull);
    expect(secondChoice!.id, 'task-028');
  });
  test('attention choice ignores tasks that cannot be acted on', () {
    final repository = KosmosRepository();

    final time = DateTime(2026, 10, 1);

    repository.addTask(
      KosmosTask(
        id: 'task-029',
        title: 'Parked task',
        createdAt: time,
        updatedAt: time,
        intent: TaskIntent.parked,
        condition: TaskCondition.ready,
      ),
    );

    repository.addTask(
      KosmosTask(
        id: 'task-030',
        title: 'Dropped task',
        createdAt: time,
        updatedAt: time,
        intent: TaskIntent.dropped,
        condition: TaskCondition.ready,
      ),
    );

    repository.addTask(
      KosmosTask(
        id: 'task-031',
        title: 'Completed task',
        createdAt: time,
        updatedAt: time,
        intent: TaskIntent.completed,
        condition: TaskCondition.ready,
      ),
    );

    repository.addTask(
      KosmosTask(
        id: 'task-032',
        title: 'Waiting task',
        createdAt: time,
        updatedAt: time,
        intent: TaskIntent.pursuing,
        condition: TaskCondition.waiting,
      ),
    );

    repository.addTask(
      KosmosTask(
        id: 'task-033',
        title: 'Blocked task',
        createdAt: time,
        updatedAt: time,
        intent: TaskIntent.pursuing,
        condition: TaskCondition.blocked,
      ),
    );

    final choice = repository.chooseAttentionTask();

    expect(choice, isNull);
  });

  test('a blocked task can become actionable again', () {
    final repository = KosmosRepository();

    final time = DateTime(2026, 10, 1);

    repository.addTask(
      KosmosTask(
        id: 'task-034',
        title: 'Recoverable task',
        createdAt: time,
        updatedAt: time,
        intent: TaskIntent.pursuing,
        condition: TaskCondition.blocked,
      ),
    );

    // CHECK: blocked task is not actionable.
    expect(repository.chooseAttentionTask(), isNull);

    // Situation changes: the task becomes ready.
    repository.changeCondition('task-034', TaskCondition.ready);

    // CHECK again: the task is now actionable.
    final choice = repository.chooseAttentionTask();

    expect(choice, isNotNull);
    expect(choice!.id, 'task-034');
    expect(choice.condition, TaskCondition.ready);
  });

  test('explains why an attention task was selected', () {
    final repository = KosmosRepository();
    final older = DateTime(2026, 10, 1);
    final newer = DateTime(2026, 10, 5);

    repository.addTask(
      KosmosTask(
        id: 'attention-old',
        title: 'Older eligible task',
        createdAt: older,
        updatedAt: older,
      ),
    );

    repository.addTask(
      KosmosTask(
        id: 'attention-new',
        title: 'Newer eligible task',
        createdAt: newer,
        updatedAt: newer,
      ),
    );

    final decision = repository.chooseAttentionDecision();

    expect(decision.hasSelection, isTrue);
    expect(decision.selectedCondition, TaskCondition.ready);
    expect(decision.selectedIntent, TaskIntent.pursuing);
    expect(decision.awaitingUserChoice, isTrue);
    expect(decision.task?.id, 'attention-old');
    expect(decision.reason, AttentionDecisionReason.leastRecentlyUpdated);
    expect(
      decision.eligibilityExplanation,
      'Task is pursuing and its condition is ready.',
    );
    expect(
      decision.selectionExplanation,
      'Chosen because it has the oldest last-updated timestamp '
      'among eligible tasks.',
    );
    expect(
      decision.explanation,
      'Task is pursuing and its condition is ready. '
      'Chosen because it has the oldest last-updated timestamp '
      'among eligible tasks.',
    );
    expect(repository.chooseAttentionTask()?.id, 'attention-old');
  });

  test('explains when no task is eligible for attention', () {
    final repository = KosmosRepository();
    final decision = repository.chooseAttentionDecision();

    expect(decision.hasSelection, isFalse);
    expect(decision.selectedCondition, isNull);
    expect(decision.selectedIntent, isNull);
    expect(decision.awaitingUserChoice, isFalse);
    expect(decision.task, isNull);
    expect(decision.reason, AttentionDecisionReason.noEligibleTasks);
    expect(
      decision.eligibilityExplanation,
      'No task meets the current attention eligibility rules.',
    );
    expect(
      decision.selectionExplanation,
      'No selection was made because there are no eligible tasks.',
    );
    expect(decision.explanation, 'No eligible tasks need attention right now.');
    expect(repository.chooseAttentionTask(), isNull);
  });
  test('ready and active pursuing tasks are eligible', () {
    final now = DateTime(2026, 10, 16);

    for (final condition in [TaskCondition.ready, TaskCondition.active]) {
      final task = KosmosTask(
        id: 'eligible-${condition.name}',
        title: '${condition.name} task',
        createdAt: now,
        updatedAt: now,
        intent: TaskIntent.pursuing,
        condition: condition,
      );

      final eligibility = TaskEligibility.evaluate(task);

      expect(eligibility.isEligible, isTrue);
      expect(
        eligibility.reason,
        condition == TaskCondition.ready
            ? TaskEligibilityReason.eligibleReady
            : TaskEligibilityReason.eligibleActive,
      );
      expect(eligibility.explanation, contains('Task is pursuing'));
    }
  });

  test('waiting blocked and unavailable tasks are not eligible', () {
    final now = DateTime(2026, 10, 16);

    for (final condition in [
      TaskCondition.waiting,
      TaskCondition.blocked,
      TaskCondition.unavailable,
    ]) {
      final task = KosmosTask(
        id: 'ineligible-${condition.name}',
        title: '${condition.name} task',
        createdAt: now,
        updatedAt: now,
        intent: TaskIntent.pursuing,
        condition: condition,
      );

      final eligibility = TaskEligibility.evaluate(task);

      expect(eligibility.isEligible, isFalse);
      expect(eligibility.reason, TaskEligibilityReason.conditionNotActionable);
      expect(
        eligibility.explanation,
        'Not eligible: task condition is ${condition.name}.',
      );
    }
  });

  test('non-pursuing intents take precedence in eligibility explanations', () {
    final now = DateTime(2026, 10, 16);

    for (final intent in [
      TaskIntent.parked,
      TaskIntent.dropped,
      TaskIntent.completed,
    ]) {
      final task = KosmosTask(
        id: 'intent-${intent.name}',
        title: '${intent.name} task',
        createdAt: now,
        updatedAt: now,
        intent: intent,
        condition: TaskCondition.ready,
      );

      final eligibility = TaskEligibility.evaluate(task);

      expect(eligibility.isEligible, isFalse);
      expect(eligibility.reason, TaskEligibilityReason.intentNotPursuing);
      expect(
        eligibility.explanation,
        'Not eligible: task intent is ${intent.name}.',
      );
    }
  });
  test(
    'attention assessment includes every task and separates eligibility',
    () {
      final repository = KosmosRepository();
      final now = DateTime(2026, 1, 1);

      repository.addTask(
        KosmosTask(
          id: 'eligible-ready',
          title: 'Ready task',
          createdAt: now,
          updatedAt: now,
          intent: TaskIntent.pursuing,
          condition: TaskCondition.ready,
        ),
      );

      repository.addTask(
        KosmosTask(
          id: 'eligible-active',
          title: 'Active task',
          createdAt: now,
          updatedAt: now.add(const Duration(minutes: 1)),
          intent: TaskIntent.pursuing,
          condition: TaskCondition.active,
        ),
      );

      repository.addTask(
        KosmosTask(
          id: 'excluded-blocked',
          title: 'Blocked task',
          createdAt: now,
          updatedAt: now.add(const Duration(minutes: 2)),
          intent: TaskIntent.pursuing,
          condition: TaskCondition.blocked,
        ),
      );

      repository.addTask(
        KosmosTask(
          id: 'excluded-parked',
          title: 'Parked task',
          createdAt: now,
          updatedAt: now.add(const Duration(minutes: 3)),
          intent: TaskIntent.parked,
          condition: TaskCondition.ready,
        ),
      );

      final assessment = repository.assessAttention();

      expect(assessment.totalCount, 4);
      expect(assessment.eligibleCount, 2);
      expect(assessment.excludedCount, 2);
      expect(
        assessment.eligibleAssessments.map((item) => item.task.id),
        containsAll(['eligible-ready', 'eligible-active']),
      );
      expect(
        assessment.excludedAssessments.map((item) => item.task.id),
        containsAll(['excluded-blocked', 'excluded-parked']),
      );
      expect(assessment.decision.task?.id, 'eligible-ready');
      expect(assessment.summary, '2 of 4 tasks are eligible for attention.');
    },
  );

  test('empty attention assessment reports no eligible tasks', () {
    final repository = KosmosRepository();

    final assessment = repository.assessAttention();

    expect(assessment.totalCount, 0);
    expect(assessment.eligibleCount, 0);
    expect(assessment.excludedCount, 0);
    expect(assessment.decision.hasSelection, isFalse);
    expect(assessment.summary, '0 of 0 tasks are eligible for attention.');
  });

  test('attention assessment does not change task state or history', () {
    final repository = KosmosRepository();
    final now = DateTime(2026, 1, 1);

    final task = KosmosTask(
      id: 'assessment-stability',
      title: 'Preserve task state',
      createdAt: now,
      updatedAt: now,
      intent: TaskIntent.pursuing,
      condition: TaskCondition.ready,
    );

    repository.addTask(task);

    final originalIntent = task.intent;
    final originalCondition = task.condition;
    final originalUpdatedAt = task.updatedAt;
    final originalHistoryLength = repository.historyFor(task.id).length;

    repository.assessAttention();

    expect(task.intent, originalIntent);
    expect(task.condition, originalCondition);
    expect(task.updatedAt, originalUpdatedAt);
    expect(repository.historyFor(task.id), hasLength(originalHistoryLength));
  });
}

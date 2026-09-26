import 'package:flutter_test/flutter_test.dart';
import 'package:kosmos/models/kosmos_event.dart';
import 'package:kosmos/models/kosmos_task.dart';
import 'package:kosmos/services/kosmos_repository.dart';

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
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kosmos/models/kosmos_task.dart';
import 'package:kosmos/models/kosmos_event.dart';
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
}

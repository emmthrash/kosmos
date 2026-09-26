import 'package:flutter_test/flutter_test.dart';
import 'package:kosmos/models/kosmos_task.dart';

void main() {
  test('creates a pursuing task in a ready condition', () {
    final now = DateTime.now();

    final task = KosmosTask(
      id: 'task-001',
      title: 'Learn Dart classes',
      createdAt: now,
      updatedAt: now,
    );

    expect(task.id, 'task-001');
    expect(task.title, 'Learn Dart classes');
    expect(task.intent, TaskIntent.pursuing);
    expect(task.condition, TaskCondition.ready);
    expect(task.progressType, ProgressType.none);
    expect(task.progress, isNull);
    expect(task.target, isNull);
  });
}

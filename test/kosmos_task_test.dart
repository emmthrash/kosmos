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

  test('copyWith changes selected fields and preserves the rest', () {
    final created = DateTime(2026, 10, 1);
    final updated = DateTime(2026, 10, 5);

    final original = KosmosTask(
      id: 'task-002',
      title: 'Learn Flutter',
      description: 'Build a small app',
      createdAt: created,
      updatedAt: updated,
      intent: TaskIntent.pursuing,
      condition: TaskCondition.ready,
      progressType: ProgressType.quantity,
      progress: 3,
      target: 10,
      notes: const ['Read the documentation'],
    );

    final changed = original.copyWith(
      condition: TaskCondition.active,
      updatedAt: DateTime(2026, 10, 6),
    );

    expect(changed.condition, TaskCondition.active);
    expect(changed.updatedAt, DateTime(2026, 10, 6));

    expect(changed.id, original.id);
    expect(changed.title, original.title);
    expect(changed.description, original.description);
    expect(changed.createdAt, original.createdAt);
    expect(changed.intent, original.intent);
    expect(changed.progressType, original.progressType);
    expect(changed.progress, original.progress);
    expect(changed.target, original.target);
    expect(changed.notes, original.notes);
  });
}

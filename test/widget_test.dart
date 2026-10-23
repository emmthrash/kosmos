import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kosmos/main.dart';
import 'package:kosmos/models/kosmos_task.dart';
import 'package:kosmos/services/kosmos_repository.dart';

void main() {
  testWidgets('attention screen shows the assessment dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(MyApp(repository: createDemoRepository()));

    expect(find.text('KOSMOS'), findsOneWidget);
    expect(find.text('CHECK'), findsOneWidget);
    expect(find.text('CHOOSE'), findsOneWidget);
    expect(find.text('METIS SUGGESTS'), findsOneWidget);
    expect(find.text('Build the KOSMOS attention screen'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('2 of 4 tasks are eligible for attention.'),
      250,
    );

    expect(
      find.text('2 of 4 tasks are eligible for attention.'),
      findsOneWidget,
    );

    final startButton = find.text('Start task');

    await tester.ensureVisible(startButton);
    expect(startButton, findsOneWidget);

    await tester.tap(startButton);
    await tester.pumpAndSettle();
  });

  testWidgets('empty repository shows the empty attention state', (
    tester,
  ) async {
    await tester.pumpWidget(MyApp(repository: KosmosRepository()));

    expect(find.text('Nothing to push right now.'), findsOneWidget);
    expect(
      find.text('0 of 0 tasks are eligible for attention.'),
      findsOneWidget,
    );
    expect(find.text('Start task'), findsNothing);
  });

  testWidgets('starting a ready task requires an explicit tap', (tester) async {
    final repository = KosmosRepository();
    final now = DateTime(2026, 1, 1);

    repository.addTask(
      KosmosTask(
        id: 'task-to-start',
        title: 'Test deliberate task start',
        createdAt: now,
        updatedAt: now,
        condition: TaskCondition.ready,
      ),
    );

    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MyApp(repository: repository));

    expect(
      repository.taskById('task-to-start')!.condition,
      TaskCondition.ready,
    );

    await tester.scrollUntilVisible(find.text('Start task'), 250);
    expect(find.text('Start task'), findsOneWidget);

    await tester.tap(find.text('Start task'));
    await tester.pumpAndSettle();

    expect(
      repository.taskById('task-to-start')!.condition,
      TaskCondition.active,
    );
    expect(find.text('Pause for now'), findsOneWidget);
    expect(repository.historyFor('task-to-start'), hasLength(2));
  });
}

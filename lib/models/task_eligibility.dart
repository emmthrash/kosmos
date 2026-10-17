import 'package:kosmos/models/kosmos_task.dart';

enum TaskEligibilityReason {
  eligibleReady,
  eligibleActive,
  intentNotPursuing,
  conditionNotActionable,
}

class TaskEligibility {
  const TaskEligibility({required this.task, required this.reason});

  final KosmosTask task;
  final TaskEligibilityReason reason;

  bool get isEligible {
    return reason == TaskEligibilityReason.eligibleReady ||
        reason == TaskEligibilityReason.eligibleActive;
  }

  String get explanation {
    switch (reason) {
      case TaskEligibilityReason.eligibleReady:
        return 'Task is pursuing and its condition is ready.';
      case TaskEligibilityReason.eligibleActive:
        return 'Task is pursuing and its condition is active.';
      case TaskEligibilityReason.intentNotPursuing:
        return 'Not eligible: task intent is ${task.intent.name}.';
      case TaskEligibilityReason.conditionNotActionable:
        return 'Not eligible: task condition is ${task.condition.name}.';
    }
  }

  factory TaskEligibility.evaluate(KosmosTask task) {
    // Intent is checked first so excluded tasks have a consistent explanation.
    if (task.intent != TaskIntent.pursuing) {
      return TaskEligibility(
        task: task,
        reason: TaskEligibilityReason.intentNotPursuing,
      );
    }

    switch (task.condition) {
      case TaskCondition.ready:
        return TaskEligibility(
          task: task,
          reason: TaskEligibilityReason.eligibleReady,
        );

      case TaskCondition.active:
        return TaskEligibility(
          task: task,
          reason: TaskEligibilityReason.eligibleActive,
        );

      case TaskCondition.waiting:
      case TaskCondition.blocked:
      case TaskCondition.unavailable:
        return TaskEligibility(
          task: task,
          reason: TaskEligibilityReason.conditionNotActionable,
        );
    }
  }
}

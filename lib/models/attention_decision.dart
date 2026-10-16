import 'package:kosmos/models/kosmos_task.dart';

enum AttentionDecisionReason { leastRecentlyUpdated, noEligibleTasks }

class AttentionDecision {
  const AttentionDecision({required this.task, required this.reason});

  final KosmosTask? task;
  final AttentionDecisionReason reason;

  bool get hasSelection => task != null;

  String get eligibilityExplanation {
    final selectedTask = task;

    if (selectedTask == null) {
      return 'No task meets the current attention eligibility rules.';
    }

    return 'Task is pursuing and its condition is '
        '${selectedTask.condition.name}.';
  }

  String get selectionExplanation {
    switch (reason) {
      case AttentionDecisionReason.leastRecentlyUpdated:
        return 'Chosen because it has the oldest last-updated timestamp '
            'among eligible tasks.';
      case AttentionDecisionReason.noEligibleTasks:
        return 'No selection was made because there are no eligible tasks.';
    }
  }

  String get explanation {
    if (!hasSelection) {
      return 'No eligible tasks need attention right now.';
    }

    return '$eligibilityExplanation $selectionExplanation';
  }
}

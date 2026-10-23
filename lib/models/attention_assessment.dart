import 'package:kosmos/models/attention_decision.dart';
import 'package:kosmos/models/task_eligibility.dart';

class AttentionAssessment {
  AttentionAssessment({
    required this.decision,
    required List<TaskEligibility> taskAssessments,
  }) : taskAssessments = List.unmodifiable(taskAssessments);

  final AttentionDecision decision;

  /// Eligibility results for every task in this assessment snapshot.
  final List<TaskEligibility> taskAssessments;

  List<TaskEligibility> get eligibleAssessments {
    return List.unmodifiable(
      taskAssessments.where((assessment) => assessment.isEligible),
    );
  }

  List<TaskEligibility> get excludedAssessments {
    return List.unmodifiable(
      taskAssessments.where((assessment) => !assessment.isEligible),
    );
  }

  /// Reuses the eligibility result already captured for the selected task.
  TaskEligibility? get selectedAssessment {
    final selectedTask = decision.task;

    if (selectedTask == null) {
      return null;
    }

    for (final assessment in taskAssessments) {
      if (assessment.task.id == selectedTask.id) {
        return assessment;
      }
    }

    return null;
  }

  int get totalCount => taskAssessments.length;

  int get eligibleCount => eligibleAssessments.length;

  int get excludedCount => excludedAssessments.length;

  String get summary {
    return '$eligibleCount of $totalCount tasks are eligible for attention.';
  }

  String get selectionExplanation => decision.selectionExplanation;

  /// Combines the summary, selected task's eligibility, and selection reason.
  String get explanation {
    final selected = selectedAssessment;

    if (selected == null) {
      return '$summary ${decision.explanation}';
    }

    return '$summary ${selected.explanation} $selectionExplanation';
  }
}

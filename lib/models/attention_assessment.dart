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

  int get totalCount => taskAssessments.length;

  int get eligibleCount => eligibleAssessments.length;

  int get excludedCount => excludedAssessments.length;

  String get summary {
    return '$eligibleCount of $totalCount tasks are eligible for attention.';
  }
}

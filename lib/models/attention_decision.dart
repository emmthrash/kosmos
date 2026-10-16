import 'package:kosmos/models/kosmos_task.dart';

enum AttentionDecisionReason { leastRecentlyUpdated, noEligibleTasks }

class AttentionDecision {
  const AttentionDecision({required this.task, required this.reason});

  final KosmosTask? task;
  final AttentionDecisionReason reason;

  bool get hasSelection => task != null;

  String get explanation {
    switch (reason) {
      case AttentionDecisionReason.leastRecentlyUpdated:
        return 'Selected because this is the least recently updated eligible task.';
      case AttentionDecisionReason.noEligibleTasks:
        return 'No eligible tasks need attention right now.';
    }
  }
}

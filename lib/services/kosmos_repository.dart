import '../models/kosmos_event.dart';
import '../models/kosmos_task.dart';

class KosmosRepository {
  final List<KosmosTask> _tasks = [];
  final List<KosmosEvent> _events = [];

  List<KosmosTask> get tasks => List.unmodifiable(_tasks);

  List<KosmosEvent> get events => List.unmodifiable(_events);

  void addTask(KosmosTask task) {
    _tasks.add(task);

    _events.add(
      KosmosEvent(
        id: 'event-${_events.length + 1}',
        taskId: task.id,
        type: KosmosEventType.created,
        timestamp: DateTime.now(),
        description: 'Task created',
      ),
    );
  }

  List<KosmosEvent> historyFor(String taskId) {
    return List.unmodifiable(
      _events.where((event) => event.taskId == taskId),
    );
  }
}

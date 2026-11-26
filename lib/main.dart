import 'package:flutter/material.dart';

import 'models/attention_assessment.dart';
import 'models/kosmos_task.dart';
import 'services/kosmos_repository.dart';

const _background = Color(0xFF0A0C0F);
const _panel = Color(0xFF13171D);
const _border = Color(0xFF29313B);
const _crimson = Color(0xFFE34B5F);
const _green = Color(0xFF65D6A0);
const _blue = Color(0xFF78AEFF);
const _muted = Color(0xFF929CAA);

void main() {
  runApp(MyApp(repository: createDemoRepository()));
}

/// Creates temporary local tasks so the first screen is useful immediately.
/// The repository is in-memory; these examples do not survive app restarts.
KosmosRepository createDemoRepository() {
  final repository = KosmosRepository();
  final now = DateTime.now();

  repository
    ..addTask(
      KosmosTask(
        id: 'build-attention-screen',
        title: 'Build the KOSMOS attention screen',
        description: 'Connect METIS to a clear, useful first interface.',
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 3)),
        condition: TaskCondition.ready,
      ),
    )
    ..addTask(
      KosmosTask(
        id: 'review-eligibility',
        title: 'Review task eligibility rules',
        description: 'Keep selection predictable and transparent.',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 1)),
        condition: TaskCondition.active,
      ),
    )
    ..addTask(
      KosmosTask(
        id: 'offline-storage',
        title: 'Plan offline storage',
        description: 'Choose a durable local storage approach.',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 4)),
        condition: TaskCondition.waiting,
      ),
    )
    ..addTask(
      KosmosTask(
        id: 'visual-identity',
        title: 'Explore the visual identity',
        description: 'Settle the visual language for KOSMOS.',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        intent: TaskIntent.parked,
      ),
    );

  return repository;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.repository});

  final KosmosRepository? repository;

  @override
  Widget build(BuildContext context) {
    const scheme = ColorScheme.dark(
      primary: _crimson,
      secondary: _green,
      surface: _panel,
      error: Color(0xFFFF7777),
      onPrimary: Colors.white,
      onSecondary: _background,
      onSurface: Color(0xFFF1F3F6),
      onError: Colors.black,
    );

    return MaterialApp(
      title: 'KOSMOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: scheme,
        scaffoldBackgroundColor: _background,
        dividerColor: _border,
        appBarTheme: const AppBarTheme(
          backgroundColor: _background,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: _panel,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: _border),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _crimson,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFE3E7ED),
            side: const BorderSide(color: _border),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: AttentionScreen(repository: repository ?? createDemoRepository()),
    );
  }
}

class AttentionScreen extends StatefulWidget {
  const AttentionScreen({super.key, required this.repository});

  final KosmosRepository repository;

  @override
  State<AttentionScreen> createState() => _AttentionScreenState();
}

class _AttentionScreenState extends State<AttentionScreen> {
  Future<void> _createTask() async {
    final newTask = await showDialog<KosmosTask>(
      context: context,
      builder: (_) => const _CreateTaskDialog(),
    );

    if (!mounted || newTask == null) return;

    widget.repository.addTask(newTask);
    setState(() {});
  }

  void _startTask(String taskId) {
    widget.repository.startTask(taskId);
    setState(() {});
  }

  void _pauseTask(String taskId) {
    widget.repository.pauseTask(taskId);
    setState(() {});
  }

  void _parkTask(String taskId) {
    widget.repository.parkTask(taskId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final assessment = widget.repository.assessAttention();
    final selected = assessment.selectedAssessment;
    final selectedTask = selected?.task;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
              children: [
                _Header(totalTasks: assessment.totalCount),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    key: const Key('create-task-button'),
                    onPressed: _createTask,
                    icon: const Icon(Icons.add),
                    label: const Text('Create task'),
                  ),
                ),
                const SizedBox(height: 32),
                const _SectionLabel(number: '01', label: 'CHECK'),
                const SizedBox(height: 12),
                Text(
                  'See where things stand.',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _StatTile(
                      label: 'TOTAL TASKS',
                      value: '${assessment.totalCount}',
                      color: Colors.white,
                      icon: Icons.layers_outlined,
                    ),
                    _StatTile(
                      label: 'ELIGIBLE',
                      value: '${assessment.eligibleCount}',
                      color: _green,
                      icon: Icons.radio_button_checked,
                    ),
                    _StatTile(
                      label: 'EXCLUDED',
                      value: '${assessment.excludedCount}',
                      color: _muted,
                      icon: Icons.remove_circle_outline,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${assessment.eligibleCount} of ${assessment.totalCount} '
                  'tasks are eligible for attention.',
                  key: const Key('attention-count-summary'),
                  style: const TextStyle(color: _muted),
                ),
                const SizedBox(height: 32),
                const _SectionLabel(number: '02', label: 'CHOOSE'),
                const SizedBox(height: 12),
                if (selectedTask == null)
                  const _EmptyAttention()
                else
                  _SelectedTaskCard(
                    task: selectedTask,
                    eligibilityExplanation: selected!.explanation,
                    selectionExplanation: assessment.selectionExplanation,
                    onStart: selectedTask.condition == TaskCondition.ready
                        ? () => _startTask(selectedTask.id)
                        : null,
                    onPause: selectedTask.condition == TaskCondition.active
                        ? () => _pauseTask(selectedTask.id)
                        : null,
                    onPark: () => _parkTask(selectedTask.id),
                  ),
                const SizedBox(height: 28),
                const _SectionLabel(number: '03', label: 'ASSESSMENT'),
                const SizedBox(height: 12),
                _AssessmentList(assessment: assessment),
                const SizedBox(height: 24),
                const _HumanControlNote(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.totalTasks});

  final int totalTasks;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _crimson.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _crimson.withValues(alpha: 0.45)),
          ),
          child: const Icon(Icons.blur_on, color: _crimson, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KOSMOS',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 2.8),
              ),
              const SizedBox(height: 2),
              const Text(
                'PERSONAL OPERATING SPACE',
                style: TextStyle(
                  color: _muted,
                  fontSize: 10,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: _green.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _green.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, color: _green, size: 7),
              SizedBox(width: 7),
              Text(
                'LOCAL',
                style: TextStyle(
                  color: _green,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          number,
          style: const TextStyle(
            color: _crimson,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: _muted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 9,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedTaskCard extends StatelessWidget {
  const _SelectedTaskCard({
    required this.task,
    required this.eligibilityExplanation,
    required this.selectionExplanation,
    required this.onStart,
    required this.onPause,
    required this.onPark,
  });

  final KosmosTask task;
  final String eligibilityExplanation;
  final String selectionExplanation;
  final VoidCallback? onStart;
  final VoidCallback? onPause;
  final VoidCallback onPark;

  @override
  Widget build(BuildContext context) {
    final isActive = task.condition == TaskCondition.active;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, color: _crimson, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'METIS SUGGESTS',
                    style: TextStyle(
                      color: _crimson,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                _StatusPill(
                  label: task.condition.name.toUpperCase(),
                  color: isActive ? _blue : _green,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              task.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.15,
                letterSpacing: -0.6,
              ),
            ),
            if (task.description != null) ...[
              const SizedBox(height: 10),
              Text(
                task.description!,
                style: const TextStyle(color: _muted, height: 1.5),
              ),
            ],
            const SizedBox(height: 22),
            const Divider(),
            const SizedBox(height: 14),
            const Text(
              'WHY IT QUALIFIES',
              style: TextStyle(
                color: _green,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              eligibilityExplanation,
              style: const TextStyle(height: 1.45, color: Color(0xFFD1D7DF)),
            ),
            const SizedBox(height: 18),
            const Text(
              'WHY THIS TASK',
              style: TextStyle(
                color: _blue,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              selectionExplanation,
              style: const TextStyle(height: 1.45, color: Color(0xFFD1D7DF)),
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (onStart != null)
                  FilledButton.icon(
                    onPressed: onStart,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start task'),
                  ),
                if (onPause != null)
                  OutlinedButton.icon(
                    onPressed: onPause,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause for now'),
                  ),
                OutlinedButton.icon(
                  onPressed: onPark,
                  icon: const Icon(Icons.archive_outlined),
                  label: const Text('Park task'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Actions change task state only when you choose them.',
              style: TextStyle(color: _muted, fontSize: 11, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAttention extends StatelessWidget {
  const _EmptyAttention();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.spa_outlined, color: _green, size: 32),
            const SizedBox(height: 18),
            Text(
              'Nothing to push right now.',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'No task currently meets the attention rules. '
              'That is information, not a failure.',
              style: TextStyle(color: _muted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssessmentList extends StatelessWidget {
  const _AssessmentList({required this.assessment});

  final AttentionAssessment assessment;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              assessment.summary,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Eligibility is based on intent and condition. '
              'Selection uses the oldest update timestamp, then task ID.',
              style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
            ),
            if (assessment.taskAssessments.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 6),
              for (final item in assessment.taskAssessments)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        item.isEligible
                            ? Icons.check_circle_outline
                            : Icons.remove_circle_outline,
                        color: item.isEligible ? _green : _muted,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.task.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.explanation,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _CreateTaskDialog extends StatefulWidget {
  const _CreateTaskDialog();

  @override
  State<_CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<_CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    final task = KosmosTask(
      id: 'task-${now.microsecondsSinceEpoch}',
      title: title,
      description: description.isEmpty ? null : description,
      createdAt: now,
      updatedAt: now,
    );

    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create task'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key: const Key('task-title-field'),
                  controller: _titleController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Task title',
                    hintText: 'What do you want to do?',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a task title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('task-description-field'),
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Add context if useful',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('confirm-create-task'),
          onPressed: _submit,
          child: const Text('Create task'),
        ),
      ],
    );
  }
}

class _HumanControlNote extends StatelessWidget {
  const _HumanControlNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _blue.withValues(alpha: 0.18)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.visibility_outlined, color: _blue, size: 19),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'METIS observes and explains. You decide what matters. '
              'A recommendation is never an obligation.',
              style: TextStyle(color: Color(0xFFB8C8DE), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

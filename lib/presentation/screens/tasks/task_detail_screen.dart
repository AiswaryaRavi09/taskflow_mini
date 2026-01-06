import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/subtask.dart';
import '../../blocs/task/task_bloc.dart';
import '../../widgets/task/status_chip.dart';
import 'package:uuid/uuid.dart';

class TaskDetailScreen extends StatefulWidget {
  final String projectId;
  final String taskId;

  const TaskDetailScreen({
    super.key,
    required this.projectId,
    required this.taskId,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  Task? _task;

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks(widget.projectId));
    context.read<TaskBloc>().add(LoadSubtasks(widget.taskId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await context.push(
                '/projects/${widget.projectId}/tasks/${widget.taskId}/edit',
              );
              // Reload tasks after returning from edit
              if (mounted) {
                context.read<TaskBloc>().add(LoadTasks(widget.projectId));
                context.read<TaskBloc>().add(LoadSubtasks(widget.taskId));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoaded) {
            _task = state.tasks.where((t) => t.id == widget.taskId).firstOrNull;
            if (_task == null) {
              return const Center(child: Text('Task not found'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildInfoSection(),
                  const SizedBox(height: 24),
                  _buildStatusSection(),
                  const SizedBox(height: 24),
                  _buildSubtasksSection(state.subtasks),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _task!.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _task!.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              Icons.flag,
              'Priority',
              _task!.priority.name.toUpperCase(),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.calendar_today,
              'Due Date',
              _task!.dueDate != null
                  ? DateFormat('MMM dd, yyyy').format(_task!.dueDate!)
                  : 'Not set',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.access_time,
              'Time',
              '${_task!.timeSpentHours}h / ${_task!.estimateHours}h',
            ),
            if (_task!.labels.isNotEmpty) ...[
              const Divider(height: 24),
              _buildLabels(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(value),
      ],
    );
  }

  Widget _buildLabels() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.label, size: 20),
            SizedBox(width: 12),
            Text('Labels', style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _task!.labels.map((label) {
            return Chip(
              label: Text(label),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskStatus.values.map((status) {
                final isSelected = _task!.status == status;
                return ChoiceChip(
                  label: Text(status.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      final updated = _task!.copyWith(status: status);
                      context.read<TaskBloc>().add(UpdateTask(updated));
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtasksSection(List<Subtask> subtasks) {
    final taskSubtasks = subtasks.where((s) => s.taskId == widget.taskId).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtasks',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddSubtaskDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            if (taskSubtasks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text('No subtasks yet'),
                ),
              )
            else
              ...taskSubtasks.map((subtask) {
                return CheckboxListTile(
                  title: Text(subtask.title),
                  value: subtask.completed,
                  onChanged: (value) {
                    final updated = subtask.copyWith(completed: value);
                    context.read<TaskBloc>().add(UpdateSubtask(updated));
                  },
                  contentPadding: EdgeInsets.zero,
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showAddSubtaskDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Subtask'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Subtask Title',
            hintText: 'Enter subtask title',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final subtask = Subtask(
                  id: const Uuid().v4(),
                  taskId: widget.taskId,
                  title: controller.text,
                );
                context.read<TaskBloc>().add(CreateSubtask(subtask));
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TaskBloc>().add(DeleteTask(widget.taskId));
              Navigator.pop(dialogContext);
              context.pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
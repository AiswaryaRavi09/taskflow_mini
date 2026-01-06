import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task.dart';
import 'status_chip.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildPriorityBadge(context),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusChip(status: task.status),
                  if (task.dueDate != null) _buildDueDateChip(context),
                  if (task.isOverdue) _buildOverdueChip(context),
                  ...task.labels.take(2).map((label) => Chip(
                    label: Text(label),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(BuildContext context) {
    Color color;
    switch (task.priority) {
      case Priority.critical:
        color = Colors.red;
        break;
      case Priority.high:
        color = Colors.orange;
        break;
      case Priority.medium:
        color = Colors.blue;
        break;
      case Priority.low:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        task.priority.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDueDateChip(BuildContext context) {
    return Chip(
      avatar: Icon(
        Icons.calendar_today,
        size: 16,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: Text(DateFormat('MMM dd').format(task.dueDate!)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildOverdueChip(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.warning, size: 16, color: Colors.red),
      label: const Text('Overdue'),
      backgroundColor: Colors.red.withOpacity(0.1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
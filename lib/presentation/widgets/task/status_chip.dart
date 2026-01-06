import 'package:flutter/material.dart';
import '../../../domain/entities/task.dart';

class StatusChip extends StatelessWidget {
  final TaskStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Chip(
      avatar: Icon(config.icon, size: 16, color: config.color),
      label: Text(config.label),
      backgroundColor: config.color.withOpacity(0.1),
      side: BorderSide(color: config.color),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  _StatusConfig _getStatusConfig(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return _StatusConfig(
          label: 'To Do',
          icon: Icons.radio_button_unchecked,
          color: Colors.grey,
        );
      case TaskStatus.inProgress:
        return _StatusConfig(
          label: 'In Progress',
          icon: Icons.play_circle_outline,
          color: Colors.blue,
        );
      case TaskStatus.blocked:
        return _StatusConfig(
          label: 'Blocked',
          icon: Icons.block,
          color: Colors.red,
        );
      case TaskStatus.inReview:
        return _StatusConfig(
          label: 'In Review',
          icon: Icons.rate_review_outlined,
          color: Colors.orange,
        );
      case TaskStatus.done:
        return _StatusConfig(
          label: 'Done',
          icon: Icons.check_circle,
          color: Colors.green,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final IconData icon;
  final Color color;

  _StatusConfig({
    required this.label,
    required this.icon,
    required this.color,
  });
}
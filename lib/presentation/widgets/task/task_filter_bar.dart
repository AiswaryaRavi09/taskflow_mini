import 'package:flutter/material.dart';
import '../../../domain/entities/task.dart';

class TaskFilterBar extends StatefulWidget {
  final Function(TaskStatus?) onStatusChanged;
  final Function(Priority?) onPriorityChanged;
  final Function(String) onSearchChanged;

  const TaskFilterBar({
    super.key,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onSearchChanged,
  });

  @override
  State<TaskFilterBar> createState() => _TaskFilterBarState();
}

class _TaskFilterBarState extends State<TaskFilterBar> {
  TaskStatus? _selectedStatus;
  Priority? _selectedPriority;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  widget.onSearchChanged('');
                  setState(() {});
                },
              )
                  : null,
              isDense: true,
            ),
            onChanged: (value) {
              widget.onSearchChanged(value);
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<TaskStatus?>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All'),
                    ),
                    ...TaskStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
                    widget.onStatusChanged(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<Priority?>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All'),
                    ),
                    ...Priority.values.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedPriority = value);
                    widget.onPriorityChanged(value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
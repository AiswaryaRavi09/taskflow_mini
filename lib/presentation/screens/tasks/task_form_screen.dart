import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task.dart';
import '../../blocs/task/task_bloc.dart';

class TaskFormScreen extends StatefulWidget {
  final String projectId;
  final String? taskId;

  const TaskFormScreen({
    super.key,
    required this.projectId,
    this.taskId,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TaskStatus _status = TaskStatus.todo;
  Priority _priority = Priority.medium;
  DateTime? _dueDate;
  num _estimateHours = 0;
  num _timeSpentHours = 0;
  List<String> _labels = [];
  List<String> _assigneeIds = [];
  DateTime? _startDate;

  bool _isLoading = true;
  Task? _existingTask;

  @override
  void initState() {
    super.initState();
    if (widget.taskId != null) {
      _loadTaskData();
    } else {
      _isLoading = false;
    }
  }

  void _loadTaskData() {
    // Load tasks first if not already loaded
    final taskBloc = context.read<TaskBloc>();
    final currentState = taskBloc.state;

    if (currentState is TaskLoaded) {
      _populateTaskData(currentState.tasks);
    } else {
      // Load tasks if not loaded
      taskBloc.add(LoadTasks(widget.projectId));
    }
  }

  void _populateTaskData(List<Task> tasks) {
    _existingTask = tasks.firstWhere(
          (t) => t.id == widget.taskId,
      orElse: () => Task(
        id: widget.taskId!,
        projectId: widget.projectId,
        title: '',
        description: '',
        createdAt: DateTime.now(),
      ),
    );

    if (_existingTask != null) {
      setState(() {
        _titleController.text = _existingTask!.title;
        _descriptionController.text = _existingTask!.description;
        _status = _existingTask!.status;
        _priority = _existingTask!.priority;
        _dueDate = _existingTask!.dueDate;
        _startDate = _existingTask!.startDate;
        _estimateHours = _existingTask!.estimateHours;
        _timeSpentHours = _existingTask!.timeSpentHours;
        _labels = List.from(_existingTask!.labels);
        _assigneeIds = List.from(_existingTask!.assigneeIds);
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskId == null ? 'Create Task' : 'Edit Task'),
      ),
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskLoaded && _isLoading && widget.taskId != null) {
            _populateTaskData(state.tasks);
          }
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter task title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter task description',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskStatus>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: TaskStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Priority>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: Priority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _priority = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Due Date'),
                subtitle: Text(
                  _dueDate != null
                      ? DateFormat('MMM dd, yyyy').format(_dueDate!)
                      : 'Not set',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDueDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _estimateHours.toString(),
                decoration: const InputDecoration(
                  labelText: 'Estimated Hours',
                  suffixText: 'hours',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _estimateHours = double.tryParse(value) ?? 0;
                },
              ),
              if (widget.taskId != null) ...[
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _timeSpentHours.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Time Spent',
                    suffixText: 'hours',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _timeSpentHours = double.tryParse(value) ?? 0;
                  },
                ),
              ],
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _saveTask,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                      widget.taskId == null ? 'Create Task' : 'Update Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _dueDate = date);
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: widget.taskId ?? const Uuid().v4(),
        projectId: widget.projectId,
        title: _titleController.text,
        description: _descriptionController.text,
        status: _status,
        priority: _priority,
        dueDate: _dueDate,
        startDate: _startDate,
        estimateHours: _estimateHours,
        timeSpentHours: _timeSpentHours,
        labels: _labels,
        assigneeIds: _assigneeIds,
        createdAt: _existingTask?.createdAt ?? DateTime.now(),
      );

      if (widget.taskId == null) {
        context.read<TaskBloc>().add(CreateTask(task));
      } else {
        context.read<TaskBloc>().add(UpdateTask(task));
      }

      context.pop();
    }
  }
}
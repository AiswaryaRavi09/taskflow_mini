import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/task.dart';
import '../../blocs/task/task_bloc.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_skeleton.dart';
import '../../widgets/task/task_card.dart';
import '../../widgets/task/task_filter_bar.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  TaskStatus? _filterStatus;
  Priority? _filterPriority;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    context.read<TaskBloc>().add(LoadTasks(widget.projectId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),  // ADD REFRESH BUTTON
            onPressed: _loadTasks,
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              context.push('/projects/${widget.projectId}/report');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TaskFilterBar(
            onStatusChanged: (status) {
              setState(() => _filterStatus = status);
            },
            onPriorityChanged: (priority) {
              setState(() => _filterPriority = priority);
            },
            onSearchChanged: (query) {
              setState(() => _searchQuery = query);
            },
          ),
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 5,
                    itemBuilder: (context, index) => const LoadingSkeleton(
                      height: 100,
                      margin: EdgeInsets.only(bottom: 12),
                    ),
                  );
                }

                if (state is TaskLoaded) {
                  var tasks = state.tasks;

                  // Apply filters
                  if (_filterStatus != null) {
                    tasks = tasks.where((t) => t.status == _filterStatus).toList();
                  }
                  if (_filterPriority != null) {
                    tasks = tasks.where((t) => t.priority == _filterPriority).toList();
                  }
                  if (_searchQuery.isNotEmpty) {
                    tasks = tasks.where((t) =>
                    t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        t.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                  }

                  if (tasks.isEmpty) {
                    return EmptyState(
                      icon: Icons.task_alt,
                      title: 'No tasks found',
                      message: _searchQuery.isEmpty && _filterStatus == null && _filterPriority == null
                          ? 'Create a new task to get started'
                          : 'No tasks match your filters',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () async {
                          await context.push(
                            '/projects/${widget.projectId}/tasks/${task.id}',
                          );
                          // Reload when returning
                          if (mounted) {
                            _loadTasks();
                          }
                        },
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/projects/${widget.projectId}/tasks/new');
          // Reload tasks when returning from task creation
          if (mounted) {
            _loadTasks();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
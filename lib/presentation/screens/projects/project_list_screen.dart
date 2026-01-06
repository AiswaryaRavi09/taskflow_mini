import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/project/project_bloc.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../widgets/common/loading_skeleton.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/project/project_card.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects',style: TextStyle(color: Colors.blue,),),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              context.read<ThemeBloc>().add(ToggleTheme());
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(_showArchived ? Icons.visibility_off : Icons.archive),
                    const SizedBox(width: 8),
                    Text(_showArchived ? 'Hide Archived' : 'Show Archived'),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _showArchived = !_showArchived;
                  });
                  context.read<ProjectBloc>().add(
                    LoadProjects(includeArchived: _showArchived),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (context, state) {
          if (state is ProjectLoading) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (context, index) => const LoadingSkeleton(
                height: 120,
                margin: EdgeInsets.only(bottom: 16),
              ),
            );
          }

          if (state is ProjectError) {
            return ErrorState(
              message: state.message,
              onRetry: () {
                context.read<ProjectBloc>().add(LoadProjects());
              },
            );
          }

          if (state is ProjectLoaded) {
            if (state.projects.isEmpty) {
              return EmptyState(
                icon: Icons.folder_open,
                title: _showArchived ? 'No archived projects' : 'No projects yet',
                message: _showArchived
                    ? 'Archive projects to see them here'
                    : 'Create your first project to get started',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.projects.length,
              itemBuilder: (context, index) {
                final project = state.projects[index];
                return ProjectCard(
                  project: project,
                  onTap: () {
                    context.push('/projects/${project.id}');
                  },
                  onArchive: () {
                    context.read<ProjectBloc>().add(
                      ArchiveProject(project.id),
                    );
                  },
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateProjectDialog(context),
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),

    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                hintText: 'Enter project name',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter project description',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<ProjectBloc>().add(
                  CreateProject(
                    nameController.text,
                    descriptionController.text,
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
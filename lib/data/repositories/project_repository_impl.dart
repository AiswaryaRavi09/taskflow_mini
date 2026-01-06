import 'package:uuid/uuid.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/local/hive_data_source.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final HiveDataSource dataSource;
  final _uuid = const Uuid();

  ProjectRepositoryImpl(this.dataSource);

  @override
  Future<List<Project>> fetchProjects({bool includeArchived = false}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final projects = dataSource.projectsBox.values.toList();
    if (includeArchived) {
      return projects;
    }
    return projects.where((p) => !p.archived).toList();
  }

  @override
  Future<Project?> getProjectById(String id) async {
    return dataSource.projectsBox.get(id);
  }

  @override
  Future<Project> createProject(String name, String description) async {
    final newProject = Project(
      id: _uuid.v4(),
      name: name,
      description: description,
      archived: false,
      createdAt: DateTime.now(),
    );
    await dataSource.projectsBox.put(newProject.id, newProject);
    return newProject;
  }

  @override
  Future<Project> updateProject(Project project) async {
    await dataSource.projectsBox.put(project.id, project);
    return project;
  }

  @override
  Future<void> archiveProject(String id) async {
    final project = await getProjectById(id);
    if (project != null) {
      final updated = project.copyWith(archived: true);
      await updateProject(updated);
    }
  }
}
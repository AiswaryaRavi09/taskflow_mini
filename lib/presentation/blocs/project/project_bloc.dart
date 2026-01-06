import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/repositories/project_repository.dart';

// Events
abstract class ProjectEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProjects extends ProjectEvent {
  final bool includeArchived;
  LoadProjects({this.includeArchived = false});

  @override
  List<Object?> get props => [includeArchived];
}

class CreateProject extends ProjectEvent {
  final String name;
  final String description;

  CreateProject(this.name, this.description);

  @override
  List<Object?> get props => [name, description];
}

class ArchiveProject extends ProjectEvent {
  final String projectId;

  ArchiveProject(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

// States
abstract class ProjectState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectLoaded extends ProjectState {
  final List<Project> projects;

  ProjectLoaded(this.projects);

  @override
  List<Object?> get props => [projects];
}

class ProjectError extends ProjectState {
  final String message;

  ProjectError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepository repository;

  ProjectBloc(this.repository) : super(ProjectInitial()) {
    on<LoadProjects>(_onLoadProjects);
    on<CreateProject>(_onCreateProject);
    on<ArchiveProject>(_onArchiveProject);
  }

  Future<void> _onLoadProjects(
      LoadProjects event,
      Emitter<ProjectState> emit,
      ) async {
    emit(ProjectLoading());
    try {
      final projects = await repository.fetchProjects(
        includeArchived: event.includeArchived,
      );
      emit(ProjectLoaded(projects));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onCreateProject(
      CreateProject event,
      Emitter<ProjectState> emit,
      ) async {
    try {
      await repository.createProject(event.name, event.description);
      add(LoadProjects());
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onArchiveProject(
      ArchiveProject event,
      Emitter<ProjectState> emit,
      ) async {
    try {
      await repository.archiveProject(event.projectId);
      add(LoadProjects());
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }
}
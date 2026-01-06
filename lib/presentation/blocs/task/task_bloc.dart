import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/subtask.dart';
import '../../../domain/repositories/task_repository.dart';

// Events
abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  final String projectId;

  LoadTasks(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class CreateTask extends TaskEvent {
  final Task task;

  CreateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTask extends TaskEvent {
  final Task task;

  UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;

  DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class LoadSubtasks extends TaskEvent {
  final String taskId;

  LoadSubtasks(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class CreateSubtask extends TaskEvent {
  final Subtask subtask;

  CreateSubtask(this.subtask);

  @override
  List<Object?> get props => [subtask];
}

class UpdateSubtask extends TaskEvent {
  final Subtask subtask;

  UpdateSubtask(this.subtask);

  @override
  List<Object?> get props => [subtask];
}

// States
abstract class TaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final List<Subtask> subtasks;

  TaskLoaded(this.tasks, {this.subtasks = const []});

  @override
  List<Object?> get props => [tasks, subtasks];
}

class TaskError extends TaskState {
  final String message;

  TaskError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;
  String? _currentProjectId;

  TaskBloc(this.repository) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<LoadSubtasks>(_onLoadSubtasks);
    on<CreateSubtask>(_onCreateSubtask);
    on<UpdateSubtask>(_onUpdateSubtask);
  }

  Future<void> _onLoadTasks(
      LoadTasks event,
      Emitter<TaskState> emit,
      ) async {
    emit(TaskLoading());
    try {
      _currentProjectId = event.projectId;
      final tasks = await repository.fetchTasksByProject(event.projectId);
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

// In task_bloc.dart - CreateTask handler
  Future<void> _onCreateTask(
      CreateTask event,
      Emitter<TaskState> emit,
      ) async {
    try {
      print('Creating task: ${event.task.title}'); // ADD THIS
      await repository.createTask(event.task);
      print('Task created successfully'); // ADD THIS
      if (_currentProjectId != null) {
        add(LoadTasks(_currentProjectId!));
      }
    } catch (e) {
      print('Error creating task: $e'); // ADD THIS
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onUpdateTask(
      UpdateTask event,
      Emitter<TaskState> emit,
      ) async {
    try {
      await repository.updateTask(event.task);
      if (_currentProjectId != null) {
        add(LoadTasks(_currentProjectId!));
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onDeleteTask(
      DeleteTask event,
      Emitter<TaskState> emit,
      ) async {
    try {
      await repository.deleteTask(event.taskId);
      if (_currentProjectId != null) {
        add(LoadTasks(_currentProjectId!));
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onLoadSubtasks(
      LoadSubtasks event,
      Emitter<TaskState> emit,
      ) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      try {
        final subtasks = await repository.fetchSubtasksByTask(event.taskId);
        emit(TaskLoaded(currentState.tasks, subtasks: subtasks));
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    }
  }

  Future<void> _onCreateSubtask(
      CreateSubtask event,
      Emitter<TaskState> emit,
      ) async {
    try {
      await repository.createSubtask(event.subtask);
      add(LoadSubtasks(event.subtask.taskId));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onUpdateSubtask(
      UpdateSubtask event,
      Emitter<TaskState> emit,
      ) async {
    try {
      await repository.updateSubtask(event.subtask);
      add(LoadSubtasks(event.subtask.taskId));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
}
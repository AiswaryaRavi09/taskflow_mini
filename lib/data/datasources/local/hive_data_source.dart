import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/subtask.dart';
import '../../../domain/entities/user.dart';

class HiveDataSource {
  static const String _usersBoxName = 'users';
  static const String _projectsBoxName = 'projects';
  static const String _tasksBoxName = 'tasks';
  static const String _subtasksBoxName = 'subtasks';

  // Public boxes
  Box<User> get usersBox => Hive.box<User>(_usersBoxName);
  Box<Project> get projectsBox => Hive.box<Project>(_projectsBoxName);
  Box<Task> get tasksBox => Hive.box<Task>(_tasksBoxName);
  Box<Subtask> get subtasksBox => Hive.box<Subtask>(_subtasksBoxName);

  Future<void> init() async {
    // Open boxes
    await Hive.openBox<User>(_usersBoxName);
    await Hive.openBox<Project>(_projectsBoxName);
    await Hive.openBox<Task>(_tasksBoxName);
    await Hive.openBox<Subtask>(_subtasksBoxName);

    // Seed data if boxes are empty
    await _seedUsers();
    await _seedProjects();
    await _seedTasks();
    await _seedSubtasks();
  }

  Future<void> _seedUsers() async {
    if (usersBox.isEmpty) {
      final jsonString = await rootBundle.loadString('assets/data/seed_data.json');
      final data = json.decode(jsonString);
      final users = (data['users'] as List).map((json) {
        final role = UserRole.values.firstWhere((e) => e.name == json['role']);
        return User(
          id: json['id'],
          name: json['name'],
          email: json['email'],
          role: role,
        );
      }).toList();

      for (final user in users) {
        await usersBox.put(user.id, user);
      }
    }
  }

  Future<void> _seedProjects() async {
    if (projectsBox.isEmpty) {
      final jsonString = await rootBundle.loadString('assets/data/seed_data.json');
      final data = json.decode(jsonString);
      final projects = (data['projects'] as List).map((json) {
        return Project(
          id: json['id'],
          name: json['name'],
          description: json['description'],
          archived: json['archived'],
          createdAt: DateTime.parse(json['createdAt']),
        );
      }).toList();

      for (final project in projects) {
        await projectsBox.put(project.id, project);
      }
    }
  }

  Future<void> _seedTasks() async {
    if (tasksBox.isEmpty) {
      final jsonString = await rootBundle.loadString('assets/data/seed_data.json');
      final data = json.decode(jsonString);
      final tasks = (data['tasks'] as List).map((json) {
        return Task(
          id: json['id'],
          projectId: json['projectId'],
          title: json['title'],
          description: json['description'],
          status: TaskStatus.values.firstWhere((e) => e.name == json['status']),
          priority: Priority.values.firstWhere((e) => e.name == json['priority']),
          startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
          dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
          estimateHours: json['estimateHours'],
          timeSpentHours: json['timeSpentHours'],
          labels: List<String>.from(json['labels']),
          assigneeIds: List<String>.from(json['assigneeIds']),
          createdAt: DateTime.parse(json['createdAt']),
        );
      }).toList();

      for (final task in tasks) {
        await tasksBox.put(task.id, task);
      }
    }
  }

  Future<void> _seedSubtasks() async {
    if (subtasksBox.isEmpty) {
      final jsonString = await rootBundle.loadString('assets/data/seed_data.json');
      final data = json.decode(jsonString);
      final subtasks = (data['subtasks'] as List).map((json) {
        return Subtask(
          id: json['id'],
          taskId: json['taskId'],
          title: json['title'],
          completed: json['completed'],
          assigneeId: json['assigneeId'],
        );
      }).toList();

      for (final subtask in subtasks) {
        await subtasksBox.put(subtask.id, subtask);
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/projects/project_list_screen.dart';
import '../../presentation/screens/projects/project_detail_screen.dart';
import '../../presentation/screens/tasks/task_detail_screen.dart';
import '../../presentation/screens/tasks/task_form_screen.dart';
import '../../presentation/screens/reports/project_report_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const ProjectListScreen(),
      ),
      GoRoute(
        path: '/projects/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProjectDetailScreen(projectId: id);
        },
      ),
      GoRoute(
        path: '/projects/:projectId/tasks/:taskId',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          final taskId = state.pathParameters['taskId']!;
          return TaskDetailScreen(
            projectId: projectId,
            taskId: taskId,
          );
        },
      ),
      GoRoute(
        path: '/projects/:projectId/tasks/new',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return TaskFormScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: '/projects/:projectId/tasks/:taskId/edit',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          final taskId = state.pathParameters['taskId']!;
          return TaskFormScreen(
            projectId: projectId,
            taskId: taskId,
          );
        },
      ),
      GoRoute(
        path: '/projects/:id/report',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProjectReportScreen(projectId: id);
        },
      ),
    ],
  );
}
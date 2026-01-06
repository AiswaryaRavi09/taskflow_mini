import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/project_repository_impl.dart';
import 'data/repositories/task_repository_impl.dart';
import 'data/repositories/report_repository_impl.dart';
import 'data/datasources/local/hive_data_source.dart';
import 'domain/entities/project.dart';
import 'domain/entities/task.dart';
import 'domain/entities/subtask.dart';
import 'domain/entities/user.dart';
import 'presentation/blocs/project/project_bloc.dart';
import 'presentation/blocs/task/task_bloc.dart';
import 'presentation/blocs/report/report_bloc.dart';
import 'presentation/blocs/theme/theme_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  // Register adapters
  Hive.registerAdapter(ProjectAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TaskStatusAdapter());
  Hive.registerAdapter(PriorityAdapter());
  Hive.registerAdapter(SubtaskAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(UserRoleAdapter());

  // Initialize data source
  final dataSource = HiveDataSource();
  await dataSource.init();

  runApp(TaskFlowApp(dataSource: dataSource));
}

class TaskFlowApp extends StatelessWidget {
  final HiveDataSource dataSource;
  const TaskFlowApp({super.key, required this.dataSource});

  @override
  Widget build(BuildContext context) {
    // Initialize repositories
    final projectRepository = ProjectRepositoryImpl(dataSource);
    final taskRepository = TaskRepositoryImpl(dataSource);
    final reportRepository = ReportRepositoryImpl(dataSource);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: projectRepository),
        RepositoryProvider.value(value: taskRepository),
        RepositoryProvider.value(value: reportRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ThemeBloc(),
          ),
          BlocProvider(
            create: (context) => ProjectBloc(projectRepository)
              ..add(LoadProjects()),
          ),
          BlocProvider(
            create: (context) => TaskBloc(taskRepository),
          ),
          BlocProvider(
            create: (context) => ReportBloc(reportRepository),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return MaterialApp.router(
              title: 'TaskFlow Mini',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: state.themeMode,
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }
}
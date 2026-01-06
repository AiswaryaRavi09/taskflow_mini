import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/report/report_bloc.dart';
import '../../widgets/report/status_tile.dart';
import '../../widgets/common/loading_skeleton.dart';

class ProjectReportScreen extends StatefulWidget {
  final String projectId;

  const ProjectReportScreen({super.key, required this.projectId});

  @override
  State<ProjectReportScreen> createState() => _ProjectReportScreenState();
}

class _ProjectReportScreenState extends State<ProjectReportScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReportBloc>().add(LoadReport(widget.projectId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Report'),
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading) {
            return GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: List.generate(
                6,
                    (_) => const LoadingSkeleton(height: 100),
              ),
            );
          }

          if (state is ReportLoaded) {
            final report = state.report;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      StatusTile(
                        title: 'Total Tasks',
                        value: report.totalTasks.toString(),
                        icon: Icons.task_alt,
                        color: Colors.blue,
                      ),
                      StatusTile(
                        title: 'Done',
                        value: report.doneTasks.toString(),
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                      StatusTile(
                        title: 'In Progress',
                        value: report.inProgressTasks.toString(),
                        icon: Icons.play_circle_outline,
                        color: Colors.orange,
                      ),
                      StatusTile(
                        title: 'Blocked',
                        value: report.blockedTasks.toString(),
                        icon: Icons.block,
                        color: Colors.red,
                      ),
                      StatusTile(
                        title: 'Overdue',
                        value: report.overdueTasks.toString(),
                        icon: Icons.warning,
                        color: Colors.deepOrange,
                      ),
                      StatusTile(
                        title: 'Completion',
                        value: '${report.completionPercentage.toStringAsFixed(1)}%',
                        icon: Icons.analytics,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Open Tasks by Assignee',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (report.openTasksByAssignee.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text('No open tasks assigned'),
                        ),
                      ),
                    )
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Assignee',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Open Tasks',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            ...report.openTasksByAssignee.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(entry.key),
                                    ),
                                    Expanded(
                                      child: Text(
                                        entry.value.toString(),
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
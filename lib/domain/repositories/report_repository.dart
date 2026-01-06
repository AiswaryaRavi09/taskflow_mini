import '../entities/project_report.dart';

abstract class ReportRepository {
  Future<ProjectReport> getProjectStatus(String projectId);
}
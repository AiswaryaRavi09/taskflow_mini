import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/project_report.dart';
import '../../../domain/repositories/report_repository.dart';

// Events
abstract class ReportEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadReport extends ReportEvent {
  final String projectId;

  LoadReport(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

// States
abstract class ReportState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final ProjectReport report;

  ReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class ReportError extends ReportState {
  final String message;

  ReportError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository repository;

  ReportBloc(this.repository) : super(ReportInitial()) {
    on<LoadReport>(_onLoadReport);
  }

  Future<void> _onLoadReport(
      LoadReport event,
      Emitter<ReportState> emit,
      ) async {
    emit(ReportLoading());
    try {
      final report = await repository.getProjectStatus(event.projectId);
      emit(ReportLoaded(report));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }
}
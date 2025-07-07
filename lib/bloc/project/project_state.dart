import 'package:equatable/equatable.dart';
import 'package:konfirmasi_wilkerstat/model/sls.dart';
import 'package:konfirmasi_wilkerstat/model/user.dart';
import 'package:konfirmasi_wilkerstat/model/village.dart';

class ProjectState extends Equatable {
  final ProjectStateData data;

  const ProjectState({required this.data});

  @override
  List<Object> get props => [data];
}

class Initializing extends ProjectState {
  const Initializing({required super.data});
}

class NoAssignment extends ProjectState {
  const NoAssignment({required super.data});
}

class InitializingError extends ProjectState {
  final String errorMessage;
  const InitializingError(this.errorMessage, {required super.data});
}

class DownloadAssignmentsFailed extends ProjectState {
  final String errorMessage;
  const DownloadAssignmentsFailed(this.errorMessage, {required super.data});
}

class DownloadVillageDataSuccess extends ProjectState {
  const DownloadVillageDataSuccess({required super.data});
}

class DownloadVillageDataFailed extends ProjectState {
  final String errorMessage;
  const DownloadVillageDataFailed({
    required super.data,
    required this.errorMessage,
  });
}

class TokenExpired extends ProjectState {
  const TokenExpired({required super.data});
}

class ProjectStateData {
  final bool isInitializing;
  final bool isDownloadingAssignments;
  final List<Village> villages;
  final List<Sls> sls;
  final User? user;

  ProjectStateData({
    required this.villages,
    required this.sls,
    required this.isInitializing,
    required this.isDownloadingAssignments,
    this.user,
  });

  ProjectStateData copyWith({
    List<Village>? villages,
    List<Sls>? sls,
    bool? isInitializing,
    bool? isDownloadingAssignments,
    User? user,
  }) {
    return ProjectStateData(
      villages: villages ?? this.villages,
      sls: sls ?? this.sls,
      isInitializing: isInitializing ?? this.isInitializing,
      isDownloadingAssignments:
          isDownloadingAssignments ?? this.isDownloadingAssignments,
      user: user ?? this.user,
    );
  }
}

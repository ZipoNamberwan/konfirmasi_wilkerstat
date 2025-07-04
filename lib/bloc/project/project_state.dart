import 'package:equatable/equatable.dart';
import 'package:konfirmasi_wilkerstat/model/sls.dart';
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
  final bool isDownloadingAssignments;
  final List<Village> villages;
  final List<Sls> sls;

  ProjectStateData({
    required this.villages,
    required this.sls,
    required this.isDownloadingAssignments,
  });

  ProjectStateData copyWith({
    List<Village>? villages,
    List<Sls>? sls,
    bool? isDownloadingAssignments,
    bool? isDownloadingBusinesses,
  }) {
    return ProjectStateData(
      villages: villages ?? this.villages,
      sls: sls ?? this.sls,
      isDownloadingAssignments:
          isDownloadingAssignments ?? this.isDownloadingAssignments,
    );
  }
}

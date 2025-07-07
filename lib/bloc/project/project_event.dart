import 'package:equatable/equatable.dart';

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();
  @override
  List<Object?> get props => [];
}

class Init extends ProjectEvent {
  const Init();
}

class AddSls extends ProjectEvent {
  final String slsId;
  const AddSls({required this.slsId});
}

class DownloadAssignments extends ProjectEvent {
  const DownloadAssignments();
}

class DownloadVillageData extends ProjectEvent {
  final String villageId;
  const DownloadVillageData({required this.villageId});
}

class DownloadSlsData extends ProjectEvent {
  final String slsId;
  const DownloadSlsData({required this.slsId});
}



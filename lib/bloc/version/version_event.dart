import 'package:equatable/equatable.dart';

abstract class VersionEvent extends Equatable {
  const VersionEvent();
  @override
  List<Object?> get props => [];
}

class CheckVersion extends VersionEvent {}

class DownloadNewPrelist extends VersionEvent {
  final List<String> slsIds;

  const DownloadNewPrelist({required this.slsIds});
}

class UpdateNewPrelistDownloadStatus extends VersionEvent {
  final List<String> slsIds;

  const UpdateNewPrelistDownloadStatus({required this.slsIds});
}

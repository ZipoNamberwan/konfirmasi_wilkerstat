import 'package:equatable/equatable.dart';
import 'package:konfirmasi_wilkerstat/model/version.dart';

class VersionState extends Equatable {
  final VersionStateData data;

  const VersionState({required this.data});

  @override
  List<Object> get props => [data];
}

class CheckVersionInitializing extends VersionState {
  CheckVersionInitializing()
    : super(
        data: VersionStateData(
          shouldUpdate: null,
          newVersion: null,
          isDownloadingNewPrelist: false,
        ),
      );
}

class UpdateNotification extends VersionState {
  const UpdateNotification({required super.data});
}

class NewAssignments extends VersionState {
  final List<String> localAssignments;
  final List<String> serverAssignments;

  const NewAssignments({
    required this.localAssignments,
    required this.serverAssignments,
    required super.data,
  });
}

class NewPrelistNotification extends VersionState {
  final List<String> newPrelist;
  const NewPrelistNotification({required this.newPrelist, required super.data});
}

class DownloadNewPrelistError extends VersionState {
  final String errorMessage;
  const DownloadNewPrelistError({
    required this.errorMessage,
    required super.data,
  });
}

class DownloadNewPrelistSuccess extends VersionState {
  const DownloadNewPrelistSuccess({required super.data});
}

class VersionStateData {
  final bool? shouldUpdate;
  final Version? newVersion;
  final String? currentVersionName;

  final bool isDownloadingNewPrelist;

  VersionStateData({
    this.newVersion,
    this.shouldUpdate,
    this.currentVersionName,
    required this.isDownloadingNewPrelist,
  });

  VersionStateData copyWith({
    Version? newVersion,
    bool? shouldUpdate,
    String? currentVersionName,
    bool? isDownloadingNewPrelist,
  }) {
    return VersionStateData(
      newVersion: newVersion ?? this.newVersion,
      shouldUpdate: shouldUpdate ?? this.shouldUpdate,
      currentVersionName: currentVersionName ?? this.currentVersionName,
      isDownloadingNewPrelist:
          isDownloadingNewPrelist ?? this.isDownloadingNewPrelist,
    );
  }
}

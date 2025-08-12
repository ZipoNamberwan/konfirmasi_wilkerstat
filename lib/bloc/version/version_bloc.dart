import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/version/version_event.dart';
import 'package:konfirmasi_wilkerstat/bloc/version/version_state.dart';
import 'package:konfirmasi_wilkerstat/classes/api_server_handler.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/assignment_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/auth_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/local_db/assignment_db_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/version_checking_repository.dart';
import 'package:konfirmasi_wilkerstat/model/business.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionBloc extends Bloc<VersionEvent, VersionState> {
  VersionBloc() : super(CheckVersionInitializing()) {
    on<CheckVersion>((event, emit) async {
      await ApiServerHandler.run(
        action: () async {
          PackageInfo packageInfo = await PackageInfo.fromPlatform();

          // Emit the current version name
          final currentVersionName = packageInfo.version;
          emit(
            VersionState(
              data: state.data.copyWith(currentVersionName: currentVersionName),
            ),
          );

          // Check for updates
          int buildNumber = int.parse(packageInfo.buildNumber);
          final organization =
              AuthRepository().getUser()?.organization?.id ?? '3500';
          final response = await VersionCheckingRepository().checkForUpdates(
            buildNumber,
            organization,
          );

          if (response['shouldUpdate'] == true) {
            emit(
              UpdateNotification(
                data: state.data.copyWith(
                  shouldUpdate: true,
                  newVersion: response['version'],
                ),
              ),
            );
            return;
          }

          final villages = await AssignmentDbRepository().getActiveVillages();
          final sls = await AssignmentDbRepository().getActiveSls();
          if (villages.isNotEmpty || sls.isNotEmpty) {
            final localSls =
                sls.where((sl) => !sl.isDeleted).map((sl) => sl.id).toList();
            final serverSls =
                (response['assignments'] as List)
                    .map((a) => a['long_code'] as String)
                    .toList();

            final isSame =
                Set.from(localSls).difference(Set.from(serverSls)).isEmpty &&
                Set.from(serverSls).difference(Set.from(localSls)).isEmpty;
            if (!isSame) {
              emit(
                NewAssignments(
                  data: state.data.copyWith(),
                  localAssignments: localSls,
                  serverAssignments: serverSls,
                ),
              );
              return;
            }
          }

          final updatePrelist =
              (response['assignments'] as List)
                  .where(
                    (a) =>
                        a['update_prelist'] != null &&
                        a['update_prelist']['has_been_downloaded'] == 0,
                  )
                  .map<String>((a) => a['long_code'] as String)
                  .toList();

          final savedUpdatedPrelist =
              await AssignmentDbRepository().getUpdatedPrelistSls();
          List<String> diff =
              updatePrelist
                  .toSet()
                  .difference(savedUpdatedPrelist.toSet())
                  .toList();
          if (diff.isNotEmpty) {
            emit(
              NewPrelistNotification(
                newPrelist: diff,
                data: state.data.copyWith(),
              ),
            );
            return;
          } else {
            if (updatePrelist.isNotEmpty) {
              add(UpdateNewPrelistDownloadStatus(slsIds: updatePrelist));
            }
          }
        },
        onLoginExpired: (e) {},
        onDataProviderError: (e) {},
        onOtherError: (e) {},
      );
    });

    on<DownloadNewPrelist>((event, emit) async {
      await ApiServerHandler.run(
        action: () async {
          emit(
            VersionState(
              data: state.data.copyWith(isDownloadingNewPrelist: true),
            ),
          );
          final result = await AssignmentRepository()
              .downloadBusinessesByMultipleSls(event.slsIds);
          final businesses =
              result.map((json) {
                return Business.fromJson(json);
              }).toList();

          await AssignmentDbRepository().saveBusinessesFromMultipleSls(
            businesses,
          );

          for (var s in event.slsIds) {
            await AssignmentDbRepository().updateSlsLockedStatus(s, false);
            await AssignmentDbRepository().addUpdatedPrelistSls(s);
          }
          emit(
            DownloadNewPrelistSuccess(
              data: state.data.copyWith(isDownloadingNewPrelist: false),
            ),
          );
          add(UpdateNewPrelistDownloadStatus(slsIds: event.slsIds));
        },
        onLoginExpired: (e) {},
        onDataProviderError: (e) {
          emit(
            DownloadNewPrelistError(
              errorMessage: e.message,
              data: state.data.copyWith(isDownloadingNewPrelist: false),
            ),
          );
        },
        onOtherError: (e) {
          emit(
            DownloadNewPrelistError(
              errorMessage: e.toString(),
              data: state.data.copyWith(isDownloadingNewPrelist: false),
            ),
          );
        },
      );
    });

    on<UpdateNewPrelistDownloadStatus>((event, emit) async {
      await ApiServerHandler.run(
        action: () async {
          await AssignmentRepository().updatePrelistStatus(event.slsIds, true);
        },
        onLoginExpired: (e) {},
        onDataProviderError: (e) {},
        onOtherError: (e) {},
      );
    });
  }
}

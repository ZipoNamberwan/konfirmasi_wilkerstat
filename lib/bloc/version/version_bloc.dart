import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/version/version_event.dart';
import 'package:konfirmasi_wilkerstat/bloc/version/version_state.dart';
import 'package:konfirmasi_wilkerstat/classes/api_server_handler.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/auth_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/version_checking_repository.dart';
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
                data: VersionStateData(
                  shouldUpdate: true,
                  newVersion: response['version'],
                ),
              ),
            );
          }
        },
        onLoginExpired: (e) {},
        onDataProviderError: (e) {},
        onOtherError: (e) {},
      );
    });
  }
}

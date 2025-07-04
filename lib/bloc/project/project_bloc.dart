import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/project/project_event.dart';
import 'package:konfirmasi_wilkerstat/bloc/project/project_state.dart';
import 'package:konfirmasi_wilkerstat/classes/api_server_handler.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/auth_repository.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc()
    : super(
        Initializing(
          data: ProjectStateData(
            isDownloadingAssignments: false,
            villages: [],
            sls: [],
          ),
        ),
      ) {
    on<Init>((event, emit) async {
      final villages = AuthRepository().getVillages();
      final sls = AuthRepository().getSls();
      emit(
        Initializing(data: state.data.copyWith(villages: villages, sls: sls)),
      );
    });

    on<DownloadVillageData>((event, emit) async {
      emit(
        Initializing(data: state.data.copyWith(isDownloadingAssignments: true)),
      );
      ApiServerHandler.run(
        action: () async {
          
        },
        onLoginExpired: (e) {
          emit(
            TokenExpired(
              data: state.data.copyWith(isDownloadingAssignments: false),
            ),
          );
        },
        onDataProviderError: (e) {
          emit(
            DownloadVillageDataFailed(
              data: state.data.copyWith(isDownloadingAssignments: false),
              errorMessage: e.message,
            ),
          );
        },
        onOtherError: (e) {
          emit(
            DownloadVillageDataFailed(
              data: state.data.copyWith(isDownloadingAssignments: false),
              errorMessage: e.toString(),
            ),
          );
        },
      );
    });
  }
}

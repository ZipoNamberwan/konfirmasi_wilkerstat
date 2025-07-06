import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/project/project_event.dart';
import 'package:konfirmasi_wilkerstat/bloc/project/project_state.dart';
import 'package:konfirmasi_wilkerstat/classes/api_server_handler.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/assignment_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/local_db/assignment_db_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/telegram_logger.dart';
import 'package:konfirmasi_wilkerstat/model/sls.dart';
import 'package:konfirmasi_wilkerstat/model/village.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc()
    : super(
        Initializing(
          data: ProjectStateData(
            isInitializing: false,
            villages: [],
            sls: [],
            isDownloadingAssignments: false,
          ),
        ),
      ) {
    on<Init>((event, emit) async {
      emit(Initializing(data: state.data.copyWith(isInitializing: true)));
      try {
        final villages = await AssignmentDbRepository().getVillages();
        final sls = await AssignmentDbRepository().getSls();
        if (villages.isEmpty && sls.isEmpty) {
          emit(NoAssignment(data: state.data.copyWith(isInitializing: false)));
        } else {
          emit(
            ProjectState(
              data: state.data.copyWith(
                isInitializing: false,
                villages: villages,
                sls: sls,
              ),
            ),
          );
        }
      } catch (e) {
        TelegramLogger.send('ProjectBloc Init Error: ${e.toString()}');
        emit(
          InitializingError(
            e.toString(),
            data: state.data.copyWith(isInitializing: false),
          ),
        );
      }
    });

    on<DownloadVillageData>((event, emit) async {});

    on<DownloadAssignments>((event, emit) async {
      emit(
        ProjectState(data: state.data.copyWith(isDownloadingAssignments: true)),
      );
      ApiServerHandler.run(
        action: () async {
          final assignments = await AssignmentRepository().getAssignments();
          final villages = assignments['villages'];
          final sls = assignments['sls'];

          // save villages and sls
          List<Village> villageList =
              villages
                  .map<Village>((village) => Village.fromJson(village))
                  .toList();
          await AssignmentDbRepository().saveVillages(villageList);

          final Map<String, Village> villageMap = {
            for (var v in villages) v['id'].toString(): Village.fromJson(v),
          };
          List<Sls> slsList =
              sls.map<Sls>((json) {
                final villageId = json['village_id'] as String;

                return Sls(
                  id: json['id'].toString(),
                  code: json['short_code'] as String,
                  name: json['name'] as String,
                  village: villageMap[villageId]!,
                );
              }).toList();
          await AssignmentDbRepository().saveSls(slsList);
          emit(
            ProjectState(
              data: state.data.copyWith(isDownloadingAssignments: false),
            ),
          );
          add(Init());
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
            DownloadAssignmentsFailed(
              e.message,
              data: state.data.copyWith(isDownloadingAssignments: false),
            ),
          );
        },
        onOtherError: (e) {
          emit(
            DownloadAssignmentsFailed(
              e.toString(),
              data: state.data.copyWith(isDownloadingAssignments: false),
            ),
          );
        },
      );
    });
  }
}

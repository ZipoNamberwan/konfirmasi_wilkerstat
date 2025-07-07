import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/project/project_event.dart';
import 'package:konfirmasi_wilkerstat/bloc/project/project_state.dart';
import 'package:konfirmasi_wilkerstat/classes/api_server_handler.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/assignment_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/auth_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/local_db/assignment_db_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/telegram_logger.dart';
import 'package:konfirmasi_wilkerstat/model/business.dart';
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
      // retrieve user information
      final user = AuthRepository().getUser();

      emit(Initializing(data: state.data.copyWith(isInitializing: true)));
      try {
        // Initialize local database by getting active villages and SLS
        final villages = await AssignmentDbRepository().getActiveVillages();
        final sls = await AssignmentDbRepository().getActiveSls();
        if (villages.isEmpty && sls.isEmpty) {
          emit(NoAssignment(data: state.data.copyWith(isInitializing: false)));
        } else {
          emit(
            ProjectState(
              data: state.data.copyWith(
                isInitializing: false,
                villages: villages,
                sls: sls,
                user: user,
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

    on<DownloadVillageData>((event, emit) async {
      await ApiServerHandler.run(
        action: () async {
          final result = await AssignmentRepository()
              .downloadBusinessesByVillage(event.villageId);
          final businesses =
              result.map((json) {
                return Business.fromJson(json);
              }).toList();

          await AssignmentDbRepository().saveBusinesses(businesses);
          await AssignmentDbRepository().updateVillageDownloadStatus(
            event.villageId,
            true,
          );

          final villages = await AssignmentDbRepository().getActiveVillages();
          final sls = await AssignmentDbRepository().getActiveSls();
          emit(
            ProjectState(
              data: state.data.copyWith(villages: villages, sls: sls),
            ),
          );
        },
        onLoginExpired: (e) {},
        onDataProviderError: (e) {},
        onOtherError: (e) {},
      );
    });

    on<DownloadSlsData>((event, emit) async {
      await AssignmentDbRepository().updateSlsDownloadStatus(event.slsId, true);
      final sls = await AssignmentDbRepository().getActiveSls();

      emit(ProjectState(data: state.data.copyWith(sls: sls)));
    });

    on<DownloadAssignments>((event, emit) async {
      emit(
        ProjectState(data: state.data.copyWith(isDownloadingAssignments: true)),
      );
      await ApiServerHandler.run(
        action: () async {
          final assignments = await AssignmentRepository().getAssignments();
          final villages = assignments['villages'];
          final sls = assignments['sls'];

          final incomingVillageIds =
              villages.map<String>((v) => v['id'].toString()).toSet();
          final localVillages =
              await AssignmentDbRepository()
                  .getVillages(); // includes is_deleted
          final localVillageMap = {for (var v in localVillages) v.id: v};

          // 1. Insert new and Reactivate soft-deleted
          List<Village> villagesToInsert = [];
          List<String> villageIdsToReactivate = [];

          for (final v in villages) {
            final id = v['id'].toString();
            if (!localVillageMap.containsKey(id)) {
              villagesToInsert.add(Village.fromJson(v));
            } else if (localVillageMap[id]!.isDeleted) {
              villageIdsToReactivate.add(id);
            }
          }

          await AssignmentDbRepository().saveVillages(villagesToInsert);
          await AssignmentDbRepository().reactivateVillages(
            villageIdsToReactivate,
          );

          // 2. Mark deleted: if local exists but missing from response
          final localVillageIds = localVillageMap.keys.toSet();
          final missingVillageIds = localVillageIds.difference(
            incomingVillageIds,
          );
          await AssignmentDbRepository().markVillagesAsDeleted(
            missingVillageIds.toList(),
          );

          // save villages and sls
          final updatedVillages = await AssignmentDbRepository().getVillages();
          final Map<String, Village> villageMap = {
            for (var v in updatedVillages) v.id: v,
          };

          final incomingSlsIds =
              sls.map<String>((s) => s['id'].toString()).toSet();
          final localSlsList = await AssignmentDbRepository().getSls();
          final localSlsMap = {for (var s in localSlsList) s.id: s};

          List<Sls> slsToInsert = [];
          List<String> slsToReactivate = [];

          for (final s in sls) {
            final id = s['id'].toString();
            if (!localSlsMap.containsKey(id)) {
              slsToInsert.add(Sls.fromJsonWithVillageMap(s, villageMap));
            } else if (localSlsMap[id]!.isDeleted) {
              slsToReactivate.add(id);
            }
          }

          await AssignmentDbRepository().saveSls(slsToInsert);
          await AssignmentDbRepository().reactivateSls(slsToReactivate);

          // Mark SLS as deleted if missing from incoming
          final localSlsIds = localSlsMap.keys.toSet();
          final missingSlsIds = localSlsIds.difference(incomingSlsIds);
          await AssignmentDbRepository().markSlsAsDeleted(
            missingSlsIds.toList(),
          );

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

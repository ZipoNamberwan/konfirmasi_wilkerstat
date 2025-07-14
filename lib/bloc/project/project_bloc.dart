import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/project/project_event.dart';
import 'package:konfirmasi_wilkerstat/bloc/project/project_state.dart';
import 'package:konfirmasi_wilkerstat/classes/api_server_handler.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/assignment_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/auth_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/local_db/assignment_db_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/local_db/upload_db_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/third_party_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/telegram_logger.dart';
import 'package:konfirmasi_wilkerstat/model/business.dart';
import 'package:konfirmasi_wilkerstat/model/sls.dart';
import 'package:konfirmasi_wilkerstat/model/village.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc()
    : super(
        Initializing(
          data: ProjectStateData(
            isInitializing: false,
            villages: [],
            sls: [],
            isDownloadingAssignments: false,
            isDownloadingVillage: false,
            isDownloadingSls: false,
            latestSlsUploads: {},
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
        final latestUploads = await UploadDbRepository().getLatestSlsUploads(
          sls.map((s) => s.id).toList(),
        );
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
                latestSlsUploads: latestUploads,
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
          emit(
            ProjectState(data: state.data.copyWith(isDownloadingVillage: true)),
          );
          final encryptedVillageId = _encryptVillageId(event.villageId);
          final result = await ThirdPartyRepository()
              .getBusinessByVillageViaCloudflare(encryptedVillageId);
          // final result = await AssignmentRepository()
          //     .downloadBusinessesByVillage(event.villageId);
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
            DownloadVillageDataSuccess(
              data: state.data.copyWith(
                villages: villages,
                sls: sls,
                isDownloadingVillage: false,
              ),
            ),
          );
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
              data: state.data.copyWith(isDownloadingVillage: false),
              errorMessage: e.message,
            ),
          );
        },
        onOtherError: (e) {
          emit(
            DownloadVillageDataFailed(
              data: state.data.copyWith(isDownloadingVillage: false),
              errorMessage: e.toString(),
            ),
          );
        },
      );
    });

    on<DownloadSlsData>((event, emit) async {
      await ApiServerHandler.run(
        action: () async {
          emit(ProjectState(data: state.data.copyWith(isDownloadingSls: true)));
          final result = await AssignmentRepository().downloadBusinessesBySls(
            event.slsId,
          );
          final businesses =
              result.map((json) {
                return Business.fromJson(json);
              }).toList();

          await AssignmentDbRepository().saveBusinesses(businesses);
          await AssignmentDbRepository().updateSlsDownloadStatus(
            event.slsId,
            true,
          );
          final sls = await AssignmentDbRepository().getActiveSls();
          emit(
            DownloadSlsDataSuccess(
              data: state.data.copyWith(sls: sls, isDownloadingSls: false),
            ),
          );
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
            DownloadSlsDataFailed(
              data: state.data.copyWith(isDownloadingSls: false),
              errorMessage: e.message,
            ),
          );
        },
        onOtherError: (e) {
          emit(
            DownloadSlsDataFailed(
              data: state.data.copyWith(isDownloadingSls: false),
              errorMessage: e.toString(),
            ),
          );
        },
      );
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

    on<UpdateLastUpdate>((event, emit) async {
      final sls = state.data.sls;
      final latestUploads = await UploadDbRepository().getLatestSlsUploads(
        sls.map((s) => s.id).toList(),
      );

      emit(
        ProjectState(
          data: state.data.copyWith(latestSlsUploads: latestUploads),
        ),
      );
    });
  }

  String _encryptVillageId(String villageId) {
    final secret = 'TqubAjeim3xjLf5AR6KCGWUQRjR0PQdK';

    final hashed = sha256.convert(utf8.encode(secret)).toString();

    List<int> hexToBytes(String hex) {
      final result = <int>[];
      for (var i = 0; i < hex.length; i += 2) {
        result.add(int.parse(hex.substring(i, i + 2), radix: 16));
      }
      return result;
    }

    final keyBytes = hexToBytes(hashed.substring(0, 32)); // 16 bytes
    final ivSourceBytes = hexToBytes(
      hashed.substring(32, 48),
    ); // 8 bytes only (matches JS)

    // Pad IV to 16 bytes like CryptoJS does
    final ivPadded = Uint8List(16)
      ..setRange(0, ivSourceBytes.length, ivSourceBytes);

    final key = encrypt.Key(Uint8List.fromList(keyBytes));
    final iv = encrypt.IV(ivPadded);

    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );

    final encrypted = encrypter.encrypt(villageId, iv: iv);

    return encrypted.base64
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll(RegExp(r'=+$'), '');
  }
}

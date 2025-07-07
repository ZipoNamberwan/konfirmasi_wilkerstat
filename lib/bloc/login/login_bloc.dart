import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/classes/api_server_handler.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/auth_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/local_db/assignment_db_repository.dart';
import 'package:konfirmasi_wilkerstat/model/sls.dart';
import 'package:konfirmasi_wilkerstat/model/user.dart';
import 'package:konfirmasi_wilkerstat/model/village.dart';
// import 'package:konfirmasi_wilkerstat/model/user.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc()
    : super(
        Initializing(
          data: LoginStateData(
            isSubmitting: false,
            isSuccess: false,
            isFailure: false,
            obscurePassword: true,
            email: LoginFormFieldState<String>(),
            password: LoginFormFieldState<String>(),
            isLogoutLoading: false,
            isLogoutSuccess: false,
            isLogoutFailure: false,
          ),
        ),
      ) {
    on<InitLogin>((event, emit) async {
      emit(Initializing(data: state.data.copyWith(isSubmitting: true)));
      if (AuthRepository().isTokenExists()) {
        emit(
          LoginSuccess(
            data: state.data.copyWith(isSuccess: true, isSubmitting: false),
          ),
        );
      } else {
        emit(LoginState(data: state.data.copyWith(isSubmitting: false)));
      }
    });

    on<LoginEmailChanged>((event, emit) {
      emit(
        LoginState(
          data: state.data.copyWith(
            email: state.data.email.copyWith(value: event.email, error: null),
          ),
        ),
      );
    });

    on<LoginPasswordChanged>((event, emit) {
      emit(
        LoginState(
          data: state.data.copyWith(
            password: state.data.password.copyWith(
              value: event.password,
              error: null,
            ),
          ),
        ),
      );
    });

    on<ToggleObscurePassword>((event, emit) {
      emit(
        LoginState(
          data: state.data.copyWith(
            obscurePassword: !state.data.obscurePassword,
          ),
        ),
      );
    });

    on<LoginSubmitted>((event, emit) async {
      emit(
        LoginState(
          data: state.data.copyWith(
            isSubmitting: true,
            resetAllErrorMessages: true,
            isSuccess: false,
            isFailure: false,
          ),
        ),
      );

      // Input validation
      String? emailError;
      String? passwordError;

      final email = state.data.email.value;
      final password = state.data.password.value;

      if (email == null || email.isEmpty) {
        emailError = 'Email kosong';
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        emailError = 'Email tidak valid';
      }

      if (password == null || password.isEmpty) {
        passwordError = 'Password kosong';
      }

      if (emailError != null || passwordError != null) {
        emit(
          LoginState(
            data: state.data.copyWith(
              isSubmitting: false,
              isFailure: true,
              isSuccess: false,
              email: state.data.email.copyWith(error: emailError),
              password: state.data.password.copyWith(error: passwordError),
            ),
          ),
        );
        return;
      }

      await ApiServerHandler.run(
        action: () async {
          emit(LoginState(data: state.data.copyWith(isSubmitting: true)));
          final response = await AuthRepository().login(
            email: email!,
            password: password!,
          );
          final token = response['token'];
          final user = response['user'];
          final villages = response['villages'];
          final sls = response['user']['wilkerstat_sls'];

          // // save villages and sls
          // List<Village> villageList =
          //     villages
          //         .map<Village>((village) => Village.fromJson(village))
          //         .toList();
          // await AssignmentDbRepository().saveVillages(villageList);

          // final Map<String, Village> villageMap = {
          //   for (var v in villages) v['id'].toString(): Village.fromJson(v),
          // };
          // List<Sls> slsList =
          //     sls.map<Sls>((json) {
          //       final villageId = json['village_id'] as String;

          //       return Sls(
          //         id: json['id'].toString(),
          //         code: json['short_code'] as String,
          //         name: json['name'] as String,
          //         village: villageMap[villageId]!,
          //         isDeleted: false, // Assuming Sls is not deleted initially
          //         hasDownloaded:
          //             false, // Assuming Sls is not downloaded initially
          //       );
          //     }).toList();
          // await AssignmentDbRepository().saveSls(slsList);

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

          // save token and user
          AuthRepository().saveToken(token);
          AuthRepository().saveUser(User.fromJson(user));

          emit(
            LoginSuccess(
              data: state.data.copyWith(isSuccess: true, isSubmitting: false),
            ),
          );
        },
        onLoginExpired: (e) {},
        onDataProviderError: (e) {
          emit(
            LoginFailed(
              errorMessage: e.message,
              data: state.data.copyWith(
                isSubmitting: false,
                isFailure: true,
                isSuccess: false,
              ),
            ),
          );
        },
        onOtherError: (e) {
          emit(
            LoginFailed(
              errorMessage: e.toString(),
              data: state.data.copyWith(
                isSubmitting: false,
                isFailure: true,
                isSuccess: false,
              ),
            ),
          );
        },
      );
    });

    on<MockupLogin>((event, emit) async {
      emit(
        LoginState(
          data: state.data.copyWith(
            isSubmitting: true,
            resetAllErrorMessages: true,
            isSuccess: false,
            isFailure: false,
          ),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      emit(LoginSuccess(data: state.data.copyWith(isSuccess: true)));
    });
  }
}

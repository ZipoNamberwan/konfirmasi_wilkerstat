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

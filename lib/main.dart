import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/login/login_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/login/login_event.dart';
import 'package:konfirmasi_wilkerstat/bloc/login/logout_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/project/project_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/version/version_bloc.dart';
import 'package:konfirmasi_wilkerstat/classes/app_config.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/assignment_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/auth_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/local_db/assignment_db_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/local_db/upload_db_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/third_party_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/version_checking_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/telegram_logger.dart';
import 'pages/login_page.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    try {
      final fullStack = details.stack.toString();
      final truncatedStack =
          fullStack.length > AppConfig.stackTraceLimitCharacter
              ? fullStack.substring(0, AppConfig.stackTraceLimitCharacter)
              : fullStack;

      TelegramLogger.send('''🚨 *Flutter Error*

    *Exception:* `${details.exception}`
    *Library:* `${details.library}`
    *Stack Trace:*
    $truncatedStack

    ''');
    } catch (_) {
      // Fail silently so it never blocks real error flow
    }

    FlutterError.presentError(details);
  };

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await _initializeApp();
      runApp(MyApp());
    },
    (Object error, StackTrace stack) {
      try {
        final fullTrace = stack.toString();
        final truncatedTrace =
            fullTrace.length > AppConfig.stackTraceLimitCharacter
                ? fullTrace.substring(0, AppConfig.stackTraceLimitCharacter)
                : fullTrace;

        final user = AuthRepository().getUser();
        final userInfo =
            user != null
                ? 'ID: ${user.id}, Name: ${user.firstname}, Email: ${user.email}, Organization: ${user.organization?.name ?? 'N/A'}'
                : 'User is null';

        final logMessage = '''
      🚨 *Unhandled Dart Error*

      *Error:* `${error.toString()}`
      *User Info:* $userInfo
      *Stack Trace:*
      $truncatedTrace
      ''';

        TelegramLogger.send(logMessage);
      } catch (_) {
        // Fail silently so it never blocks real error flow
      }
    },
  );
}

Future<void> _initializeApp() async {
  await AuthRepository().init();
  await AssignmentDbRepository().init();
  await AssignmentRepository().init();
  await ThirdPartyRepository().init();
  await UploadDbRepository().init();
  await VersionCheckingRepository().init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc()..add(InitLogin()),
        ),
        BlocProvider<ProjectBloc>(create: (context) => ProjectBloc()),
        BlocProvider<LogoutBloc>(create: (context) => LogoutBloc()),
        BlocProvider<UpdatingBloc>(create: (context) => UpdatingBloc()),
        BlocProvider<VersionBloc>(create: (context) => VersionBloc()),
      ],
      child: MaterialApp(
        title: 'KEN AROK',
        debugShowCheckedModeBanner: false,
        home: const LoginPage(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/login/login_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/login/login_event.dart';
import 'package:konfirmasi_wilkerstat/bloc/login/logout_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/project/project_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_bloc.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/assignment_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/auth_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/local_db/assignment_db_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/local_db/upload_db_repository.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/third_party_repository.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp();
  runApp(const MyApp());
}

Future<void> _initializeApp() async {
  await AuthRepository().init();
  await AssignmentDbRepository().init();
  await AssignmentRepository().init();
  await ThirdPartyRepository().init();
  await UploadDbRepository().init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc()..add(InitLogin()),
          // ..add(MockupLogin()),
        ),
        BlocProvider<ProjectBloc>(create: (context) => ProjectBloc()),
        BlocProvider<LogoutBloc>(create: (context) => LogoutBloc()),
        BlocProvider<UpdatingBloc>(create: (context) => UpdatingBloc()),
      ],
      child: MaterialApp(
        title: 'Konfirmasi Wilkerstat',
        debugShowCheckedModeBanner: false,
        home: const LoginPage(),
      ),
    );
  }
}

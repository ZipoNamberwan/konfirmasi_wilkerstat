import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/login/login_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/login/login_event.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/auth_repository.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp();
  runApp(const MyApp());
}

Future<void> _initializeApp() async {
  await AuthRepository().init();
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
      ],
      child: MaterialApp(
        title: 'Konfirmasi Wilkerstat',
        debugShowCheckedModeBanner: false,
        home: const LoginPage(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memospace/features/memo/cubit/memo_cubit.dart';
import 'package:memospace/features/memo/data/memo_repository.dart';
import 'package:memospace/features/workspace/cubit/workspace_cubit.dart';
import 'package:memospace/features/workspace/data/workspace_repository.dart';

import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
// import 'features/home/home_screen.dart';
import 'features/shell/main_shell.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => WorkspaceCubit(WorkspaceRepository())),
        BlocProvider(create: (_) => MemoCubit(MemoRepository())),
      ],
      child: const MemoSpaceApp(),
    ),
  );
}

class MemoSpaceApp extends StatelessWidget {
  const MemoSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoSpace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        // AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.home: (context) => const MainShell(),
      },
    );
  }
}

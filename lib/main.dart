import 'package:flutter/material.dart';

import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
// import 'features/home/home_screen.dart';
import 'features/shell/main_shell.dart';

void main() {
  runApp(const MemoSpaceApp());
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

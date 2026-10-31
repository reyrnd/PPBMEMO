import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/app_theme.dart';
import '../../auth/screens/login_screen.dart';
import '../../shell/main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    // Efek visual splash
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Tunggu auth state Firebase selesai di-restore
    final user = await FirebaseAuth.instance
        .authStateChanges()
        .first
        .timeout(const Duration(seconds: 5), onTimeout: () => null);

    if (!mounted) return;

    // Jika sudah login → MainShell, belum login → LoginScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            user != null ? const MainShell() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.ink,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 56),
            SizedBox(height: 16),
            Text(
              'MemoSpace',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

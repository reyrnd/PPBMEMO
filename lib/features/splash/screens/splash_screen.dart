import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/app_routes.dart';
import '../../../core/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.login,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  child: Image.asset(
                    'assets/images/MemoSpaceLogo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const Text(
                  'MemoSpace',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Semua ide, satu ruang bersama.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 90,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      minHeight: 4,
                      backgroundColor: AppTheme.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16), // Jarak antara loading bar dan teks
                const Text(
                  'Memuat ruang kerja...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(
                        0xFF75777C), // Menggunakan warna teks sekunder Anda
                  ),
                ),
                const SizedBox(height: 4), // Jarak tipis ke teks versi
                const Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(
                        0xFFC5C6CC), // Menggunakan warna abu-abu tipis untuk versi
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}

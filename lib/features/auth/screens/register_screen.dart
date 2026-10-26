import 'package:flutter/material.dart';

import '../../../core/app_routes.dart';
import '../../../core/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Validasi berhasil. Pendaftaran belum dihubungkan.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tema dekorasi kolom masukan (Filled & Rounded Penuh)
    final inputDecorationTheme = InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF4F5F7), // Latar abu-abu halus
      hintStyle: const TextStyle(color: Colors.black38),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      errorStyle: const TextStyle(
          height: 0,
          fontSize:
              0), // Menyembunyikan teks error bawaan karena kita buat kustom di bawahnya
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: AppTheme.textPrimary, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Bagian Logo & Badge Atas ---
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppTheme.textPrimary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              'assets/images/MemoSpaceLogo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.assignment_turned_in,
                                      color: Colors.white, size: 28),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '• MEMOSPACE WORKSPACE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Bagian Judul ---
                  const Center(
                    child: Text(
                      'Buat akun',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Mulai simpan ide dan bekerja bersama tim.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Input Nama Lengkap ---
                  const Text(
                    'Nama Lengkap',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: inputDecorationTheme.copyWith(
                      hintText: 'Farhan Kurniawan',
                      prefixIcon: const Icon(Icons.person_outline,
                          color: Colors.black54),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty)
                        return 'Nama wajib diisi.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- Input Email ---
                  const Text(
                    'Email',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: inputDecorationTheme.copyWith(
                      hintText: 'farhan.kurniawan@workspace.id',
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: Colors.black54),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty)
                        return 'Email wajib diisi.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- Input Kata Sandi ---
                  const Text(
                    'Kata Sandi',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: inputDecorationTheme.copyWith(
                      hintText: '••••••••••••••••',
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: Colors.black54),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Password wajib diisi.';
                      if (value.length < 8) return 'Kurang';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  // Petunjuk kriteria kata sandi sesuai gambar
                  const Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 14, color: Colors.black38),
                      SizedBox(width: 6),
                      Text(
                        'Minimal 8 karakter, kombinasi huruf & angka',
                        style: TextStyle(fontSize: 12, color: Colors.black38),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Input Konfirmasi Kata Sandi ---
                  const Text(
                    'Konfirmasi Kata Sandi',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  // Kita pakai FormFieldState kustom untuk mendeteksi error pewarnaan kotak seperti di gambar
                  FormField<String>(
                    validator: (value) {
                      if (_confirmPasswordController.text.isEmpty) {
                        return 'Konfirmasi password wajib diisi.';
                      }
                      if (_confirmPasswordController.text !=
                          _passwordController.text) {
                        return 'Kata sandi belum cocok';
                      }
                      return null;
                    },
                    builder: (FormFieldState state) {
                      final hasError = state.hasError;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            onChanged: (value) {
                              state.didChange(value);
                            },
                            decoration: InputDecoration(
                              filled: true,
// Jika error, latar belakang berubah kemerahan tipis sesuai gambar
                              fillColor: hasError
                                  ? const Color(0xFFFFEBEE)
                                  : const Color(0xFFF4F5F7),
                              hintText: '••••••••••••••••',
                              hintStyle: const TextStyle(color: Colors.black38),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
// Merubah ikon gembok jadi putar/history saat salah sandi
                              prefixIcon: Icon(
                                hasError ? Icons.history : Icons.lock_outline,
                                color: hasError
                                    ? Colors.redAccent
                                    : Colors.black54,
                              ),
                              suffixIcon: hasError
                                  ? const Icon(Icons.error_outline,
                                      color: Colors.redAccent)
                                  : IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.black54,
                                      ),
                                    ),
                            ),
                          ),
                          if (hasError) ...[
                            const SizedBox(height: 8),
                            Text(
                              state.errorText ?? '',
                              style: const TextStyle(
                                  color: Colors.redAccent, fontSize: 12),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
// --- Tombol Buat Akun Utama ---
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: _handleRegister,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.textPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Buat Akun',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
// --- Divider Pembatas "atau" ---
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'atau',
                          style: TextStyle(color: Colors.black38, fontSize: 13),
                        ),
                      ),
                      Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                    ],
                  ),
                  const SizedBox(height: 20),
// --- Tombol Daftar dengan Google ---
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF4F5F7),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.g_mobiledata,
                              size: 32, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'Daftar dengan Google',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
// --- Badge Keamanan ---
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_outlined,
                              size: 16, color: Colors.green),
                          SizedBox(width: 6),
                          Text(
                            'Enkripsi Ruang Kerja Aktif',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
// --- Teks Sudah Punya Akun? Masuk ---
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Sudah punya akun? ',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 14),
                        ),
                        InkWell(
                          onTap: () {
// Menggunakan rute balik ke login screen
                            Navigator.pushReplacementNamed(
                                context, AppRoutes.login);
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            child: Text(
                              'Masuk',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                                decoration: TextDecoration.underline,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
// --- Catatan Hukum / Persetujuan Privasi ---
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Dengan mendaftar, Anda menyetujui Ketentuan & Privasi MemoSpace.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black38,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

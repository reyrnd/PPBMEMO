import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/core/utils/validators.dart';

class ChangePasswordScreen extends StatefulWidget {
  final ValueChanged<PasswordChangeData>? onSave;

  const ChangePasswordScreen({
    super.key,
    this.onSave,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  var _obscureCurrentPassword = true;
  var _obscureNewPassword = true;
  var _obscureConfirmPassword = true;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_refreshPasswordRequirements);
    _confirmPasswordController.addListener(_refreshPasswordRequirements);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _refreshPasswordRequirements() {
    setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masuk kembali untuk mengubah kata sandi.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: _currentPasswordController.text,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPasswordController.text);
      widget.onSave?.call(
        PasswordChangeData(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi berhasil diubah.')),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      final message = switch (error.code) {
        'wrong-password' ||
        'invalid-credential' =>
          'Kata sandi lama yang dimasukkan salah.',
        'weak-password' => 'Kata sandi baru terlalu lemah.',
        'requires-recent-login' =>
          'Silakan masuk kembali sebelum mengubah kata sandi.',
        _ => 'Kata sandi gagal diubah. Silakan coba lagi.',
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi gagal diubah. Silakan coba lagi.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final password = _newPasswordController.text;
    final hasMinLength = password.length >= 8;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ubah Kata Sandi',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        // Ikon avatar di pojok kanan atas telah dihapus di sini agar konsisten
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    // --- 1. BOX NOTIFIKASI KEAMANAN ---
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.shield_outlined,
                              size: 18, color: AppTheme.textSecondary),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Buat kata sandi baru yang kuat untuk melindungi akun dan workspace MemoSpace Anda.',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- 2. INPUT KATA SANDI LAMA & OPSI LUPA ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _FieldLabel('Kata sandi lama'),
                        GestureDetector(
                          onTap: () {
                            // Tambahkan aksi navigasi atau fungsi lupa sandi di sini
                          },
                          child: const Text(
                            'Lupa kata sandi?',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      hintText: 'Masukkan kata sandi lama',
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      onToggleVisibility: () => setState(
                        () =>
                            _obscureCurrentPassword = !_obscureCurrentPassword,
                      ),
                      validator: (value) =>
                          Validators.required(value, 'Kata sandi saat ini'),
                    ),
                    const SizedBox(height: 20),

                    // --- 3. INPUT KATA SANDI BARU ---
                    const _FieldLabel('Kata sandi baru'),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      hintText: 'Masukkan kata sandi baru',
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      onToggleVisibility: () => setState(
                          () => _obscureNewPassword = !_obscureNewPassword),
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 16),

                    // --- 4. BOKS PERSYARATAN KATA SANDI KUSTOM ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PERSYARATAN KATA SANDI:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black45,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildRequirement('Minimal 8 karakter', hasMinLength),
                          _buildRequirement(
                              'Mengandung huruf besar (A-Z)', hasUppercase),
                          _buildRequirement(
                              'Mengandung angka (0-9)', hasNumber),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- 5. INPUT KONFIRMASI KATA SANDI BARU ---
                    const _FieldLabel('Konfirmasi kata sandi baru'),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      hintText: 'Ulangi kata sandi baru',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      onToggleVisibility: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                      validator: (value) => Validators.confirmPassword(
                        value,
                        _newPasswordController.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // --- 6. TOMBOL AKSI UTAMA & FOOTER INFO ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.textPrimary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Simpan kata sandi baru',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.history,
                          size: 15, color: AppTheme.textSecondary),
                      SizedBox(width: 6),
                      Text(
                        'Perubahan akan mengeluarkan sesi di perangkat lain',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String hintText,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required FormFieldValidator<String?> validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        suffixIcon: IconButton(
          tooltip: obscureText ? 'Lihat kata sandi' : 'Sembunyikan kata sandi',
          onPressed: onToggleVisibility,
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.black45,
            size: 20,
          ),
        ),
        filled: true,
        fillColor:
            const Color(0xFFF3F4F6), // Seragam tanpa garis border kaku luar
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.textPrimary, width: 1),
        ),
      ),
    );
  }

  Widget _buildRequirement(String label, bool satisfied) {
// Menyesuaikan warna hijau sukses sesuai gambar referensi Anda
    final color = satisfied ? const Color(0xFF16A34A) : AppTheme.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            satisfied ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: satisfied ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class PasswordChangeData {
  final String currentPassword;
  final String newPassword;
  const PasswordChangeData({
    required this.currentPassword,
    required this.newPassword,
  });
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
        fontSize: 14,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/core/utils/validators.dart';
import 'package:memospace/features/auth/models/app_user.dart';

class EditProfileScreen extends StatefulWidget {
  final AppUser user;
  final Future<void> Function(AppUser)? onSave;
  final VoidCallback? onChangePhoto;

  const EditProfileScreen({
    super.key,
    required this.user,
    this.onSave,
    this.onChangePhoto,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _bioController;

  // State untuk memantau jumlah karakter bio secara real-time
  int _bioCharacterCount = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _bioCharacterCount = _bioController.text.length;

    _bioController.addListener(() {
      setState(() {
        _bioCharacterCount = _bioController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await widget.onSave?.call(
        widget.user.copyWith(
          name: _nameController.text.trim(),
          bio: _bioController.text.trim(),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil gagal disimpan: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: AppTheme.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
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
                    // --- 1. SEKSI FOTO PROFIL ---
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 52,
                                backgroundColor: AppTheme.ink,
                                child: Text(
                                  widget.user.initials,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: widget.onChangePhoto,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.textPrimary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_outlined,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: widget.onChangePhoto,
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.textPrimary,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Ubah foto',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- 2. INPUT NAMA LENGKAP ---
                    const _FieldLabel('Nama lengkap'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => Validators.required(value, 'Nama'),
                      style: const TextStyle(
                          color: AppTheme.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                      decoration: _inputDecoration().copyWith(
                        suffixIcon: _nameController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.cancel_outlined,
                                    color: AppTheme.faint, size: 20),
                                onPressed: () => _nameController.clear(),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- 3. INPUT EMAIL (READ ONLY & DISABLED) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _FieldLabel('Email'),
                        Row(
                          children: const [
                            Icon(Icons.lock_outline,
                                size: 13, color: AppTheme.textSecondary),
                            SizedBox(width: 4),
                            Text(
                              'Tidak dapat diubah',
                              style: TextStyle(
                                  fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      readOnly: true,
                      enabled: false,
                      style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                      decoration: _inputDecoration().copyWith(
                        suffixIcon: const Icon(Icons.verified_outlined,
                            color: AppTheme.faint, size: 18),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- 4. INPUT BIO SINGKAT ---
                    const _FieldLabel('Bio singkat'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _bioController,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 4,
                      maxLines: 5,
                      maxLength: 200,
                      style: const TextStyle(
                          color: AppTheme.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.4),
                      decoration: _inputDecoration(
                        hintText: 'Jelaskan diri Anda secara singkat...',
                      ).copyWith(
                        counterText:
                            '', // Menghilangkan counter default di pojok kanan bawah bawaan material
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Baris Status Publikasi & Kustom Counter Teks sesuai Gambar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.circle,
                                size: 6, color: Color(0xFF16A34A)),
                            SizedBox(width: 6),
                            Text(
                              'Publik',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF16A34A),
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Text(
                          '$_bioCharacterCount / 200 karakter',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
// --- 5. BOX INFORMASI PROFIL ---
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.line),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.info_outline,
                              size: 18, color: AppTheme.textSecondary),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Informasi ini akan ditampilkan pada profil tim, repositori riset, dan kolaborator proyek MemoSpace.',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
// --- 6. TOMBOL SIMPAN PERUBAHAN ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.ink,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Simpan perubahan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.check, size: 18),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
          color: AppTheme.faint, fontSize: 14, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: AppTheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.textPrimary, width: 1),
      ),
    );
  }
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

import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  // Bahasa default sesuai dengan konfigurasi berkas TSX
  String _selectedLanguage = 'Bahasa Indonesia';

  final List<String> _languages = ['Bahasa Indonesia', 'English', 'Español'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Judul Section Preferensi Bahasa
              const Text(
                'Pilih bahasa yang ingin digunakan.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 16),

              // Kotak Kontainer Daftar Bahasa (White Box Style)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.whiteBackgroundField,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.line),
                ),
                child: Column(
                  children: List.generate(_languages.length, (index) {
                    final language = _languages[index];
                    final isSelected = language == _selectedLanguage;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedLanguage = language),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          border: index == _languages.length - 1
                              ? null
                              : const Border(
                                  bottom: BorderSide(
                                      color: AppTheme.line, width: 1)),
                        ),
                        child: Row(
                          children: [
                            // Teks Nama Bahasa
                            Expanded(
                              child: Text(
                                language,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.ink,
                                ),
                              ),
                            ),
                            // Indikator Centang Bulat Seleksi Kreatif (Gaya Radio Figma)
                            if (isSelected)
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: AppTheme.ink,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const Spacer(),

              // Tombol Konfirmasi Pengubahan Bahasa di Bagian Bawah
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.ink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text(
                    'Terapkan bahasa',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-Widgets / Component Slicing
  // ---------------------------------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.canvas,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.ink),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Bahasa',
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink),
      ),
    );
  }
}

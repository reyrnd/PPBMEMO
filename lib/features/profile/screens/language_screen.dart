import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';

class LanguageScreen extends StatefulWidget {
  final String initialLanguage;
  final ValueChanged<String>? onLanguageChanged;

  const LanguageScreen({
    super.key,
    this.initialLanguage = 'Indonesia',
    this.onLanguageChanged,
  }) : assert(
          initialLanguage == 'Indonesia' || initialLanguage == 'English',
          'initialLanguage must be Indonesia or English.',
        );

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selectedLanguage = widget.initialLanguage;

  void _selectLanguage(String language) {
    setState(() => _selectedLanguage = language);
  }

  void _savePreference() {
    widget.onLanguageChanged?.call(_selectedLanguage);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // --- 1. APP BAR CLEAN SETUP ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bahasa',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        // Ikon avatar di pojok kanan atas dihapus agar konsisten secara fungsional
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  // --- 2. SUB-DESKRIPSI JUDUL ---
                  const Text(
                    'Pilih bahasa tampilan untuk aplikasi MemoSpace Anda.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- 3. BOKS PILIHAN BAHASA ---
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        // Pilihan Bahasa: Indonesia
                        Theme(
                          data: Theme.of(context).copyWith(
                            unselectedWidgetColor: Colors.black26,
                          ),
                          child: RadioListTile<String>.adaptive(
                            value: 'Indonesia',
                            groupValue: _selectedLanguage,
                            activeColor: Colors.black,
                            controlAffinity: ListTileControlAffinity.trailing,
                            title: const Text(
                              'Indonesia',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: const Text(
                              'Bahasa utama sistem',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13),
                            ),
                            onChanged: (value) {
                              if (value != null) _selectLanguage(value);
                            },
                          ),
                        ),
                        const Divider(
                            height: 1,
                            color: Color(0xFFF3F4F6),
                            indent: 16,
                            endIndent: 16),
                        // Pilihan Bahasa: English
                        Theme(
                          data: Theme.of(context).copyWith(
                            unselectedWidgetColor: Colors.black26,
                          ),
                          child: RadioListTile<String>.adaptive(
                            value: 'English',
                            groupValue: _selectedLanguage,
                            activeColor: Colors.black,
                            controlAffinity: ListTileControlAffinity.trailing,
                            title: const Text(
                              'English',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: const Text(
                              'English (United States)',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13),
                            ),
                            onChanged: (value) {
                              if (value != null) _selectLanguage(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- 4. CATATAN INFORMASI PERUBAHAN ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.info_outline,
                          size: 18, color: AppTheme.textSecondary),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Perubahan bahasa akan diterapkan seketika pada antarmuka memo, navigasi, dan pemberitahuan.',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // --- 5. BOKS STATUS SINKRONISASI KAMUS ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.translate,
                            size: 18,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Status sinkronisasi',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Kamus otomatis aktif',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- 6. TOMBOL AKSI UTAMA DI BAGIAN BAWAH ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: _savePreference,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Simpan preferensi',
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
}

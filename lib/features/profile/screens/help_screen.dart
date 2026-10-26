import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';

class HelpScreen extends StatefulWidget {
  final VoidCallback? onContactTeam;

  const HelpScreen({
    super.key,
    this.onContactTeam,
  });

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  // Data FAQ disesuaikan persis dengan gambar referensi baru Anda
  final List<Map<String, String>> _faqs = [
    {
      'question': 'Bagaimana cara mengundang anggota ke workspace?',
      'answer':
          'Buka menu Detail Workspace, ketuk tombol \'Undang Anggota\', lalu masukkan alamat email rekan kelompok atau bagikan 6 digit kode unik workspace.',
    },
    {
      'question': 'Apakah catatan dapat diedit bersama secara real-time?',
      'answer':
          'Ya, seluruh catatan di MemoSpace mendukung kolaborasi multi-pengguna secara real-time dengan sinkronisasi instan otomatis.',
    },
    {
      'question':
          'Bagaimana cara menyematkan lampiran berkas atau gambar pada memo?',
      'answer':
          'Saat mengedit memo, gunakan ikon klip kertas di bilah alat bawah untuk memilih berkas dokumen atau gambar dari penyimpanan lokal Anda.',
    },
    {
      'question':
          'Berapa kapasitas maksimal penyimpanan berkas di satu workspace?',
      'answer':
          'Kapasitas penyimpanan dasar berkas untuk satu workspace standar adalah hingga 100 MB per ruang kerja bersama.',
    },
    {
      'question': 'Bagaimana cara mengubah izin akses peran anggota tim?',
      'answer':
          'Hanya pemilik workspace yang dapat mengubah peran anggota dari Menu Anggota di dalam pengaturan kelola ruang kerja.',
    },
  ];

  // State untuk melacak kategori aktif (0 = Semua Topik)
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'Semua Topik',
    'Workspace',
    'Kolaborasi',
    'Penyimpanan'
  ];

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
          'Bantuan',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        // Ikon avatar di pojok kanan atas dibuang demi konsistensi alur pengaturan
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            // --- 2. SEARCH BAR ---
            TextFormField(
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari pertanyaan bantuan...',
                hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.black38, size: 20),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
                  borderSide:
                      const BorderSide(color: AppTheme.textPrimary, width: 1),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // --- 3. TOPIC PILLS (HORIZONTAL SCROLL) ---
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategoryIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.textPrimary
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            _categories[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // --- 4. SECTION TITLE: PERTANYAAN POPULER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pertanyaan Populer',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${_faqs.length} Pertanyaan',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- 5. INDIVIDUAL FAQ LIST ---
            Column(
              children: _faqs.map((faq) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      title: Text(
                        faq['question']!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      iconColor: AppTheme.textPrimary,
                      collapsedIconColor: AppTheme.textSecondary,
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          faq['answer']!,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // --- 6. NOTICE BOX & CALL TO ACTION BUTTON ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEBECEE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.headset_mic_outlined,
                          size: 20,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Masih butuh bantuan lain?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Tim dukungan MemoSpace siap membantu kendala proyekmu.',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: widget.onContactTeam,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.textPrimary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.chat_bubble_outline, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Hubungi tim',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

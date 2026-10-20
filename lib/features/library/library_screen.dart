import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _bottomNavIndex = 1; // Aktif di Library

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      // --- 1. APP BAR ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'MemoSpace',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16, left: 8),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFE8F5E9),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      'DA',
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 2. HEADER TITLE & ACTION BUTTONS ---
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Perpustakaan',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Semua berkas dan catatan tersimpan',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildHeaderActionButton(Icons.tune, 'Pilih'),
                        const SizedBox(width: 8),
                        _buildHeaderActionButton(Icons.swap_vert, null),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- 3. SEARCH BAR ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: AppTheme.pillInput(
                    hint: 'Cari di seluruh catatan & berkas...',
                    prefixIcon: const Icon(Icons.search, color: Colors.black54),
                    suffixIcon: const Icon(Icons.tune, color: Colors.black54),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- 4. HORIZONTAL FILTER PILLS ---
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterPill(Icons.grid_view, 'Semua', true),
                    const SizedBox(width: 8),
                    _buildFilterPill(Icons.description_outlined, 'Teks', false),
                    const SizedBox(width: 8),
                    _buildFilterPill(Icons.image_outlined, 'Foto', false),
                    const SizedBox(width: 8),
                    _buildFilterPill(Icons.play_circle_outline, 'Video', false),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- 5. SUB-FILTER ROW (Workspace & View Mode) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.folder_open,
                              size: 16, color: AppTheme.textSecondary),
                          SizedBox(width: 6),
                          Text('Semua Workspace',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                          Icon(Icons.arrow_drop_down, size: 16),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Text('14 Memo ditemukan',
                            style: TextStyle(
                                fontSize: 11, color: AppTheme.textSecondary)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.splitscreen,
                                  size: 16, color: AppTheme.textPrimary),
                              SizedBox(width: 4),
                              Icon(Icons.grid_view_sharp,
                                  size: 16, color: Colors.black26),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Info Urutan
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '• Menampilkan arsip terkini  • Urutkan: Terbaru',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(height: 16),

              // --- 6. LIST CARD CONTENT ---
              // KARTU 1: PDF Document Card
              _buildBaseCard(
                category: 'Proyek Robot AUV',
                badgeText: 'PDF',
                badgeColor: const Color(0xFFFEE2E2),
                badgeTextColor: const Color(0xFFEF4444),
                title: 'spek_sonar_v2.pdf & Catatan Integrasi',
                description:
                    'Panduan kalibrasi frekuensi transduser akustik 200kHz untuk modul navigasi otonom bawah air.',
                userInitials: 'FK',
                userName: 'Farhan K.',
                timeAgo: '25 mnt lalu',
                customContent: Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.picture_as_pdf,
                            color: Color(0xFFEF4444)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('spek_sonar_v2.pdf',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('1.8 MB • 12 Halaman',
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download,
                            size: 14, color: AppTheme.textPrimary),
                        label: const Text('Unduh',
                            style: TextStyle(
                                fontSize: 11, color: AppTheme.textPrimary)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 0),
                          side: const BorderSide(color: Colors.black12),
                        ),
                      )
                    ],
                  ),
                ),
              ),
// KARTU 2: Image Card
              _buildBaseCard(
                category: 'Proyek Robot AUV',
                badgeText: '2 Foto',
                badgeColor: const Color(0xFFDCFCE7),
                badgeTextColor: const Color(0xFF15803D),
                title: 'Dokumentasi Uji Rangkaian Thruster & ESC',
                description:
                    'Hasil soldering pin waterproof brushless motor dan instalasi heat sink aluminium pada kompartemen tabung akrilik.',
                userInitials: 'SR',
                userName: 'Siti R.',
                timeAgo: 'Kemarin',
                customContent: Container(
                  margin: const EdgeInsets.only(top: 12),
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: NetworkImage(
                          'unsplash.com'), // Placeholder rangkaian elektro/komponen
                      fit: BoxFit.cover,
                    ),
                  ),
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.collections, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text('2 Lampiran',
                            style:
                                TextStyle(color: Colors.white, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ),
// KARTU 3: Video Card
              _buildBaseCard(
                category: 'Proyek Robot AUV',
                badgeText: 'MP4 • 1080p',
                badgeColor: const Color(0xFFE0E7FF),
                badgeTextColor: const Color(0xFF4338CA),
                title: 'Video Uji Daya Apung (Buoyancy Test)',
                description:
                    'Pengecekan ballast netral air tawar di kolam simulasi sebelum instalasi payload kamera depth vision.',
                userInitials: 'NP',
                userName: 'Nabila P.',
                timeAgo: '2 hari lalu',
                customContent: Container(
                  margin: const EdgeInsets.only(top: 12),
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: NetworkImage(
                          'unsplash.com'), // Placeholder kolam/robot air
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: const Icon(Icons.play_arrow,
                          color: Colors.black, size: 28),
                    ),
                  ),
                ),
              ),
// KARTU 4: Text Quote Card
              _buildBaseCard(
                category: 'Skripsi Interaksi AI',
                badgeText: 'Catatan Cepat',
                badgeColor: const Color(0xFFF1F5F9),
                badgeTextColor: AppTheme.textSecondary,
                title: 'Catatan Sintesis: Analisis Kebutuhan Riset',
                description: '',
                userInitials: 'AP',
                userName: 'Anisa Putri',
                timeAgo: '3 hari lalu',
                customContent: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '"Mahasiswa butuh workspace visual yang rapi, minim distraksi & fleksibel untuk menampung ide sporadis tanpa harus memikirkan tagging manual yang rumit di awal pencatatan..."',
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: AppTheme.textPrimary,
                            height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Wrap(
                      spacing: 6,
                      children: [
                        Text('#metodologi',
                            style:
                                TextStyle(color: Colors.black45, fontSize: 12)),
                        Text('#user_interview',
                            style:
                                TextStyle(color: Colors.black45, fontSize: 12)),
                        Text('#heuristic_eval',
                            style:
                                TextStyle(color: Colors.black45, fontSize: 12)),
                      ],
                    )
                  ],
                ),
              ),
// --- 7. BOTTOM CLOUD STORAGE BANNER ---
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cloud_done_outlined,
                          color: Color(0xFF16A34A)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sinkronisasi Cloud Aktif',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(height: 2),
                          Text('1.2 GB dari 15 GB terpakai',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Kelola',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

// --- WIDGET HELPER BUILDERS ---
  Widget _buildHeaderActionButton(IconData icon, String? text) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: text != null ? 12 : 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textPrimary),
          if (text != null) ...[
            const SizedBox(width: 4),
            Text(text,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
          ]
        ],
      ),
    );
  }

  Widget _buildFilterPill(IconData icon, String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: isActive ? Colors.transparent : Colors.black12),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 16, color: isActive ? Colors.white : AppTheme.textPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseCard({
    required String category,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required String title,
    required String description,
    required String userInitials,
    required String userName,
    required String timeAgo,
    required Widget customContent,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
// Row kategori, badge tag & bookmark icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      children: [
                        const Icon(Icons.folder_open,
                            size: 12, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(category,
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(badgeText,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: badgeTextColor)),
                  ),
                ],
              ),
              const Icon(Icons.bookmark_border,
                  size: 18, color: AppTheme.textSecondary),
            ],
          ),
          const SizedBox(height: 12),
// Judul
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(description,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary, height: 1.3)),
          ],
// Konten kustom berkas (Gambar/PDF/Quote)
          customContent,
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
// Row Profil pembuat kartu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: const Color(0xFFE2E8F0),
                    child: Text(userInitials,
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary)),
                  ),
                  const SizedBox(width: 6),
                  Text(userName,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 6),
                  Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                          color: Colors.black26, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(timeAgo,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
              const Icon(Icons.more_vert,
                  size: 16, color: AppTheme.textSecondary)
            ],
          )
        ],
      ),
    );
  }
}

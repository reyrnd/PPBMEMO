import 'package:flutter/material.dart';
import 'package:memospace/core/widgets/memo_app_bar.dart';
import '../../core/app_theme.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _bottomNavIndex = 3; // Aktif di tab Aktivitas (indeks ke-3)
  int _selectedFilterIndex = 0; // 0: Semua, 1: Memo, 2: Berkas, 3: Komentar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Latar belakang diubah sedikit ke abu-abu terang agar boks putih ber-border terlihat kontras
      backgroundColor: const Color(0xFFFAFAFA),

      // --- 1. CUSTOM APP BAR ---
      appBar: const MemoAppBar(),

      // --- 2. BODY UTAMA DENGAN SATU PADDING TERPUSAT ---
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER TITLE ---
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aktivitas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Apa yang terjadi di timmu',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // --- HORIZONTAL FILTER PILLS ---
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterPill('Semua', 0),
                    const SizedBox(width: 8),
                    _buildFilterPill('Memo', 1),
                    const SizedBox(width: 8),
                    _buildFilterPill('Berkas', 2),
                    const SizedBox(width: 8),
                    _buildFilterPill('Komentar', 3),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- KELOMPOK 1: HARI INI ---
              const Text(
                'HARI INI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Boks Container Putih Ber-Border untuk Hari Ini
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Column(
                  children: [
                    _buildActivityItem(
                      avatarText: 'NP',
                      boldName: 'Nabila',
                      actionText: ' membuat memo ',
                      boldTarget: 'Rancangan UI Login',
                      workspaceName: 'Proyek PPB',
                      timeText: '10 mnt lalu',
                    ),
                    const Divider(
                        height: 1, thickness: 0.5, color: Color(0xFFE5E5E5)),
                    _buildActivityItem(
                      avatarText: 'FK',
                      boldName: 'Farhan',
                      actionText: ' mengunggah ',
                      boldTarget: 'spek_sonar_v2.pdf',
                      workspaceName: 'Robotika AUV',
                      timeText: '45 mnt lalu',
                    ),
                    const Divider(
                        height: 1, thickness: 0.5, color: Color(0xFFE5E5E5)),
                    _buildActivityItem(
                      avatarText: 'DP',
                      boldName: 'Dimas',
                      actionText: ' memberi komentar pada ',
                      boldTarget: 'Daftar User Story Sprint 2',
                      workspaceName: 'Proyek PPB',
                      timeText: '2 jam lalu',
                    ),
                    const Divider(
                        height: 1, thickness: 0.5, color: Color(0xFFE5E5E5)),
                    _buildActivityItem(
                      avatarText: 'DN',
                      boldName: 'Dina',
                      actionText: ' mengedit catatan ',
                      boldTarget: 'Kalibrasi Sensor IMU',
                      workspaceName: 'Robotika AUV',
                      timeText: '3 jam lalu',
                    ),
                    const Divider(
                        height: 1, thickness: 0.5, color: Color(0xFFE5E5E5)),
                    _buildActivityItem(
                      avatarText: 'AP',
                      boldName: 'Aditya',
                      actionText: ' mengunggah ',
                      boldTarget: 'ERD_Schema_Final.pdf',
                      workspaceName: 'Proyek PPB',
                      timeText: '5 jam lalu',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- KELOMPOK 2: KEMARIN ---
              const Text(
                'KEMARIN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Boks Container Putih Ber-Border untuk Kemarin
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Column(
                  children: [
                    _buildActivityItem(
                      avatarText: 'FR',
                      boldName: 'Fajar',
                      actionText: ' membuat memo ',
                      boldTarget: 'Notulensi Evaluasi Proker',
                      workspaceName: 'Rapat Mingguan',
                      timeText: 'Kemarin, 16:20',
                    ),
                    const Divider(
                        height: 1, thickness: 0.5, color: Color(0xFFE5E5E5)),
                    _buildActivityItem(
                      avatarText: 'BS',
                      boldName: 'Budi',
                      actionText: ' mengunggah ',
                      boldTarget: 'hasil_uji_propulsi.xlsx',
                      workspaceName: 'Robotika AUV',
                      timeText: 'Kemarin, 14:05',
                    ),
                    const Divider(
                        height: 1, thickness: 0.5, color: Color(0xFFE5E5E5)),
                    _buildActivityItem(
                      avatarText: 'SN',
                      boldName: 'Siti',
                      actionText: ' memberi komentar pada ',
                      boldTarget: 'Jadwal Sidang Skripsi',
                      workspaceName: 'Skripsi',
                      timeText: 'Kemarin, 09:30',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

// --- WIDGET HELPER 1: FILTER PILLS ---
  Widget _buildFilterPill(String label, int index) {
    final bool isActive = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1E1E1E) : const Color(0xFFF4F5F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

// --- WIDGET HELPER 2: KOMPONEN BARIS AKTIVITAS (PADDING VERTIKAL PRESISI DI DALAM BOKS) ---
  Widget _buildActivityItem({
    required String avatarText,
    required String boldName,
    required String actionText,
    required String boldTarget,
    required String workspaceName,
    required String timeText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 8.0), // Dioptimalkan untuk jarak di dalam boks
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFF4F5F7),
            child: Text(
              avatarText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textPrimary, height: 1.3),
                    children: [
                      TextSpan(
                          text: boldName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: actionText),
                      TextSpan(
                          text: boldTarget,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F5F7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.folder_open_outlined,
                          size: 10, color: Colors.black38),
                      const SizedBox(width: 4),
                      Text(
                        workspaceName,
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            timeText,
            style: const TextStyle(fontSize: 11, color: Colors.black38),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

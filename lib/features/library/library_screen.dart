import 'package:flutter/material.dart';
import 'package:memospace/core/widgets/memo_app_bar.dart';
import '../../core/app_theme.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _bottomNavIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),

      // --- 1. APP BAR ---
      appBar: const MemoAppBar(),

      // --- 2. FLOATING ACTION BUTTON ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),

      // --- 3. BODY DENGAN SATU PADDING UTAMA MENGAPIT ---
      body: SafeArea(
        child: SingleChildScrollView(
          // PADDING UTAMA DIATUR DI SINI (Menghapus padding parsial di widget-widget dalam)
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER TITLE ---
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Perpustakaan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Semua catatan dan berkas tersimpan',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // --- SEARCH BAR ---
              TextField(
                decoration: AppTheme.pillInput(
                  hint: 'Cari di seluruh catatan & berkas...',
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.black38, size: 20),
                  suffixIcon: const Icon(Icons.tune,
                      color: AppTheme.textPrimary, size: 20),
                ),
              ),
              const SizedBox(height: 20),

              // --- SUB-FILTER ROW ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Semua Workspace',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary.withOpacity(0.8)),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.keyboard_arrow_down,
                          size: 18, color: AppTheme.textPrimary),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        '14 memo',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.reorder,
                          size: 20, color: AppTheme.textPrimary),
                      const SizedBox(width: 10),
                      const Icon(Icons.grid_view_outlined,
                          size: 18, color: Colors.black26),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 8),

              // --- LIST CONTENT CARD ---
              // KARTU 1: PDF Document Card
              _buildLibraryCard(
                category: 'Robotika AUV',
                badgeText: 'PDF',
                title: 'Spesifikasi Kalibrasi Sensor Sonar...',
                description:
                    'Hasil pengujian pembacaan jarak transduser bawah air pada kedalaman 5 meter...',
                userInitials: 'DN',
                userName: 'Dina Novita',
                timeAgo: '20 mnt lalu',
                attachmentWidget: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F5F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf,
                          color: Color(0xFFEF4444), size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Spesifikasi_Transduser_AUV_v2.',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppTheme.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text('3.4 MB',
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.file_download_outlined,
                            color: AppTheme.textPrimary, size: 20),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),

              // KARTU 2: Image Gallery Card
              _buildLibraryCard(
                category: 'Robotika AUV',
                badgeText: '2 Foto',
                title: 'Dokumentasi Pengujian Daya Dorong...',
                description:
                    'Pengukuran arus motor brushless pada beban 12V dan 16V saat uji statis di kolam...',
                userInitials: 'BS',
                userName: 'Budi Santoso',
                timeAgo: 'Kemarin',
                attachmentWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              'https://picsum.photos',
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              'https://picsum.photos',
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.image_outlined,
                            color: Colors.black38, size: 16),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'uji_kolam_statik_01.jpg • 2 foto (5.8 MB)',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.file_download_outlined,
                              color: AppTheme.textPrimary, size: 20),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // KARTU 3: Text Note Card
              _buildLibraryCard(
                category: 'Rapat Mingguan',
                badgeText: null,
                title: 'Notulensi Koordinasi Sprint & Pembagian',
                description:
                    'Target integrasi sistem navigasi otonom dimajukan ke akhir pekan depan. Pembelian...',
                userInitials: 'FK',
                userName: 'Farhan Kurniawan',
                timeAgo: '3 hari lalu',
                attachmentWidget: null,
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

// --- WIDGET HELPER BUILDER KARTU UTAMA ---
  Widget _buildLibraryCard({
    required String category,
    required String? badgeText,
    required String title,
    required String description,
    required String userInitials,
    required String userName,
    required String timeAgo,
    Widget? attachmentWidget,
  }) {
    return Container(
// SEKARANG HANYA MENGGUNAKAN MARGIN VERTIKAL (Horizontal dinonaktifkan karena sudah di-cover padding utama)
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.folder_open_outlined,
                            size: 12, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          category,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (badgeText != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F5F7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ],
              ),
              const Icon(Icons.bookmark_border,
                  color: AppTheme.textSecondary, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
          ),
          if (attachmentWidget != null) ...[
            const SizedBox(height: 12),
            attachmentWidget,
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E5)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: const Color(0xFFF4F5F7),
                    child: Text(
                      userInitials,
                      style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userName,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                        color: Colors.black26, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeAgo,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const Icon(Icons.more_vert,
                  color: AppTheme.textSecondary, size: 16),
            ],
          )
        ],
      ),
    );
  }
}

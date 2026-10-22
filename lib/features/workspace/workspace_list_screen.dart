import 'package:flutter/material.dart';
import 'package:memospace/core/widgets/memo_app_bar.dart';
import 'package:memospace/features/home/data/dummy_data.dart';
import '../../core/app_theme.dart';

class WorkspaceListScreen extends StatefulWidget {
  const WorkspaceListScreen({super.key});

  @override
  State<WorkspaceListScreen> createState() => _WorkspaceListScreenState();
}

class _WorkspaceListScreenState extends State<WorkspaceListScreen> {
  // int _bottomNavIndex = 2; // Aktif di tab Workspace (indeks ke-2)
  int _selectedFilterIndex = 0; // 0: Semua, 1: Disematkan, 2: Milik saya

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
          0xFFFAFAFA), // Background abu-abu tipis agar kartu putih terlihat pop-out

      // --- 1. CUSTOM APP BAR ---
      appBar: const MemoAppBar(),

      // --- 2. FLOATING ACTION BUTTON ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),

      // --- 3. BODY UTAMA DENGAN SATU PADDING TERPUSAT ---
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
                    'Workspace',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ruang kerja timmu',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // --- SEARCH BAR ---
              TextField(
                decoration: AppTheme.pillInput(
                  hint: 'Cari workspace...',
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.black38, size: 20),
                ),
              ),
              const SizedBox(height: 16),

              // --- FILTER PILLS ---
              Row(
                children: [
                  _buildFilterPill('Semua', 0),
                  const SizedBox(width: 8),
                  _buildFilterPill('Disematkan', 1),
                  const SizedBox(width: 8),
                  _buildFilterPill('Milik saya', 2),
                ],
              ),
              const SizedBox(height: 24),

              // --- LIST KARTU WORKSPACE ---
              // Catatan: Isinya bisa di-looping dari dummyWorkspaces milik Anda.
              // Di bawah ini adalah visualisasi rendering komponen kustomnya:

              // Kelompok 1: DISEMATKAN
              const Row(
                children: [
                  Icon(Icons.push_pin_outlined,
                      size: 14, color: AppTheme.textSecondary),
                  SizedBox(width: 4),
                  Text(
                    'DISEMATKAN',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildWorkspaceItemCard(
                tag: 'Robotika',
                title: 'Proyek Robot AUV',
                description: 'Pengembangan robot bawah air autonomous tim...',
                memberCount: 6,
                memoCount: 14,
                fileCount: 6,
                updatedTime: '2 jam lalu',
                isPinned: true,
                avatars: ['FK', 'DN', 'BS'],
              ),
              _buildWorkspaceItemCard(
                tag: 'Kuliah',
                title: 'Proyek PPB',
                description: 'Tugas besar pengembangan aplikasi mobile...',
                memberCount: 4,
                memoCount: 9,
                fileCount: 15,
                updatedTime: '4 jam lalu',
                isPinned: true,
                avatars: ['SR', 'AP'],
              ),
              const SizedBox(height: 24),

              // Kelompok 2: SEMUA WORKSPACE
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SEMUA WORKSPACE',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5),
                  ),
                  Text(
                    '4 Ruang',
                    style:
                        TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildWorkspaceItemCard(
                tag: 'Organisasi',
                title: 'Rapat Mingguan',
                description: 'Koordinasi mingguan Himpunan Mahasiswa &...',
                memberCount: 8,
                memoCount: 8,
                fileCount: 12,
                updatedTime: 'kemarin',
                isPinned: false,
                avatars: ['NP', 'FR', 'DN'],
              ),
              _buildWorkspaceItemCard(
                tag: 'Pribadi',
                title: 'Skripsi',
                description:
                    'Catatan riset literatur, draft bab 1-4, dan logbook...',
                memberCount: 1,
                memoCount: 12,
                fileCount: 4,
                updatedTime: '3 jam lalu',
                isPinned: false,
                avatars: ['AP'],
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS 1: FILTER PILLS ---
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

  // --- WIDGET HELPERS 2: SLICING KARTU WORKSPACE KUSTOM ---
  Widget _buildWorkspaceItemCard({
    required String tag,
    required String title,
    required String description,
    required int memberCount,
    required int memoCount,
    required int fileCount,
    required String updatedTime,
    required bool isPinned,
    required List<String> avatars,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Tag Kategori & Icon Pin Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary),
                ),
              ),
              Icon(
                isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                size: 16,
                color: isPinned ? AppTheme.textPrimary : Colors.black26,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Judul dan Ringkasan Deskripsi
          Text(
            title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          // Tumpukan Avatar Kru (Avatar Stack) & Total Anggota
          Row(
            children: [
              SizedBox(
                width: (avatars.length * 14.0) + 16.0,
                height: 24,
                child: Stack(
                  children: List.generate(avatars.length, (i) {
                    return Positioned(
                      left: i * 14.0,
                      child: CircleAvatar(
                        radius: 11,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: const Color(0xFFE5E5E5),
                          child: Text(
                            avatars[i],
                            style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$memberCount anggota',
                style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E5)),
          const SizedBox(height: 12),
          // Deretan Metadata Bawah (Memo, Berkas, Waktu)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.description_outlined,
                      size: 14, color: Colors.black38),
                  const SizedBox(width: 4),
                  Text('$memoCount memo',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                  const SizedBox(width: 8),
                  const Text('•',
                      style: TextStyle(color: Colors.black26, fontSize: 11)),
                  const SizedBox(width: 8),
                  const Icon(Icons.folder_open_outlined,
                      size: 14, color: Colors.black38),
                  const SizedBox(width: 4),
                  Text('$fileCount berkas',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
              Text(
                'Diperbarui $updatedTime',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/app_theme.dart'; // Pastikan path tema Anda benar

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // --- 1. CUSTOM APP BAR ---
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
          IconButton(
            icon: const Icon(Icons.notifications_none,
                color: AppTheme.textPrimary),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 8),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.textPrimary,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 2. GREETING HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'Selamat pagi',
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary),
                          ),
                          SizedBox(width: 4),
                          Text('👋', style: TextStyle(fontSize: 24)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                                color: Colors.black, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Ada 3 pembaruan penting di timmu hari ini.',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Avatar lingkaran kanan dengan inisial DA
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFE8F5E9),
                    child: Stack(
                      children: [
                        const Center(
                          child: Text(
                            'DA',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- 3. SEARCH BAR ---
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F7),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari memo atau workspace...',
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.black54),
                    suffixIcon: Icon(Icons.tune, color: Colors.black54),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- 4. QUICK ACTION PILLS ---
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildActionButton(
                        Icons.space_dashboard_outlined, 'Workspace Baru', true),
                    const SizedBox(width: 8),
                    _buildActionButton(
                        Icons.note_add_outlined, '+ Memo', false),
                    const SizedBox(width: 8),
                    _buildActionButton(Icons.filter_list, 'Filter', false),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // --- 5. SECTION: WORKSPACE SAYA ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Workspace Saya •',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Row(
                      children: [
                        Text('Lihat Semua (4)',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13)),
                        Icon(Icons.chevron_right,
                            size: 16, color: AppTheme.textSecondary),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildWorkspaceCard(
                        'Robotika & Elektro',
                        'Proyek Robot AUV',
                        '18 Memo',
                        '6 Berkas CAD',
                        '12 mnt lalu',
                        true),
                    const SizedBox(width: 12),
                    _buildWorkspaceCard(
                        'Semester 6',
                        'Rekayasa Perangkat Lunak',
                        '12 Memo',
                        '3 Lampiran',
                        '3 jam lalu',
                        false),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // --- 6. SECTION: MEMO TERBARU ---
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Memo Terbaru',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary),
                      ),
                      SizedBox(width: 8),
                      Badge(
                        label: Text('3 baru'),
                        backgroundColor: Color(0xFFF4F5F7),
                        textColor: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                  Text(
                    'Arsip',
                    style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        decoration: TextDecoration.underline),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // List Memo Vertikal
              _buildMemoCard(
                category: 'Proyek Robot AUV',
                title: 'Catatan Rapat Tim: Pembagian Modul Sensor',
                content:
                    'Pengujian sensor sonar bawah air dijadwalkan hari Jumat di kolam rekayasa. Pastikan modul ESP32 dan waterproof...',
                fileName: 'spek_sonar_v2.pdf',
                author: 'Farhan K.',
                time: '25 mnt lalu',
                isPinned: true,
              ),
              const SizedBox(height: 12),
              _buildMemoCard(
                category: 'Rekayasa Perangkat Lunak',
                title: 'Daftar User Story Sprint 2',
                content:
                    'Integrasi autentikasi Google Sign-In dan perbaikan state management Riverpod untuk halaman profil dan...',
                taskCount: '8/10 tugas',
                author: 'Dimas A.',
                time: '3 jam lalu',
                isPinned: false,
                isBookmarked: true,
              ),
              const SizedBox(height: 28),

              // --- 7. SECTION: AKTIVITAS TIM ---
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Aktivitas Tim',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary),
                  ),
                  Text(
                    'Hari ini',
                    style: TextStyle(color: Colors.black38, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildActivityRow(
                        'FK',
                        'Farhan K. menambahkan 3 foto ke memo',
                        '"Pengujian Thruster AUV"',
                        '15 mnt lalu'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(color: Color(0xFFE0E0E0)),
                    ),
                    _buildActivityRow('NP', 'Nabila P. menandai selesai pada',
                        '"Revisi Diagram ERD"', '1 jam lalu'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
// --- 8. FLOATING BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.textPrimary,
        unselectedItemColor: Colors.black38,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.folder_open), label: 'Workspace'),
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view), label: 'Kategori'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined), label: 'Profil'),
        ],
      ),
    );
  }

// --- WIDGET BUILDER HELPER ---
// Tombol Cepat (Pills)
  Widget _buildActionButton(IconData icon, String label, bool isPrimary) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isPrimary ? AppTheme.textPrimary : const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon,
              size: 18, color: isPrimary ? Colors.white : AppTheme.textPrimary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isPrimary ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

// Kartu Workspace Horizontal
  Widget _buildWorkspaceCard(String category, String title, String memoCount,
      String fileCount, String time, bool hasPin) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFF4F5F7),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(category,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54)),
              ),
              if (hasPin)
                const Icon(Icons.push_pin,
                    size: 14, color: AppTheme.textPrimary),
            ],
          ),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('📁 $memoCount  •  📄 $fileCount',
              style: const TextStyle(fontSize: 11, color: Colors.black38)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                width: 50,
                child: Stack(
                  children: [
                    CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.black,
                        child: Text('F',
                            style:
                                TextStyle(fontSize: 8, color: Colors.white))),
                    Positioned(
                        left: 12,
                        child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.grey,
                            child: Text('S',
                                style: TextStyle(
                                    fontSize: 8, color: Colors.white)))),
                  ],
                ),
              ),
              Text(time,
                  style: const TextStyle(fontSize: 10, color: Colors.black38)),
            ],
          )
        ],
      ),
    );
  }

// Kartu Memo Vertikal
  Widget _buildMemoCard({
    required String category,
    required String title,
    required String content,
    String? fileName,
    String? taskCount,
    required String author,
    required String time,
    required bool isPinned,
    bool isBookmarked = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFF4F5F7),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(category,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54)),
              ),
              Icon(
                isPinned
                    ? Icons.push_pin
                    : (isBookmarked ? Icons.bookmark_border : Icons.more_horiz),
                size: 16,
                color: Colors.black54,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 6),
          Text(content,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          if (fileName != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F7),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.picture_as_pdf,
                      size: 14, color: Colors.redAccent),
                  const SizedBox(width: 6),
                  Text(fileName,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary)),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (taskCount != null) ...[
            Row(
              children: [
                const Icon(Icons.assignment_turned_in_outlined,
                    size: 14, color: Colors.black54),
                const SizedBox(width: 6),
                Text(taskCount,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(author,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              Text('•  $time',
                  style: const TextStyle(fontSize: 12, color: Colors.black38)),
            ],
          )
        ],
      ),
    );
  }

// Baris Riwayat Aktivitas Tim
  Widget _buildActivityRow(
      String initial, String leadingText, String targetText, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: const Color(0xFFF4F5F7),
          child: Text(initial,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 13, height: 1.3),
                  children: [
                    TextSpan(text: '$leadingText '),
                    TextSpan(
                        text: targetText,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline)),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(time,
                  style: const TextStyle(fontSize: 11, color: Colors.black38)),
            ],
          ),
        )
      ],
    );
  }
}

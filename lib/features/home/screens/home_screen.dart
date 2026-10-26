import 'package:flutter/material.dart';
import 'package:memospace/core/widgets/memo_app_bar.dart';
import 'package:memospace/core/widgets/section_header.dart';
import 'package:memospace/features/home/widgets/quick_action_button.dart';
import 'package:memospace/features/activity/data/dummy_activities.dart';
import 'package:memospace/features/activity/widgets/activity_row.dart';
import 'package:memospace/features/memo/data/dummy_memos.dart';
import 'package:memospace/features/memo/screens/memo_editor_screen.dart';
import 'package:memospace/features/workspace/data/dummy_workspaces.dart';
import 'package:memospace/features/workspace/screens/create_join_workspace_screen.dart';
import 'package:memospace/features/workspace/screens/workspace_detail_screen.dart';
import 'package:memospace/features/search/screens/search_screen.dart';
import '../../../core/app_theme.dart';

import '../../workspace/widgets/workspace_card.dart';
import '../../memo/widgets/memo_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onSeeAllWorkspaces, onSeeAllActivities, onSeeAllMemos;

  const HomeScreen(
      {super.key,
      this.onSeeAllWorkspaces,
      this.onSeeAllActivities,
      this.onSeeAllMemos});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // --- 1. APP BAR ---
      appBar: const MemoAppBar(),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 2. GREETING HEADER ---
              const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Selamat pagi',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary),
                            ),
                            SizedBox(width: 4),
                            Text('👋', style: TextStyle(fontSize: 22)),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Ada 3 pembaruan penting di timmu hari ini.',
                          style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // --- 3. SEARCH BAR ---
              TextField(
                readOnly: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SearchScreen(),
                  ),
                ),
                decoration: AppTheme.pillInput(
                  hint: 'Cari memo atau workspace...',
                  prefixIcon: const Icon(Icons.search, color: Colors.black38),
                ),
              ),
              const SizedBox(height: 18),

              // --- 4. QUICK ACTION PILLS ---
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: QuickActionButton(
                      icon: Icons.create_new_folder_outlined,
                      label: 'Workspace Baru',
                      isPrimary: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const CreateJoinWorkspaceScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: QuickActionButton(
                      icon: Icons.add,
                      label: 'Memo',
                      isPrimary: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MemoEditorScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- 5. SECTION: WORKSPACE SAYA ---
              SectionHeader(
                title: 'Workspace Saya',
                onAction: widget.onSeeAllWorkspaces,
              ),
              const SizedBox(height: 12),
              dummyWorkspaces.isEmpty
                  ? Container(
                      width: double.infinity,
                      height:
                          140, // Disamakan dengan tinggi ListView agar tata letak tidak berubah
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEAEAEA)),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open_outlined,
                            size: 40,
                            color: Colors.black38,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Belum ada workspace',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Buat ruang kerja baru untuk mengatur proyekmu.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      height:
                          140, // Atur tinggi boks agar pas dengan WorkspaceCard Anda
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...dummyWorkspaces.take(5).map((w) => Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const WorkspaceDetailScreen()),
                                  ),
                                  child: WorkspaceCard(workspace: w),
                                ),
                              )),
                        ],
                      ),
                    ),
              const SizedBox(height: 24),

              // --- 6. SECTION: MEMO TERBARU ---
              SectionHeader(
                title: 'Memo Terbaru',
                onAction: widget.onSeeAllMemos,
              ),
              const SizedBox(height: 4),
              // Looping data memo tanpa badge / arsip (Sesuai Desain Baru)
              dummyMemos.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 32, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(
                            0xFFF8F9FA), // Latar belakang abu-abu sangat muda
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEAEAEA)),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_alt_outlined,
                            size: 48,
                            color: Colors.black38,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Belum ada memo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Buat memo pertamamu untuk mencatat ide atau tugas.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: dummyMemos
                          .take(5)
                          .map((m) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const MemoEditorScreen()),
                                  ),
                                  child: MemoCard(memo: m),
                                ),
                              ))
                          .toList(),
                    ),
              const SizedBox(height: 24),

              // --- 7. SECTION: AKTIVITAS TIM ---
              SectionHeader(
                title: 'Aktivitas Tim',
                onAction: widget.onSeeAllActivities,
              ),
              const SizedBox(height: 12),
              // Daftar Aktivitas tanpa pembungkus garis kotak luar (Sesuai Desain Baru)
              dummyActivities.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 32, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(
                            0xFFF8F9FA), // Latar belakang abu-abu muda yang serasi
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none_outlined,
                            size: 48,
                            color: Colors.black38,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Belum ada aktivitas',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Semua riwayat pembaruan atau kegiatan timmu akan muncul di sini.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // Gunakan math.min agar tidak error jika jumlah data kurang dari 4
                          for (var i = 0;
                              i <
                                  (dummyActivities.length < 4
                                      ? dummyActivities.length
                                      : 4);
                              i++) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: ActivityRow(activity: dummyActivities[i]),
                            ),
                            if (i !=
                                (dummyActivities.length < 4
                                    ? dummyActivities.length - 1
                                    : 3))
                              const Divider(
                                  color: Color(0xFFE0E0E0), height: 1),
                          ],
                        ],
                      ),
                    ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDER HELPER ---
  // Tombol Cepat (Pills)
}

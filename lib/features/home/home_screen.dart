import 'package:flutter/material.dart';
import 'package:memospace/core/widgets/memo_app_bar.dart';
import 'package:memospace/features/activity/widgets/activity_row.dart';
import 'package:memospace/features/workspace/workspace_screen.dart';
import '../../core/app_theme.dart';

import '../workspace/widgets/workspace_card.dart';
import '../memo/widgets/memo_card.dart';
import 'data/dummy_data.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onSeeAllWorkspaces, onSeeAllActivities;

  const HomeScreen(
      {super.key, this.onSeeAllWorkspaces, this.onSeeAllActivities});

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
                    child: _buildActionButton(Icons.create_new_folder_outlined,
                        'Workspace Baru', true),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _buildActionButton(Icons.add, 'Memo', false),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- 5. SECTION: WORKSPACE SAYA ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Workspace Saya',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary),
                  ),
                  TextButton(
                    onPressed: widget.onSeeAllWorkspaces,
                    child: Row(
                      children: [
                        Text('Lihat Semua (${dummyActivities.length})',
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13)),
                        const Icon(Icons.chevron_right,
                            size: 16, color: AppTheme.textSecondary),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height:
                    140, // Atur tinggi boks agar pas dengan WorkspaceCard Anda
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...dummyWorkspaces.map((w) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const WorkspaceScreen()),
                            ),
                            child: WorkspaceCard(workspace: w),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- 6. SECTION: MEMO TERBARU ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Memo Terbaru',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Row(
                      children: [
                        Text('Lihat Semua',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Looping data memo tanpa badge / arsip (Sesuai Desain Baru)
              Column(
                children: dummyMemos
                    .map((m) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: MemoCard(memo: m),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),

              // --- 7. SECTION: AKTIVITAS TIM ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Aktivitas Tim',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary),
                  ),
                  TextButton(
                    onPressed: widget.onSeeAllActivities,
                    child: const Row(
                      children: [
                        Text('Lihat Semua',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Daftar Aktivitas tanpa pembungkus garis kotak luar (Sesuai Desain Baru)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    for (var i = 0; i < dummyActivities.length; i++) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ActivityRow(activity: dummyActivities[i]),
                      ),
                      if (i != dummyActivities.length - 1)
                        const Divider(color: Color(0xFFE0E0E0), height: 1),
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
  Widget _buildActionButton(IconData icon, String label, bool isPrimary) {
    return Container(
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF1E1E1E) : const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(20),
        border: isPrimary
            ? null
            : Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 18, color: isPrimary ? Colors.white : AppTheme.textPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isPrimary ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

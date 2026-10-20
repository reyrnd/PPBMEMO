import 'package:flutter/material.dart';
import 'package:memospace/features/activity/widgets/activity_row.dart';
import 'package:memospace/features/workspace/workspace_screen.dart';
import '../../core/app_theme.dart';

import '../workspace/widgets/workspace_card.dart';
import '../memo/widgets/memo_card.dart';
import 'data/dummy_data.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onSeeAllWorkspaces;

  const HomeScreen({super.key, this.onSeeAllWorkspaces});

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
                ],
              ),
              const SizedBox(height: 20),

              // --- 3. SEARCH BAR ---
              TextField(
                decoration: AppTheme.pillInput(
                  hint: 'Cari memo atau workspace...',
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  suffixIcon: const Icon(Icons.tune, color: Colors.black54),
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
                    onPressed: widget.onSeeAllWorkspaces,
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
                    ...dummyWorkspaces
                        .where((w) => w.hasPin)
                        .map((w) => Padding(
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
                    const SizedBox(width: 12),
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
              ...dummyMemos.map((m) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: MemoCard(memo: m),
                  )),
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
              const SizedBox(height: 20),
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
}

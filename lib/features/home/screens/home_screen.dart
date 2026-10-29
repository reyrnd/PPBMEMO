import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memospace/core/widgets/memo_app_bar.dart';
import 'package:memospace/core/widgets/section_header.dart';
import 'package:memospace/features/home/widgets/quick_action_button.dart';
import 'package:memospace/features/activity/data/activity_repository.dart';
import 'package:memospace/features/activity/models/activity.dart';
import 'package:memospace/features/activity/widgets/activity_row.dart';
import 'package:memospace/features/memo/cubit/memo_cubit.dart';
import 'package:memospace/features/memo/screens/memo_editor_screen.dart';
import 'package:memospace/features/workspace/cubit/workspace_cubit.dart';
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
  late final Stream<List<Activity>> _activities;

  @override
  void initState() {
    super.initState();
    _activities = ActivityRepository().watchAllMyActivities();
  }

  void _openMemoEditor(BuildContext context) {
    final workspaces = context.read<WorkspaceCubit>().state;
    if (workspaces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Buat atau gabung workspace terlebih dahulu.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MemoEditorScreen(workspaceId: workspaces.first.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workspaces = context.watch<WorkspaceCubit>().state;
    final memos = context.watch<MemoCubit>().state;

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
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
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
                        const SizedBox(height: 6),
                        Text(
                          '${memos.length} memo tersimpan di ${workspaces.length} workspace.',
                          style: const TextStyle(
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
                            builder: (_) => CreateJoinWorkspaceScreen(
                              onCreate: (data) async {
                                await context.read<WorkspaceCubit>().create(
                                      data.name,
                                      data.description,
                                      data.category,
                                      data.pinOnHome,
                                    );
                                if (context.mounted) Navigator.pop(context);
                              },
                              onJoin: (code) async {
                                try {
                                  await context
                                      .read<WorkspaceCubit>()
                                      .join(code);
                                  if (context.mounted) Navigator.pop(context);
                                } catch (error) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error.toString())),
                                  );
                                }
                              },
                            ),
                          ),
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
                      onTap: () => _openMemoEditor(context),
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
              workspaces.isEmpty
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
                          ...workspaces.take(5).map((w) => Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => WorkspaceDetailScreen(
                                              workspace: w,
                                            )),
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
              memos.isEmpty
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
                      children: memos
                          .take(5)
                          .map((m) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => MemoEditorScreen(
                                              workspaceId: m.workspaceId,
                                              memo: m,
                                            )),
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
              _buildRecentActivities(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return StreamBuilder<List<Activity>>(
      stream: _activities,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text(
            'Aktivitas gagal dimuat.',
            style: TextStyle(color: AppTheme.textSecondary),
          );
        }

        final activities =
            snapshot.data?.take(4).toList() ?? const <Activity>[];
        if (activities.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Belum ada aktivitas.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              for (var index = 0; index < activities.length; index++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ActivityRow(activity: activities[index]),
                ),
                if (index < activities.length - 1)
                  const Divider(color: AppTheme.border, height: 1),
              ],
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET BUILDER HELPER ---
  // Tombol Cepat (Pills)
}

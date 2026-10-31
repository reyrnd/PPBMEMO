import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/avatar_stack.dart';
import '../../activity/data/activity_repository.dart';
import '../../activity/models/activity.dart';
import '../../activity/screens/activity_screen.dart';
import '../../memo/cubit/memo_cubit.dart';
import '../../memo/models/memo.dart';
import '../../memo/screens/memo_editor_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../shell/main_shell.dart';
import '../../workspace/cubit/workspace_cubit.dart';
import '../../workspace/models/workspace.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildSpaceCard(context),
              const SizedBox(height: 24),
              _buildSectionTitle('Quick actions'),
              const SizedBox(height: 12),
              _buildQuickActionsGrid(context),
              const SizedBox(height: 24),
              _buildSectionTitle(
                'Recent memos',
                actionText: 'See all',
                onAction: () => MainShellScope.of(context)?.switchTab(1),
              ),
              const SizedBox(height: 12),
              _buildRecentMemosList(),
              const SizedBox(height: 24),
              _buildSectionTitle(
                'Your workspaces',
                actionText: 'Manage',
                onAction: () => MainShellScope.of(context)?.switchTab(2),
              ),
              const SizedBox(height: 12),
              _buildWorkspacesCard(context),
              const SizedBox(height: 24),
              _buildSectionTitle(
                'Latest activity',
                actionText: 'View all',
                onAction: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ActivityScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _buildActivityList(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Menampilkan bottom sheet pemilihan workspace sebelum membuka MemoEditorScreen
  void _openNewMemo(BuildContext context, {bool isChecklist = false}) {
    final workspaces = context.read<WorkspaceCubit>().state;
    if (workspaces.isEmpty) {
      showWorkspaceChoiceSheet(context: context);
      return;
    }

    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => SheetFrame(
        title: isChecklist ? 'New checklist' : 'New memo',
        description:
            'Choose which workspace this ${isChecklist ? 'checklist' : 'memo'} will be saved to.',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: workspaces.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, index) {
                  final ws = workspaces[index];
                  final isOwner = ws.ownerId == currentUid;
                  final isEven = index.isEven;

                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MemoEditorScreen(
                              workspaceId: ws.id,
                              initialIsChecklist: isChecklist,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [AppTheme.shadowSoft],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isEven ? AppTheme.ink : AppTheme.mint,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.grid_view_rounded,
                                color: isEven ? Colors.white : AppTheme.olive,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          ws.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.ink,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isOwner
                                              ? AppTheme.peach
                                              : AppTheme.surface,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          isOwner ? 'OWNER' : 'MEMBER',
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w700,
                                            color: isOwner
                                                ? AppTheme.caramel
                                                : AppTheme.muted,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${ws.members.length} members · ${ws.memoCount} memos',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.faint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.faint,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.pop(sheetCtx);
                showCreateWorkspaceSheet(context: context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.line),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, size: 15, color: AppTheme.ink),
                    SizedBox(width: 6),
                    Text(
                      'Create new workspace',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firstName =
        (user?.displayName != null && user!.displayName!.isNotEmpty)
            ? user.displayName!.split(' ').first
            : 'Naya';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MEMOSPACE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
                color: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Good morning, $firstName',
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                color: AppTheme.ink,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildIconButton(
              Icons.search_rounded,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
            ),
            const SizedBox(width: 8),
            _buildIconButton(
              Icons.notifications_none_rounded,
              hasBadge: true,
              onTap: () => showNotificationsSheet(context: context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton(
    IconData icon, {
    bool hasBadge = false,
    required VoidCallback onTap,
  }) {
    return Stack(
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [AppTheme.shadowSoft],
              ),
              child: Icon(icon, color: AppTheme.ink, size: 19),
            ),
          ),
        ),
        if (hasBadge)
          Positioned(
            right: 10,
            top: 9,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: AppTheme.caramel,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSpaceCard(BuildContext context) {
    return BlocBuilder<MemoCubit, MemoState>(
      builder: (context, memoState) {
        final memos =
            memoState is MemoLoaded ? memoState.memos : const <Memo>[];
        final memoCount = memos.length;
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        final updatedThisWeek =
            memos.where((m) => m.updatedAt.isAfter(weekAgo)).length;

        return Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppTheme.ink,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [AppTheme.shadowCard],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -28,
                top: -32,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -8,
                top: 28,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white.withValues(alpha: 0.85),
                                size: 12,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'YOUR SPACE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => showActionSheet(
                            context: context,
                            title: 'Your space',
                            description: 'Manage your personal MemoSpace.',
                            options: const [
                              'View space details',
                              'Share weekly summary',
                            ],
                            primaryButtonLabel: 'Open',
                            onApplied: (selected) {
                              Future.delayed(
                                const Duration(milliseconds: 450),
                                () {
                                  if (!context.mounted) return;
                                  if (selected == 'Share weekly summary') {
                                    showWeeklySummarySheet(context: context);
                                  } else {
                                    showSpaceDetailsSheet(context: context);
                                  }
                                },
                              );
                            },
                          ),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.more_horiz_rounded,
                              color: Colors.white.withValues(alpha: 0.55),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(
                      width: 255,
                      child: Text(
                        'Turn your ideas into something real.',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.15,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$memoCount memos · $updatedThisWeek updated this week',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => showWeeklySummarySheet(context: context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.ios_share_rounded,
                                  size: 11,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Weekly summary',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(
    String title, {
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.ink,
            letterSpacing: -0.3,
          ),
        ),
        if (actionText != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              child: Row(
                children: [
                  Text(
                    actionText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.muted,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: AppTheme.muted,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      {
        'icon': Icons.description_outlined,
        'label': 'Note',
        'subtitle': 'Create a new memo',
        'color': AppTheme.peach,
        'onTap': () => _openNewMemo(context),
      },
      {
        'icon': Icons.people_outline_rounded,
        'label': 'Workspace',
        'subtitle': 'Create or join space',
        'color': AppTheme.mint,
        'onTap': () => showWorkspaceChoiceSheet(context: context),
      },
    ];

    return Row(
      children: List.generate(actions.length, (index) {
        final item = actions[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 6,
              right: index == actions.length - 1 ? 0 : 6,
            ),
            child: GestureDetector(
              onTap: item['onTap'] as VoidCallback,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [AppTheme.shadowSoft],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: item['color'] as Color,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: AppTheme.ink,
                        size: 19,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item['label'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['subtitle'] as String,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.faint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRecentMemosList() {
    return BlocBuilder<MemoCubit, MemoState>(
      builder: (context, state) {
        if (state is MemoLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: AppTheme.ink),
            ),
          );
        }
        if (state is MemoLoaded) {
          final memos = state.memos;
          if (memos.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [AppTheme.shadowSoft],
              ),
              child: const Text(
                'No memos found yet. Tap "New memo" above to capture an idea.',
                style: TextStyle(
                  color: AppTheme.faint,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          return Column(
            children: memos.take(3).map((memo) {
              IconData currentIcon = Icons.bolt_rounded;
              Color iconBg = AppTheme.peach;
              Color iconColor = AppTheme.caramel;
              final lowerTag = memo.tag.toLowerCase();
              if (lowerTag == 'studio' ||
                  lowerTag == 'checklist' ||
                  memo.checklist.isNotEmpty) {
                currentIcon = Icons.check_circle_outline_rounded;
                iconBg = AppTheme.mint;
                iconColor = AppTheme.olive;
              } else if (lowerTag == 'product' || lowerTag == 'research') {
                currentIcon = Icons.menu_book_rounded;
                iconBg = AppTheme.lilac;
                iconColor = AppTheme.plum;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: _buildMemoCard(
                  icon: currentIcon,
                  iconBg: iconBg,
                  iconColor: iconColor,
                  title: memo.title,
                  preview: memo.preview,
                  meta: memo.meta.isEmpty ? 'Edited recently' : memo.meta,
                  tag: memo.tag,
                  dueDate: memo.dueDate,
                  progress: memo.progress,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MemoEditorScreen(
                        memoId: memo.id,
                        workspaceId: memo.workspaceId,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMemoCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String preview,
    required String meta,
    required String tag,
    required String dueDate,
    required VoidCallback onTap,
    double? progress,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [AppTheme.shadowSoft],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.more_horiz_rounded,
                        size: 17,
                        color: AppTheme.faint,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.muted,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  if (progress != null) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: AppTheme.soft,
                      valueColor: const AlwaysStoppedAnimation(AppTheme.olive),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        meta,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.faint,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '•',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.faint,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.muted,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (dueDate.isNotEmpty) DeadlineBadge(date: dueDate),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspacesCard(BuildContext context) {
    return BlocBuilder<WorkspaceCubit, List<Workspace>>(
      builder: (context, workspaces) {
        if (workspaces.isEmpty) {
          return InkWell(
            onTap: () => showWorkspaceChoiceSheet(context: context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [AppTheme.shadowSoft],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: AppTheme.muted,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No workspaces yet. Tap to create or join one.',
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final workspace = workspaces.first;
        final memoState = context.watch<MemoCubit>().state;
        final allMemos =
            memoState is MemoLoaded ? memoState.memos : const <Memo>[];
        final wsMemos =
            allMemos.where((m) => m.workspaceId == workspace.id).toList();
        final targetMemos = wsMemos.isNotEmpty ? wsMemos : allMemos;
        final todoCount =
            targetMemos.where((m) => m.status == 'todo').length;
        final doingCount =
            targetMemos.where((m) => m.status == 'doing').length;
        final doneCount = targetMemos
            .where((m) => m.status == 'done' || (m.progress ?? 0.0) >= 1.0)
            .length;
        final memberCount =
            workspace.members.isEmpty ? 1 : workspace.members.length;

        return InkWell(
          onTap: () => MainShellScope.of(context)?.switchTab(2),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [AppTheme.shadowSoft],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.ink,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.grid_view_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workspace.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$memberCount members · ${wsMemos.length} memos',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AvatarStack(
                      members: workspace.members,
                      maxAvatars: 3,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatItem(value: '$todoCount', label: 'To do'),
                      ),
                      Container(width: 1, height: 20, color: AppTheme.line),
                      Expanded(
                        child:
                            _StatItem(value: '$doingCount', label: 'Working'),
                      ),
                      Container(width: 1, height: 20, color: AppTheme.line),
                      Expanded(
                        child: _StatItem(value: '$doneCount', label: 'Done'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToActivityTarget({
    required BuildContext context,
    String memoId = '',
    String workspaceId = '',
    String targetTitle = '',
  }) {
    final memoState = context.read<MemoCubit>().state;
    final memos = memoState is MemoLoaded ? memoState.memos : const <Memo>[];
    final workspaces = context.read<WorkspaceCubit>().state;

    Memo? matchedMemo;
    if (memoId.isNotEmpty) {
      final found = memos.where((m) => m.id == memoId);
      if (found.isNotEmpty) matchedMemo = found.first;
    }
    if (matchedMemo == null && targetTitle.isNotEmpty) {
      final found = memos.where(
        (m) => m.title.toLowerCase() == targetTitle.toLowerCase(),
      );
      if (found.isNotEmpty) matchedMemo = found.first;
    }

    if (matchedMemo != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MemoEditorScreen(
            memoId: matchedMemo!.id,
            workspaceId: matchedMemo.workspaceId,
          ),
        ),
      );
      return;
    }

    if (workspaceId.isNotEmpty) {
      final foundWs = workspaces.where((w) => w.id == workspaceId);
      if (foundWs.isNotEmpty) {
        MainShellScope.of(context)?.switchTab(2);
        return;
      }
    }
    if (memos.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MemoEditorScreen(
            memoId: memos.first.id,
            workspaceId: memos.first.workspaceId,
          ),
        ),
      );
    }
  }

  Widget _buildActivityList() {
    return StreamBuilder<List<Activity>>(
      stream: ActivityRepository().watchAllMyActivities(),
      builder: (context, snapshot) {
        final memoState = context.watch<MemoCubit>().state;
        final memos =
            memoState is MemoLoaded ? memoState.memos : const <Memo>[];
        final activities = snapshot.data ?? const <Activity>[];
        if (activities.isEmpty) {
          if (memos.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [AppTheme.shadowSoft],
              ),
              child: const Text(
                'No recent activity yet. Create or update a memo to see live updates here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final recentMemos = memos.take(3).toList();
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [AppTheme.shadowSoft],
            ),
            child: Column(
              children: List.generate(recentMemos.length, (index) {
                final m = recentMemos[index];
                final isLast = index == recentMemos.length - 1;
                final actorName =
                    m.authorName.isEmpty ? 'Naya' : m.authorName.split(' ').first;
                final initials = m.assignee.isNotEmpty ? m.assignee : 'NA';
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                  child: _buildActivityRow(
                    initials: initials,
                    bgColor: index.isEven ? AppTheme.caramel : AppTheme.olive,
                    actor: actorName,
                    action: m.checklist.isNotEmpty
                        ? 'updated checklist in'
                        : 'updated memo',
                    subject: m.title.isEmpty ? 'Untitled memo' : m.title,
                    time: DateFormatter.getRelativeTimeText(m.updatedAt),
                    onTap: () => _navigateToActivityTarget(
                      context: context,
                      memoId: m.id,
                      workspaceId: m.workspaceId,
                      targetTitle: m.title,
                    ),
                  ),
                );
              }),
            ),
          );
        }

        final visible = activities.take(3).toList();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [AppTheme.shadowSoft],
          ),
          child: Column(
            children: List.generate(visible.length, (index) {
              final activity = visible[index];
              final isLast = index == visible.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                child: _buildActivityRow(
                  initials: activity.initials,
                  bgColor: index.isEven ? AppTheme.caramel : AppTheme.olive,
                  actor: activity.initials,
                  action: activity.action,
                  subject: activity.target,
                  time: DateFormatter.getRelativeTimeText(activity.time),
                  onTap: () => _navigateToActivityTarget(
                    context: context,
                    memoId: activity.memoId,
                    workspaceId: activity.workspaceId,
                    targetTitle: activity.target,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildActivityRow({
    required String initials,
    required Color bgColor,
    required String actor,
    required String action,
    required String subject,
    required String time,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.muted,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: '$actor ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                        ),
                      ),
                      TextSpan(text: '$action '),
                      TextSpan(
                        text: subject,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                time,
                style: const TextStyle(
                  color: AppTheme.faint,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 15,
                color: AppTheme.faint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppTheme.faint,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../activity/data/activity_repository.dart';
import '../../activity/models/activity.dart';
import '../../activity/screens/activity_screen.dart';
import '../../memo/cubit/memo_cubit.dart';
import '../../memo/models/memo.dart';
import '../../memo/screens/memo_editor_screen.dart';
import '../board/board_view.dart';
import '../board/canvas_board.dart';
import '../board/kanban_board.dart';
import '../cubit/workspace_cubit.dart';
import '../models/workspace.dart';

class WorkspaceDetailScreen extends StatefulWidget {
  final Workspace workspace;

  const WorkspaceDetailScreen({super.key, required this.workspace});

  @override
  State<WorkspaceDetailScreen> createState() => _WorkspaceDetailScreenState();
}

class _WorkspaceDetailScreenState extends State<WorkspaceDetailScreen> {
  String _activeTab = 'Overview';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: BlocBuilder<MemoCubit, MemoState>(
          builder: (context, state) {
            final workspaceMemos = state is MemoLoaded
                ? state.memos
                    .where((memo) => memo.workspaceId == widget.workspace.id)
                    .toList()
                : <Memo>[];
            final isLoading = state is MemoLoading;
            final totalFiles = workspaceMemos.fold<int>(
              0,
              (sum, m) => sum + m.attachments.length,
            );
            final totalChecklistTasks = workspaceMemos.fold<int>(
              0,
              (sum, m) => sum + m.checklist.length,
            );

            return RefreshIndicator(
              color: AppTheme.ink,
              backgroundColor: Colors.white,
              onRefresh: () async {
                await Future.wait([
                  context.read<WorkspaceCubit>().refresh(),
                  context.read<MemoCubit>().refresh(),
                ]);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildTopNavBar(widget.workspace),
                  const SizedBox(height: 20),
                  _buildWorkspaceInfoCard(widget.workspace),
                  const SizedBox(height: 16),
                  _buildStatsGrid(
                    workspaceMemos.length,
                    totalFiles,
                    totalChecklistTasks,
                    isLoading,
                  ),
                  const SizedBox(height: 20),
                  _buildSegmentedTab(),
                  const SizedBox(height: 24),
                  if (_activeTab == 'Overview') ...[
                    _buildSectionTitle(
                      'Members',
                      actionText: 'View all',
                      onAction: () {},
                    ),
                    const SizedBox(height: 12),
                    _buildMembersList(widget.workspace),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      'Recent activity',
                      actionText: 'View all',
                      onAction: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ActivityScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActivityList(widget.workspace),
                  ] else ...[
                    BoardView(
                      canvasBoard: CanvasBoard(
                        workspaceId: widget.workspace.id,
                        workspaceName: widget.workspace.title,
                        memos: workspaceMemos,
                        onMemoMoved: (memo, position) =>
                            context.read<MemoCubit>().updateMemoPosition(
                                  widget.workspace.id,
                                  memo.id,
                                  position.dx,
                                  position.dy,
                                ),
                        onMemoTap: _openMemo,
                      ),
                      kanbanBoard: KanbanBoard(
                        workspaceId: widget.workspace.id,
                        workspaceName: widget.workspace.title,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openMemo(Memo memo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MemoEditorScreen(
          memoId: memo.id.startsWith('canvas-') ||
                  const ['big-idea', 'next-steps', 'research', 'launch']
                      .contains(memo.id)
              ? null
              : memo.id,
          workspaceId: widget.workspace.id,
          initialTitle: memo.title,
          initialContent: memo.content,
        ),
      ),
    );
  }

  Widget _buildTopNavBar(Workspace workspace) {
    final isOwner =
        workspace.ownerId == FirebaseAuth.instance.currentUser?.uid;
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [AppTheme.shadowSoft],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.ink,
              size: 19,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workspace.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${isOwner ? 'Owner' : 'Member'} · ${workspace.members.length} members',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: AppTheme.ink,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () => showInviteWorkspaceSheet(
              context: context,
              workspace: workspace,
            ),
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Invite',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkspaceInfoCard(Workspace workspace) {
    final isOwner =
        workspace.ownerId == FirebaseAuth.instance.currentUser?.uid;
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
            right: -32,
            top: -40,
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
                      child: Text(
                        isOwner ? 'OWNER' : 'MEMBER',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.grid_view_rounded,
                      color: Colors.white.withValues(alpha: 0.35),
                      size: 19,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  workspace.title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  workspace.description.isEmpty
                      ? 'Product strategy, research, and launch planning.'
                      : workspace.description,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.55),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => showInviteWorkspaceSheet(
                    context: context,
                    workspace: workspace,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.copy_rounded,
                          color: AppTheme.ink,
                          size: 13,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Invite code: ${workspace.inviteCode}',
                          style: const TextStyle(
                            fontSize: 10,
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
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    int memosCount,
    int activeTasks,
    int completedTasks,
    bool isLoading,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [AppTheme.shadowSoft],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(isLoading ? '...' : '$memosCount', 'Memos'),
          ),
          Container(width: 1, height: 24, color: AppTheme.line),
          Expanded(child: _buildStatItem('$activeTasks', 'Active')),
          Container(width: 1, height: 24, color: AppTheme.line),
          Expanded(child: _buildStatItem('$completedTasks', 'Done')),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
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

  Widget _buildSegmentedTab() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.soft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: ['Overview', 'Hybrid Board'].map((tabName) {
          final isSelected = _activeTab == tabName;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = tabName),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected ? const [AppTheme.shadowSoft] : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  tabName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppTheme.ink : AppTheme.muted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(
    String title, {
    required String actionText,
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
        InkWell(
          onTap: onAction,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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

  Widget _buildMembersList(Workspace workspace) {
    final members = workspace.members;
    if (members.isEmpty) {
      return const Text(
        'No members yet.',
        style: TextStyle(color: AppTheme.muted),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [AppTheme.shadowSoft],
      ),
      child: Column(
        children: List.generate(members.length, (index) {
          final member = members[index];
          final isOwner = member.role.name == 'owner';
          final avatarColors = [
            AppTheme.ink,
            AppTheme.caramel,
            AppTheme.olive,
          ];
          final avatarBg = avatarColors[index % avatarColors.length];

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: index == members.length - 1
                  ? null
                  : const Border(bottom: BorderSide(color: AppTheme.line)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: avatarBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    member.initials,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        member.userId ==
                                FirebaseAuth.instance.currentUser?.uid
                            ? 'You'
                            : 'Active now',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.faint,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isOwner ? AppTheme.peach : AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isOwner ? 'Owner' : 'Member',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isOwner ? AppTheme.caramel : AppTheme.muted,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActivityList(Workspace workspace) {
    final memoState = context.watch<MemoCubit>().state;
    final workspaceMemos = memoState is MemoLoaded
        ? memoState.memos.where((m) => m.workspaceId == workspace.id).toList()
        : const <Memo>[];

    return StreamBuilder<List<Activity>>(
      stream: ActivityRepository().watchWorkspaceActivities(
        workspaceId: workspace.id,
        workspaceName: workspace.title,
      ),
      builder: (context, snapshot) {
        final activities = snapshot.data ?? const <Activity>[];
        if (activities.isEmpty) {
          if (workspaceMemos.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [AppTheme.shadowSoft],
              ),
              child: const Text(
                'No activity in this workspace yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [AppTheme.shadowSoft],
            ),
            child: Column(
              children: List.generate(workspaceMemos.take(5).length, (index) {
                final m = workspaceMemos[index];
                final isLast = index == workspaceMemos.take(5).length - 1;
                final actor =
                    m.authorName.isEmpty ? 'Naya' : m.authorName.split(' ').first;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                  child: _buildActivityRow(
                    initials: m.assignee.isNotEmpty ? m.assignee : 'NA',
                    bgColor: index.isEven ? AppTheme.caramel : AppTheme.olive,
                    actor: actor,
                    action: 'updated',
                    target: m.title.isEmpty ? 'Untitled memo' : m.title,
                    time: DateFormatter.getRelativeTimeText(m.updatedAt),
                    onTap: () => _openMemo(m),
                  ),
                );
              }),
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [AppTheme.shadowSoft],
          ),
          child: Column(
            children: List.generate(activities.take(5).length, (index) {
              final activity = activities[index];
              final isLast = index == activities.take(5).length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                child: _buildActivityRow(
                  initials: activity.initials,
                  bgColor: index.isEven ? AppTheme.caramel : AppTheme.olive,
                  actor: activity.initials,
                  action: activity.action,
                  target: activity.target,
                  time: DateFormatter.getRelativeTimeText(activity.time),
                  onTap: () {
                    Memo? matched;
                    if (activity.memoId.isNotEmpty) {
                      final byId = workspaceMemos
                          .where((m) => m.id == activity.memoId);
                      if (byId.isNotEmpty) matched = byId.first;
                    }
                    if (matched == null) {
                      final byTitle = workspaceMemos.where((m) =>
                          m.title.toLowerCase() ==
                          activity.target.toLowerCase());
                      if (byTitle.isNotEmpty) matched = byTitle.first;
                    }
                    if (matched != null) {
                      _openMemo(matched);
                    }
                  },
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
    required String target,
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
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.muted,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
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
                        text: target,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

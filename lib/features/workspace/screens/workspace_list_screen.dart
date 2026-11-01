import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/avatar_stack.dart';
import '../../memo/cubit/memo_cubit.dart';
import '../../search/screens/search_screen.dart';
import '../cubit/workspace_cubit.dart';
import '../models/workspace.dart';
import 'workspace_detail_screen.dart';

class WorkspaceListScreen extends StatelessWidget {
  const WorkspaceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceCubit, List<Workspace>>(
      builder: (context, workspaces) {
        return BlocBuilder<MemoCubit, MemoState>(
          builder: (context, memoState) {
            final allMemos =
                memoState is MemoLoaded ? memoState.memos : const [];
            final memoCount = allMemos.length;
            final memberCount = workspaces.fold<int>(
                0,
                (total, workspace) =>
                    total +
                    (workspace.members.isEmpty ? 1 : workspace.members.length));
            return Scaffold(
              backgroundColor: AppTheme.canvas,
              body: SafeArea(
                child: RefreshIndicator(
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _header(context, workspaces.length),
                        const SizedBox(height: 20),
                        _actions(context),
                        const SizedBox(height: 20),
                        _stats(workspaces.length, memberCount, memoCount),
                        const SizedBox(height: 28),
                        const Text(
                          'All workspaces',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _workspaceList(context, workspaces),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _header(BuildContext context, int workspaceCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$workspaceCount ACTIVE SPACES',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Your workspaces',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppTheme.ink,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _iconButton(
              icon: Icons.search_rounded,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
            ),
            const SizedBox(width: 8),
            _iconButton(
              icon: Icons.notifications_none_rounded,
              onTap: () => showNotificationsSheet(context: context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
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
          child: Icon(icon, color: AppTheme.ink, size: 20),
        ),
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _actionCard(
            context,
            title: 'Create',
            subtitle: 'New workspace',
            icon: Icons.add_rounded,
            dark: true,
            onTap: () => showCreateWorkspaceSheet(context: context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionCard(
            context,
            title: 'Join',
            subtitle: 'Use invite code',
            icon: Icons.login_rounded,
            dark: false,
            onTap: () => showJoinWorkspaceSheet(context: context),
          ),
        ),
      ],
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool dark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: dark ? AppTheme.ink : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: dark
                      ? Colors.white.withOpacity(0.12)
                      : AppTheme.mint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: dark ? Colors.white : AppTheme.olive,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: dark ? Colors.white : AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 9,
                        color: dark ? Colors.white60 : AppTheme.faint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stats(int workspaceCount, int memberCount, int memoCount) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [AppTheme.shadowSoft],
      ),
      child: Row(
        children: [
          _stat('$workspaceCount', 'Spaces'),
          _divider(),
          _stat('$memberCount', 'Members'),
          _divider(),
          _stat('$memoCount', 'Memos'),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Column(
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
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 24, color: AppTheme.line);

  Widget _emptyWorkspaceState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [AppTheme.shadowSoft],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppTheme.soft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.groups_outlined,
                size: 24, color: AppTheme.muted),
          ),
          const SizedBox(height: 12),
          const Text(
            'No workspaces yet',
            style: TextStyle(
              color: AppTheme.ink,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Create a new space or join one with an invitation code.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.muted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => showCreateWorkspaceSheet(context: context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.ink,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Create workspace',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  List<Widget> _workspaceCards(
      BuildContext context, List<Workspace> workspaces) {
    if (workspaces.isEmpty) return [_emptyWorkspaceState(context)];
    return workspaces.asMap().entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _workspaceCard(
          context,
          entry.value,
          index: entry.key,
        ),
      );
    }).toList();
  }

  Widget _workspaceList(BuildContext context, List<Workspace> workspaces) {
    return Column(
      children: _workspaceCards(context, workspaces),
    );
  }

  Widget _workspaceCard(
    BuildContext context,
    Workspace workspace, {
    required int index,
  }) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final role = workspace.ownerId == userId ? 'Owner' : 'Member';
    final memoState = context.watch<MemoCubit>().state;
    final liveMemoCount = memoState is MemoLoaded
        ? memoState.memos.where((m) => m.workspaceId == workspace.id).length
        : workspace.memoCount;
    final liveMemberCount =
        workspace.members.isEmpty ? 1 : workspace.members.length;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => WorkspaceDetailScreen(workspace: workspace)),
        ),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: index.isEven ? AppTheme.ink : AppTheme.mint,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.grid_view_rounded,
                      color: index.isEven ? Colors.white : AppTheme.olive,
                      size: 19,
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
                                workspace.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.ink,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _roleBadge(role),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$liveMemberCount members · $liveMemoCount memos',
                          style: const TextStyle(
                            fontSize: 10,
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
              const SizedBox(height: 14),
              Container(height: 1, color: AppTheme.line),
              const SizedBox(height: 12),
              Row(
                children: [
                  AvatarStack(
                    members: workspace.members,
                    maxAvatars: 3,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      workspace.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Updated ${DateFormatter.getRelativeTimeText(workspace.updatedAt)}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppTheme.faint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        role.toUpperCase(),
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: AppTheme.muted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

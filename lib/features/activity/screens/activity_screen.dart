import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../memo/cubit/memo_cubit.dart';
import '../../memo/models/memo.dart';
import '../../memo/screens/memo_editor_screen.dart';
import '../../workspace/cubit/workspace_cubit.dart';
import '../../workspace/screens/workspace_detail_screen.dart';
import '../data/activity_repository.dart';
import '../models/activity.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  void _openActivityTarget(
    BuildContext context, {
    required String memoId,
    required String workspaceId,
    required String targetTitle,
  }) {
    final memoState = context.read<MemoCubit>().state;
    final memos = memoState is MemoLoaded ? memoState.memos : const <Memo>[];
    final workspaces = context.read<WorkspaceCubit>().state;

    Memo? matchedMemo;
    if (memoId.isNotEmpty) {
      final byId = memos.where((m) => m.id == memoId);
      if (byId.isNotEmpty) matchedMemo = byId.first;
    }
    if (matchedMemo == null && targetTitle.isNotEmpty) {
      final byTitle = memos.where(
        (m) => m.title.toLowerCase() == targetTitle.toLowerCase(),
      );
      if (byTitle.isNotEmpty) matchedMemo = byTitle.first;
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
      final wsMatch = workspaces.where((w) => w.id == workspaceId);
      if (wsMatch.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkspaceDetailScreen(workspace: wsMatch.first),
          ),
        );
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final memoState = context.watch<MemoCubit>().state;
    final memos = memoState is MemoLoaded ? memoState.memos : const <Memo>[];
    final workspaces = context.watch<WorkspaceCubit>().state;

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: StreamBuilder<List<Activity>>(
                stream: ActivityRepository().watchAllMyActivities(),
                builder: (context, snapshot) {
                  final streamActivities = snapshot.data ?? const <Activity>[];

                  final resolvedActivities = streamActivities.isNotEmpty
                      ? streamActivities
                      : memos.map((m) {
                          final wsMatch = workspaces
                              .where((w) => w.id == m.workspaceId)
                              .toList();
                          final wsName =
                              wsMatch.isNotEmpty ? wsMatch.first.name : m.tag;
                          final actor = m.authorName.isEmpty
                              ? 'Naya Anindita'
                              : m.authorName;
                          return Activity(
                            id: 'memo-act-${m.id}',
                            initials: m.assignee.isNotEmpty ? m.assignee : 'NA',
                            action: '$actor memperbarui memo',
                            target: m.title.isEmpty ? 'Untitled memo' : m.title,
                            workspaceId: m.workspaceId,
                            workspaceName: wsName,
                            memoId: m.id,
                            time: m.updatedAt,
                          );
                        }).toList();

                  if (resolvedActivities.isEmpty) {
                    return const Center(
                      child: Text(
                        'No workspace activity yet.',
                        style: TextStyle(
                          color: AppTheme.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppTheme.ink,
                    backgroundColor: Colors.white,
                    onRefresh: () async {
                      await Future.wait([
                        context.read<WorkspaceCubit>().refresh(),
                        context.read<MemoCubit>().refresh(),
                      ]);
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: resolvedActivities.length,
                      itemBuilder: (context, index) {
                      final activity = resolvedActivities[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () => _openActivityTarget(
                              context,
                              memoId: activity.memoId,
                              workspaceId: activity.workspaceId,
                              targetTitle: activity.target,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: const [AppTheme.shadowSoft],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: index.isEven
                                          ? AppTheme.peach
                                          : AppTheme.mint,
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      activity.initials,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.ink,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.muted,
                                              fontWeight: FontWeight.w500,
                                              height: 1.45,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '${activity.action} ',
                                              ),
                                              TextSpan(
                                                text: activity.target,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: AppTheme.ink,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (activity.workspaceName.isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 3),
                                            child: Text(
                                              activity.workspaceName,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.faint,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormatter.getRelativeTimeText(
                                        activity.time),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.faint,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 16,
                                    color: AppTheme.faint,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              customBorder: const CircleBorder(),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
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
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Team activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: AppTheme.ink,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Tap any update to open its memo or workspace',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../memo/cubit/memo_cubit.dart';
import '../../memo/models/memo.dart';
import '../../memo/screens/memo_editor_screen.dart';
import '../../workspace/cubit/workspace_cubit.dart';
import '../../workspace/screens/workspace_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedFilter = 'All';

  final List<String> _filters = const ['All', 'Memos', 'Workspaces', 'Files'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memoState = context.watch<MemoCubit>().state;
    final allMemos = memoState is MemoLoaded ? memoState.memos : <Memo>[];
    final allWorkspaces = context.watch<WorkspaceCubit>().state;

    final q = _query.trim().toLowerCase();

    final matchingMemos = allMemos.where((m) {
      if (_selectedFilter == 'Workspaces') return false;
      if (_selectedFilter == 'Files' && m.attachments.isEmpty) return false;
      if (q.isEmpty) return true;
      final inTitle = m.title.toLowerCase().contains(q);
      final inContent = m.content.toLowerCase().contains(q);
      final inTag = m.tag.toLowerCase().contains(q);
      final inChecklist = m.checklistTitle.toLowerCase().contains(q) ||
          m.checklist.any(
            (c) => (c['text'] as String? ?? '').toLowerCase().contains(q),
          );
      final inAttachments = m.attachments.any(
        (a) => (a['name'] as String? ?? '').toLowerCase().contains(q),
      );
      return inTitle || inContent || inTag || inChecklist || inAttachments;
    }).toList();

    final matchingWorkspaces = allWorkspaces.where((w) {
      if (_selectedFilter == 'Memos' || _selectedFilter == 'Files') {
        return false;
      }
      if (q.isEmpty) return true;
      return w.name.toLowerCase().contains(q) ||
          w.description.toLowerCase().contains(q) ||
          w.inviteCode.toLowerCase().contains(q);
    }).toList();

    final totalResults = matchingMemos.length + matchingWorkspaces.length;

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildSearchInputBar(),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((filter) {
                    final active = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: active ? AppTheme.ink : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: active ? null : const [AppTheme.shadowSoft],
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: active ? Colors.white : AppTheme.muted,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    q.isEmpty
                        ? 'Recent memos & spaces'
                        : 'Results for “$_query”',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    '$totalResults found',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.faint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: totalResults == 0
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 36,
                              color: AppTheme.faint,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              q.isEmpty
                                  ? 'No memos or workspaces yet'
                                  : 'No matches for "$_query"',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Try searching by memo title, checklist item, attachment name, or workspace.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.muted,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 24),
                        children: [
                          ...matchingWorkspaces.map((ws) {
                            final wsMemos = allMemos
                                .where((m) => m.workspaceId == ws.id)
                                .length;
                            return _buildResultTile(
                              icon: Icons.grid_view_rounded,
                              iconBg: AppTheme.mint,
                              iconColor: AppTheme.olive,
                              title: ws.name,
                              subtitle:
                                  'Workspace · ${ws.members.isEmpty ? 1 : ws.members.length} members · $wsMemos memos',
                              badge: 'Space',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        WorkspaceDetailScreen(workspace: ws),
                                  ),
                                );
                              },
                            );
                          }),
                          ...matchingMemos.map((memo) {
                            final wsMatch = allWorkspaces
                                .where((w) => w.id == memo.workspaceId)
                                .toList();
                            final wsName = wsMatch.isNotEmpty
                                ? wsMatch.first.name
                                : memo.tag;
                            final hasFiles = memo.attachments.isNotEmpty;
                            final hasChecklist = memo.checklist.isNotEmpty;
                            return _buildResultTile(
                              icon: hasFiles
                                  ? Icons.attach_file_rounded
                                  : hasChecklist
                                      ? Icons.checklist_rounded
                                      : Icons.description_rounded,
                              iconBg: hasFiles
                                  ? AppTheme.lilac
                                  : hasChecklist
                                      ? AppTheme.mint
                                      : AppTheme.peach,
                              iconColor: hasFiles
                                  ? AppTheme.plum
                                  : hasChecklist
                                      ? AppTheme.olive
                                      : AppTheme.caramel,
                              title: memo.title.isEmpty
                                  ? 'Untitled memo'
                                  : memo.title,
                              subtitle:
                                  '$wsName · ${memo.preview.isEmpty ? DateFormatter.getRelativeTimeText(memo.updatedAt) : memo.preview}',
                              badge: memo.tag,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MemoEditorScreen(
                                      memoId: memo.id,
                                      workspaceId: memo.workspaceId,
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badge,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [AppTheme.shadowSoft],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppTheme.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.muted,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.faint,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.canvas,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.ink),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search MemoSpace',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Memos, checklists, files & workspaces',
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [AppTheme.shadowSoft],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppTheme.muted, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.ink,
              ),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search memos, checklists, files, or spaces...',
                hintStyle: TextStyle(color: AppTheme.faint, fontSize: 12.5),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4, vertical: 13),
              ),
            ),
          ),
          if (_query.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _query = '';
                });
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppTheme.muted,
                  size: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

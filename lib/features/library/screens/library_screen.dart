import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_theme.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../memo/cubit/memo_cubit.dart';
import '../../memo/models/memo.dart';
import '../../memo/screens/memo_editor_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../workspace/cubit/workspace_cubit.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _activeFilter = 'All';
  final List<String> _filters = ['All', 'Notes', 'Checklists', 'Media', 'Files'];
  final TextEditingController _searchController = TextEditingController();
  String _selectedSort = 'Recently updated';
  String? _selectedCollection;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isMediaMemo(Memo memo) {
    final tag = memo.tag.toLowerCase();
    return tag == 'media' ||
        memo.attachments.any(
          (a) => a['type'] == 'Photo' || a['type'] == 'Video',
        );
  }

  bool _isFileMemo(Memo memo) {
    final tag = memo.tag.toLowerCase();
    return tag == 'files' ||
        tag == 'file' ||
        tag == 'pdf' ||
        memo.attachments.any(
          (a) => a['type'] == 'PDF' || a['type'] == 'Document',
        );
  }

  bool _isChecklistMemo(Memo memo) {
    final tag = memo.tag.toLowerCase();
    return memo.checklist.isNotEmpty ||
        memo.dueDate.trim().isNotEmpty ||
        tag == 'checklist' ||
        tag == 'projects';
  }

  bool _isNoteMemo(Memo memo) {
    return memo.content.trim().isNotEmpty ||
        (memo.attachments.isEmpty && memo.checklist.isEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final workspaces = context.watch<WorkspaceCubit>().state;
    final workspaceNames = {
      for (final ws in workspaces) ws.id: ws.name,
    };

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: BlocBuilder<MemoCubit, MemoState>(
          builder: (context, state) {
            List<Memo> firebaseMemos = [];
            bool isLoading = state is MemoLoading;

            if (state is MemoLoaded) {
              firebaseMemos = state.memos;
            }
            final query = _searchController.text.trim().toLowerCase();
            final visibleMemos = firebaseMemos.where((memo) {
              final normalizedTag = memo.tag.toLowerCase();
              final wsName =
                  (workspaceNames[memo.workspaceId] ?? '').toLowerCase();
              final matchesQuery = query.isEmpty ||
                  memo.title.toLowerCase().contains(query) ||
                  memo.content.toLowerCase().contains(query) ||
                  memo.checklistTitle.toLowerCase().contains(query) ||
                  normalizedTag.contains(query) ||
                  wsName.contains(query);

              final matchesFilter = switch (_activeFilter) {
                'Notes' => _isNoteMemo(memo),
                'Checklists' => _isChecklistMemo(memo),
                'Media' => _isMediaMemo(memo),
                'Files' => _isFileMemo(memo),
                _ => true,
              };

              final matchesCollection = _selectedCollection == null ||
                  switch (_selectedCollection) {
                    'Notes & Ideas' => _isNoteMemo(memo),
                    'Checklists' => _isChecklistMemo(memo),
                    'Media' => _isMediaMemo(memo),
                    'Documents' => _isFileMemo(memo),
                    _ => true,
                  };

              return matchesQuery && matchesFilter && matchesCollection;
            }).toList()
              ..sort((a, b) {
                if (_selectedSort == 'Date created') {
                  return a.updatedAt.compareTo(b.updatedAt);
                } else if (_selectedSort == 'Name A–Z') {
                  return a.title.toLowerCase().compareTo(b.title.toLowerCase());
                } else {
                  return b.updatedAt.compareTo(a.updatedAt);
                }
              });

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
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildSearchBarRow(),
                  const SizedBox(height: 16),
                  _buildFilterPills(),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    'Collections',
                    actionText:
                        _selectedCollection != null ? 'Clear filter' : 'All items',
                    onAction: () {
                      if (_selectedCollection != null) {
                        setState(() => _selectedCollection = null);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child:
                                CircularProgressIndicator(color: AppTheme.ink),
                          ),
                        )
                      : _buildCollectionsGrid(firebaseMemos),
                  const SizedBox(height: 28),
                  _buildSectionTitle(
                    'Recently added (${visibleMemos.length})',
                    actionText: 'Sort',
                    onAction: () => showActionSheet(
                      context: context,
                      title: 'Sort items',
                      description: 'Choose how library items are ordered.',
                      options: const [
                        'Recently updated',
                        'Date created',
                        'Name A–Z',
                      ],
                      initialSelected: _selectedSort,
                      primaryButtonLabel: 'Apply',
                      onApplied: (sort) => setState(() => _selectedSort = sort),
                    ),
                  ),
                  const SizedBox(height: 12),
                  isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child:
                                CircularProgressIndicator(color: AppTheme.ink),
                          ),
                        )
                      : _buildRecentlyAddedList(
                          context,
                          visibleMemos,
                          firebaseMemos.isEmpty,
                          workspaceNames,
                        ),
                  const SizedBox(height: 24),
                ],
              ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EVERYTHING, ORGANIZED',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AppTheme.muted,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Your library',
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
            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [AppTheme.shadowSoft],
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: AppTheme.ink,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => showNotificationsSheet(context: context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [AppTheme.shadowSoft],
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppTheme.ink,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBarRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [AppTheme.shadowSoft],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppTheme.faint, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                hintText: 'Search memos, checklists, or workspaces...',
                hintStyle: TextStyle(color: AppTheme.faint),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {});
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.close_rounded, color: AppTheme.faint, size: 17),
              ),
            ),
          Container(width: 1, height: 18, color: AppTheme.line),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Reset filters',
            onPressed: () {
              setState(() {
                _activeFilter = 'All';
                _selectedCollection = null;
                _searchController.clear();
              });
            },
            icon: const Icon(
              Icons.filter_list_rounded,
              color: AppTheme.muted,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => setState(() => _activeFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.ink : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [AppTheme.shadowSoft],
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppTheme.muted,
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
            letterSpacing: -0.2,
          ),
        ),
        InkWell(
          onTap: onAction,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
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
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 15,
                  color: AppTheme.muted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollectionsGrid(List<Memo> memos) {
    final int notesCount = memos.where(_isNoteMemo).length;
    final int checklistsCount = memos.where(_isChecklistMemo).length;
    final int mediaCount = memos.where(_isMediaMemo).length;
    final int filesCount = memos.where(_isFileMemo).length;

    final collections = [
      {
        'title': 'Notes & Ideas',
        'count': '$notesCount items',
        'icon': Icons.auto_awesome_rounded,
        'color': AppTheme.peach,
      },
      {
        'title': 'Checklists',
        'count': '$checklistsCount items',
        'icon': Icons.checklist_rtl_rounded,
        'color': AppTheme.mint,
      },
      {
        'title': 'Media',
        'count': '$mediaCount items',
        'icon': Icons.image_rounded,
        'color': AppTheme.lilac,
      },
      {
        'title': 'Documents',
        'count': '$filesCount items',
        'icon': Icons.insert_drive_file_rounded,
        'color': AppTheme.soft,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: collections.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        final item = collections[index];
        final title = item['title'] as String;
        final isSelected = _selectedCollection == title;

        return GestureDetector(
          onTap: () {
            setState(() {
              if (_selectedCollection == title) {
                _selectedCollection = null;
              } else {
                _selectedCollection = title;
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: isSelected
                  ? Border.all(color: AppTheme.ink, width: 1.5)
                  : null,
              boxShadow: const [AppTheme.shadowSoft],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: item['color'] as Color,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: AppTheme.ink,
                        size: 19,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.ink,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['count'] as String,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.faint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentlyAddedList(
    BuildContext context,
    List<Memo> visibleMemos,
    bool isTotalEmpty,
    Map<String, String> workspaceNames,
  ) {
    if (visibleMemos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [AppTheme.shadowSoft],
        ),
        child: Column(
          children: [
            const Icon(
              Icons.library_books_outlined,
              size: 28,
              color: AppTheme.faint,
            ),
            const SizedBox(height: 10),
            Text(
              isTotalEmpty
                  ? 'Belum ada memo di Library Anda.'
                  : 'Tidak ada memo yang cocok dengan filter ini.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isTotalEmpty
                  ? 'Buat memo pertama Anda dengan menekan tombol di bawah.'
                  : 'Coba ubah kata kunci pencarian atau reset filter di atas.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.faint,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            if (isTotalEmpty)
              ElevatedButton.icon(
                onPressed: () {
                  final workspaces = context.read<WorkspaceCubit>().state;
                  if (workspaces.isEmpty) {
                    showWorkspaceChoiceSheet(context: context);
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MemoEditorScreen(
                        workspaceId: workspaces.first.id,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.ink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text(
                  'Create new memo',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              )
            else
              TextButton(
                onPressed: () {
                  setState(() {
                    _activeFilter = 'All';
                    _selectedCollection = null;
                    _searchController.clear();
                  });
                },
                child: const Text(
                  'Reset filters',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Column(
      children: visibleMemos.map((memo) {
        IconData itemIcon = Icons.description_rounded;
        Color iconBg = AppTheme.peach;
        Color iconColor = AppTheme.caramel;

        if (_isMediaMemo(memo)) {
          itemIcon = Icons.image_rounded;
          iconBg = AppTheme.lilac;
          iconColor = AppTheme.plum;
        } else if (_isFileMemo(memo)) {
          itemIcon = Icons.insert_drive_file_rounded;
          iconBg = AppTheme.surface;
          iconColor = AppTheme.ink;
        } else if (_isChecklistMemo(memo)) {
          itemIcon = Icons.checklist_rtl_rounded;
          iconBg = AppTheme.mint;
          iconColor = AppTheme.olive;
        }

        final wsLabel = workspaceNames[memo.workspaceId] ?? memo.tag;
        final doneChecklist =
            memo.checklist.where((c) => c['done'] == true).length;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [AppTheme.shadowSoft],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MemoEditorScreen(
                    memoId: memo.id,
                    workspaceId: memo.workspaceId,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(itemIcon, color: iconColor, size: 19),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            memo.title.isEmpty ? 'Untitled memo' : memo.title,
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
                            memo.preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
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
                                  wsLabel,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.muted,
                                  ),
                                ),
                              ),
                              if (memo.checklist.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.mint,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${memo.checklistTitle.isNotEmpty ? '${memo.checklistTitle}: ' : ''}$doneChecklist/${memo.checklist.length}',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.olive,
                                    ),
                                  ),
                                ),
                              if (memo.attachments.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.peach,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${memo.attachments.length} file${memo.attachments.length > 1 ? 's' : ''}',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.caramel,
                                    ),
                                  ),
                                ),
                              if (memo.dueDate.trim().isNotEmpty)
                                DeadlineBadge(
                                  date: memo.dueDate,
                                  completed: (memo.progress ?? 0.0) >= 1.0,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.more_horiz_rounded,
                        color: AppTheme.faint,
                        size: 18,
                      ),
                      onPressed: () => showActionSheet(
                        context: context,
                        title: 'More actions',
                        description:
                            'Manage this memo or share it with others.',
                        options: const [
                          'Share',
                          'Duplicate',
                          'Delete memo',
                        ],
                        primaryButtonLabel: 'Done',
                        onApplied: (action) {
                          if (action == 'Delete memo') {
                            context
                                .read<MemoCubit>()
                                .delete(memo.workspaceId, memo.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Memo berhasil dihapus'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } else if (action == 'Duplicate') {
                            context.read<MemoCubit>().addMemo(
                                  workspaceId: memo.workspaceId,
                                  title: '${memo.title} (Copy)',
                                  content: memo.content,
                                  tag: memo.tag,
                                  dueDate: memo.dueDate,
                                  checklistTitle: memo.checklistTitle,
                                  attachments: memo.attachments,
                                  checklist: memo.checklist,
                                );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

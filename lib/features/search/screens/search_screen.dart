import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/features/memo/data/dummy_memos.dart';
import 'package:memospace/features/memo/models/memo.dart';
import 'package:memospace/features/memo/widgets/memo_card.dart';
import 'package:memospace/features/workspace/data/dummy_workspaces.dart';
import 'package:memospace/features/workspace/models/workspace.dart';

enum _SearchFilter { all, memo, workspace, file }

class SearchScreen extends StatefulWidget {
  final ValueChanged<Memo>? onMemoTap;
  final ValueChanged<Workspace>? onWorkspaceTap;
  final ValueChanged<Memo>? onFileTap;

  const SearchScreen({
    super.key,
    this.onMemoTap,
    this.onWorkspaceTap,
    this.onFileTap,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final List<String> _recentSearches = [];
  _SearchFilter _filter = _SearchFilter.all;

  String get _query => _searchController.text.trim().toLowerCase();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    setState(() {
      _recentSearches.removeWhere(
        (recent) => recent.toLowerCase() == query.toLowerCase(),
      );
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 8) _recentSearches.removeLast();
    });
    FocusScope.of(context).unfocus();
  }

  void _selectRecentSearch(String query) {
    _searchController.text = query;
    setState(() {});
    _search(query);
  }

  List<Memo> get _memoResults {
    if (_filter != _SearchFilter.all && _filter != _SearchFilter.memo) {
      return const [];
    }
    return dummyMemos.where((memo) {
      return _contains(memo.title) ||
          _contains(memo.content) ||
          _contains(memo.category) ||
          _contains(memo.author);
    }).toList();
  }

  List<Workspace> get _workspaceResults {
    if (_filter != _SearchFilter.all && _filter != _SearchFilter.workspace) {
      return const [];
    }
    return dummyWorkspaces.where((workspace) {
      return _contains(workspace.title) || _contains(workspace.category);
    }).toList();
  }

  List<({Memo memo, String fileName})> get _fileResults {
    if (_filter != _SearchFilter.all && _filter != _SearchFilter.file) {
      return const [];
    }
    return [
      for (final memo in dummyMemos)
        if (memo.fileName != null &&
            (_matches(memo.fileName!) ||
                _matches(memo.title) ||
                _matches(memo.category)))
          (memo: memo, fileName: memo.fileName!),
    ];
  }

  bool _contains(String value) => value.toLowerCase().contains(_query);

  bool _matches(String value) => value.toLowerCase().contains(_query);

  @override
  Widget build(BuildContext context) {
    final hasQuery = _query.isNotEmpty;
    final memos = hasQuery ? _memoResults : const <Memo>[];
    final workspaces = hasQuery ? _workspaceResults : const <Workspace>[];
    final files =
        hasQuery ? _fileResults : const <({Memo memo, String fileName})>[];
    final hasResults =
        memos.isNotEmpty || workspaces.isNotEmpty || files.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencarian'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
                onSubmitted: _search,
                decoration: AppTheme.pillInput(
                  hint: 'Cari memo, workspace, atau berkas...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Hapus pencarian',
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
            ),
            if (hasQuery) _buildFilterChips(),
            Expanded(
              child: hasQuery
                  ? _buildSearchResults(
                      memos: memos,
                      workspaces: workspaces,
                      files: files,
                      hasResults: hasResults,
                    )
                  : _buildRecentSearches(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Pencarian terakhir',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => setState(_recentSearches.clear),
              child: const Text('Hapus semua'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (_recentSearches.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Belum ada pencarian.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          )
        else
          for (final query in _recentSearches)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.history,
                color: AppTheme.textSecondary,
              ),
              title: Text(query),
              trailing: IconButton(
                tooltip: 'Hapus pencarian',
                onPressed: () => setState(() => _recentSearches.remove(query)),
                icon: const Icon(Icons.close, size: 18),
              ),
              onTap: () => _selectRecentSearch(query),
            ),
      ],
    );
  }

  Widget _buildFilterChips() {
    const filters = [
      (filter: _SearchFilter.all, label: 'Semua'),
      (filter: _SearchFilter.memo, label: 'Memo'),
      (filter: _SearchFilter.workspace, label: 'Workspace'),
      (filter: _SearchFilter.file, label: 'Berkas'),
    ];

    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = filters[index];
          final selected = _filter == item.filter;
          return ChoiceChip(
            label: Text(item.label),
            selected: selected,
            onSelected: (_) => setState(() => _filter = item.filter),
            selectedColor: AppTheme.primary,
            backgroundColor: AppTheme.editorToolbarBackground,
            labelStyle: TextStyle(
              color: selected ? AppTheme.background : AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            shape: const StadiumBorder(),
            side: BorderSide.none,
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _buildSearchResults({
    required List<Memo> memos,
    required List<Workspace> workspaces,
    required List<({Memo memo, String fileName})> files,
    required bool hasResults,
  }) {
    if (!hasResults) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Tidak ada hasil yang cocok.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        if (memos.isNotEmpty) ...[
          _buildGroupTitle('Memo', memos.length),
          const SizedBox(height: 10),
          for (final memo in memos)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: widget.onMemoTap == null
                    ? null
                    : () => widget.onMemoTap!(memo),
                borderRadius: BorderRadius.circular(16),
                child: MemoCard(memo: memo),
              ),
            ),
        ],
        if (workspaces.isNotEmpty) ...[
          _buildGroupTitle('Workspace', workspaces.length),
          const SizedBox(height: 10),
          for (final workspace in workspaces)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _WorkspaceResultTile(
                workspace: workspace,
                onTap: widget.onWorkspaceTap == null
                    ? null
                    : () => widget.onWorkspaceTap!(workspace),
              ),
            ),
        ],
        if (files.isNotEmpty) ...[
          _buildGroupTitle('Berkas', files.length),
          const SizedBox(height: 10),
          for (final file in files)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FileResultTile(
                fileName: file.fileName,
                memoTitle: file.memo.title,
                onTap: widget.onFileTap == null
                    ? null
                    : () => widget.onFileTap!(file.memo),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildGroupTitle(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceResultTile extends StatelessWidget {
  final Workspace workspace;
  final VoidCallback? onTap;

  const _WorkspaceResultTile({
    required this.workspace,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.folder_outlined, color: AppTheme.textPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workspace.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      workspace.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _FileResultTile extends StatelessWidget {
  final String fileName;
  final String memoTitle;
  final VoidCallback? onTap;

  const _FileResultTile({
    required this.fileName,
    required this.memoTitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.insert_drive_file_outlined,
                color: AppTheme.textPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      memoTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

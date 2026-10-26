import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/core/widgets/memo_app_bar.dart';
import 'package:memospace/features/workspace/data/dummy_workspaces.dart';
import 'package:memospace/features/workspace/models/workspace.dart';
import 'package:memospace/features/workspace/screens/create_join_workspace_screen.dart';

class WorkspaceListScreen extends StatefulWidget {
  const WorkspaceListScreen({super.key});

  @override
  State<WorkspaceListScreen> createState() => _WorkspaceListScreenState();
}

class _WorkspaceListScreenState extends State<WorkspaceListScreen> {
  final _searchController = TextEditingController();
  int _selectedFilterIndex = 0;

  List<Workspace> get _filteredWorkspaces {
    final query = _searchController.text.trim().toLowerCase();
    return dummyWorkspaces.where((workspace) {
      final matchesQuery = query.isEmpty ||
          workspace.title.toLowerCase().contains(query) ||
          workspace.category.toLowerCase().contains(query);
      final matchesFilter = switch (_selectedFilterIndex) {
        1 => workspace.hasPin,
        _ => true,
      };
      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspaces = _filteredWorkspaces;
    final pinnedWorkspaces =
        workspaces.where((workspace) => workspace.hasPin).toList();
    final otherWorkspaces =
        workspaces.where((workspace) => !workspace.hasPin).toList();
    final showPinnedSection = _selectedFilterIndex == 0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const MemoAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateJoinWorkspaceScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.background,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
          children: [
            const Text(
              'Workspace',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ruang kerja timmu',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: AppTheme.pillInput(
                hint: 'Cari workspace...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
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
            const SizedBox(height: 16),
            Row(
              children: [
                _buildFilterPill('Semua', 0),
                const SizedBox(width: 8),
                _buildFilterPill('Disematkan', 1),
                const SizedBox(width: 8),
                _buildFilterPill('Milik saya', 2),
              ],
            ),
            const SizedBox(height: 24),
            if (workspaces.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'Workspace tidak ditemukan.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              )
            else ...[
              if (showPinnedSection && pinnedWorkspaces.isNotEmpty) ...[
                _buildSectionHeading('DISEMATKAN', pinnedWorkspaces.length,
                    icon: Icons.push_pin_outlined),
                const SizedBox(height: 12),
                for (final workspace in pinnedWorkspaces)
                  _buildWorkspaceCard(workspace),
                if (otherWorkspaces.isNotEmpty) const SizedBox(height: 16),
              ],
              if (otherWorkspaces.isNotEmpty || !showPinnedSection) ...[
                _buildSectionHeading(
                  _selectedFilterIndex == 1 ? 'DISEMATKAN' : 'SEMUA WORKSPACE',
                  showPinnedSection
                      ? otherWorkspaces.length
                      : workspaces.length,
                ),
                const SizedBox(height: 12),
                for (final workspace
                    in showPinnedSection ? otherWorkspaces : workspaces)
                  _buildWorkspaceCard(workspace),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, int index) {
    final isActive = _selectedFilterIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: isActive,
      onSelected: (_) => setState(() => _selectedFilterIndex = index),
      selectedColor: AppTheme.primary,
      backgroundColor: AppTheme.editorToolbarBackground,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isActive ? AppTheme.background : AppTheme.textPrimary,
      ),
      shape: const StadiumBorder(),
      side: BorderSide.none,
      showCheckmark: false,
    );
  }

  Widget _buildSectionHeading(String title, int count, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
        ],
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Text(
          '$count ruang',
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildWorkspaceCard(Workspace workspace) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.editorToolbarBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  workspace.category,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              Icon(
                workspace.hasPin ? Icons.push_pin : Icons.push_pin_outlined,
                size: 16,
                color: workspace.hasPin
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            workspace.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMemberAvatars(workspace.memberInitials),
              const SizedBox(width: 6),
              Text(
                '${workspace.memberInitials.length} anggota',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                size: 14,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${workspace.memoCount} memo',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '•',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.folder_open_outlined,
                size: 14,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${workspace.fileCount} berkas',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                workspace.time,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberAvatars(List<String> initials) {
    final visibleInitials = initials.take(3).toList();
    return SizedBox(
      width:
          visibleInitials.isEmpty ? 0 : 24 + (visibleInitials.length - 1) * 16,
      height: 24,
      child: Stack(
        children: [
          for (var index = 0; index < visibleInitials.length; index++)
            Positioned(
              left: index * 16,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: AppTheme.background,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: AppTheme.surface,
                  child: Text(
                    visibleInitials[index],
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

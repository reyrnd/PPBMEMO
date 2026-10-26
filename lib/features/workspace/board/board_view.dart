import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';

enum WorkspaceBoardType { canvas, kanban }

class BoardView extends StatefulWidget {
  final Widget canvasBoard;
  final Widget kanbanBoard;
  final WorkspaceBoardType initialBoard;
  final VoidCallback? onAddMemo;
  final VoidCallback? onSearch;
  final VoidCallback? onFilter;

  const BoardView({
    super.key,
    required this.canvasBoard,
    required this.kanbanBoard,
    this.initialBoard = WorkspaceBoardType.canvas,
    this.onAddMemo,
    this.onSearch,
    this.onFilter,
  });

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  late var _selectedBoard = widget.initialBoard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _buildBoardToggle()),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Cari memo',
              onPressed: widget.onSearch,
              icon: const Icon(Icons.search),
              color: AppTheme.textPrimary,
            ),
            IconButton(
              tooltip: 'Filter memo',
              onPressed: widget.onFilter,
              icon: const Icon(Icons.filter_list),
              color: AppTheme.textPrimary,
            ),
            IconButton(
              tooltip: 'Tambah memo',
              onPressed: widget.onAddMemo,
              icon: const Icon(Icons.add),
              color: AppTheme.textPrimary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: IndexedStack(
            index: _selectedBoard == WorkspaceBoardType.canvas ? 0 : 1,
            children: [widget.canvasBoard, widget.kanbanBoard],
          ),
        ),
      ],
    );
  }

  Widget _buildBoardToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.editorToolbarBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _BoardToggleOption(
            label: 'Kanvas',
            isSelected: _selectedBoard == WorkspaceBoardType.canvas,
            onTap: () =>
                setState(() => _selectedBoard = WorkspaceBoardType.canvas),
          ),
          _BoardToggleOption(
            label: 'Kanban',
            isSelected: _selectedBoard == WorkspaceBoardType.kanban,
            onTap: () =>
                setState(() => _selectedBoard = WorkspaceBoardType.kanban),
          ),
        ],
      ),
    );
  }
}

class _BoardToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BoardToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor:
              isSelected ? AppTheme.background : Colors.transparent,
          foregroundColor:
              isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

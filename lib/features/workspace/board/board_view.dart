import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';

enum WorkspaceBoardType { kanban, canvas }

class BoardView extends StatefulWidget {
  final Widget canvasBoard;
  final Widget kanbanBoard;
  final WorkspaceBoardType initialBoard;

  const BoardView({
    super.key,
    required this.canvasBoard,
    required this.kanbanBoard,
    this.initialBoard = WorkspaceBoardType.kanban,
  });

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  late WorkspaceBoardType _selectedBoard = widget.initialBoard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header row matching `section === "Hybrid Board"` in App.tsx (lines 900-916)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hybrid Board',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Drag cards to organize your team’s work.',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.faint,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.soft,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPillOption(
                    label: 'Kanban',
                    isSelected: _selectedBoard == WorkspaceBoardType.kanban,
                    onTap: () => setState(
                        () => _selectedBoard = WorkspaceBoardType.kanban),
                  ),
                  _buildPillOption(
                    label: 'Canvas',
                    isSelected: _selectedBoard == WorkspaceBoardType.canvas,
                    onTap: () => setState(
                        () => _selectedBoard = WorkspaceBoardType.canvas),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_selectedBoard == WorkspaceBoardType.kanban)
          widget.kanbanBoard
        else
          widget.canvasBoard,
      ],
    );
  }

  Widget _buildPillOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? const [AppTheme.shadowSoft] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppTheme.ink : AppTheme.muted,
          ),
        ),
      ),
    );
  }
}

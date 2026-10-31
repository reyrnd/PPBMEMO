import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_theme.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../memo/cubit/memo_cubit.dart';
import '../../memo/models/memo.dart';
import '../../memo/screens/memo_editor_screen.dart';
import '../cubit/workspace_cubit.dart';

class KanbanBoard extends StatefulWidget {
  final String workspaceId;
  final String workspaceName;

  const KanbanBoard({
    super.key,
    this.workspaceId = 'design-system',
    this.workspaceName = 'Design System',
  });

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  final ScrollController _horizontalScrollController = ScrollController();
  String? _draggingMemoId;

  static const List<Map<String, dynamic>> _columnDefs = [
    {
      'id': 'todo',
      'title': 'Rencana',
      'dotColor': AppTheme.caramel,
    },
    {
      'id': 'doing',
      'title': 'Dikerjakan',
      'dotColor': AppTheme.olive,
    },
    {
      'id': 'done',
      'title': 'Selesai',
      'dotColor': AppTheme.plum,
    },
  ];

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  String _normalizeStatus(Memo memo) {
    final s = memo.status.toLowerCase();
    if (s == 'doing' || s == 'done' || s == 'todo') return s;
    final p = memo.progress ?? 0.0;
    if (p >= 1.0) return 'done';
    if (p > 0.0) return 'doing';
    return 'todo';
  }

  void _moveCardToColumn(Memo memo, String targetColumnId) {
    final currentStatus = _normalizeStatus(memo);
    if (currentStatus == targetColumnId) return;

    context.read<MemoCubit>().updateMemoStatus(
          widget.workspaceId,
          memo.id,
          targetColumnId,
        );

    final colTitle = _columnDefs
        .firstWhere(
          (c) => c['id'] == targetColumnId,
          orElse: () => {'title': targetColumnId},
        )['title'] as String;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dipindahkan ke kolom "$colTitle"'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  /// Auto-scroll horizontal saat user men-drag kartu mendekati tepi kiri/kanan layar
  void _handlePointerMoveWhileDragging(PointerMoveEvent event) {
    if (_draggingMemoId == null || !_horizontalScrollController.hasClients) {
      return;
    }
    final screenWidth = MediaQuery.of(context).size.width;
    final dx = event.position.dx;
    const edgeThreshold = 65.0;
    const scrollStep = 14.0;

    if (dx > screenWidth - edgeThreshold) {
      final maxScroll = _horizontalScrollController.position.maxScrollExtent;
      final target = (_horizontalScrollController.offset + scrollStep)
          .clamp(0.0, maxScroll);
      _horizontalScrollController.jumpTo(target);
    } else if (dx < edgeThreshold) {
      final target = (_horizontalScrollController.offset - scrollStep)
          .clamp(0.0, _horizontalScrollController.position.maxScrollExtent);
      _horizontalScrollController.jumpTo(target);
    }
  }

  Color _avatarBgForTone(String tone) {
    switch (tone) {
      case 'peach':
        return AppTheme.peach;
      case 'mint':
        return AppTheme.mint;
      case 'lilac':
        return AppTheme.lilac;
      default:
        return AppTheme.ink;
    }
  }

  Color _avatarTextColorForTone(String tone) {
    switch (tone) {
      case 'peach':
        return AppTheme.caramel;
      case 'mint':
        return AppTheme.olive;
      case 'lilac':
        return AppTheme.plum;
      default:
        return Colors.white;
    }
  }

  List<Map<String, String>> _resolveAssignees() {
    final workspaces = context.read<WorkspaceCubit>().state;
    final matched = workspaces.where((w) => w.id == widget.workspaceId);
    if (matched.isNotEmpty && matched.first.members.isNotEmpty) {
      final tones = ['dark', 'peach', 'mint', 'lilac'];
      final members = matched.first.members;
      return List.generate(members.length, (i) {
        final m = members[i];
        return {
          'initials': m.initials.isEmpty ? 'M' : m.initials,
          'name': m.name.isEmpty ? 'Member' : m.name,
          'tone': tones[i % tones.length],
        };
      });
    }
    return const [
      {'initials': 'NA', 'name': 'Naya', 'tone': 'dark'},
      {'initials': 'RK', 'name': 'Raka', 'tone': 'peach'},
      {'initials': 'SL', 'name': 'Sora', 'tone': 'mint'},
      {'initials': 'AL', 'name': 'Aruna', 'tone': 'lilac'},
    ];
  }

  void _openTaskFormSheet(String columnId, {Memo? existingMemo}) {
    final isEdit = existingMemo != null;
    final titleCtrl = TextEditingController(text: existingMemo?.title ?? '');
    final noteCtrl = TextEditingController(text: existingMemo?.content ?? '');

    final assignees = _resolveAssignees();
    String selectedAssignee = existingMemo?.assignee.isNotEmpty == true
        ? existingMemo!.assignee
        : assignees.first['initials']!;
    String selectedTone = existingMemo?.assigneeTone.isNotEmpty == true
        ? existingMemo!.assigneeTone
        : assignees.first['tone']!;
    String selectedDate = existingMemo?.dueDate ?? '';
    String selectedStatus = existingMemo != null
        ? _normalizeStatus(existingMemo)
        : columnId;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: SheetFrame(
              title: isEdit ? 'Edit card' : 'Add card to board',
              description: isEdit
                  ? 'Update task details, column status, assignee, or deadline.'
                  : 'Create a new card directly in this workspace board.',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title input card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [AppTheme.shadowSoft],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TASK TITLE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.faint,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: titleCtrl,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'e.g. Finalize onboarding flow',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.faint,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Notes input card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [AppTheme.shadowSoft],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NOTES',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.faint,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: noteCtrl,
                          maxLines: 3,
                          minLines: 2,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.muted,
                            height: 1.5,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Add context or acceptance criteria...',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: AppTheme.faint,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Status Column Selector
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [AppTheme.shadowSoft],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'COLUMN STATUS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.faint,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: _columnDefs.map((col) {
                            final colId = col['id'] as String;
                            final colTitle = col['title'] as String;
                            final isSelected = selectedStatus == colId;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: GestureDetector(
                                  onTap: () => setSheetState(
                                    () => selectedStatus = colId,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.ink
                                          : AppTheme.surface,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      colTitle,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? Colors.white
                                            : AppTheme.ink,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Assign Teammate
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [AppTheme.shadowSoft],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ASSIGN TEAMMATE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.faint,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: assignees.map((a) {
                              final initials = a['initials']!;
                              final name = a['name']!;
                              final tone = a['tone']!;
                              final isSelected = selectedAssignee == initials;

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () => setSheetState(() {
                                    selectedAssignee = initials;
                                    selectedTone = tone;
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.ink
                                          : AppTheme.surface,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: _avatarBgForTone(tone),
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            initials,
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w700,
                                              color: _avatarTextColorForTone(
                                                tone,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          name,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? Colors.white
                                                : AppTheme.ink,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Due Date card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [AppTheme.shadowSoft],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'DUE DATE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.faint,
                                letterSpacing: 0.8,
                              ),
                            ),
                            if (selectedDate.isNotEmpty)
                              GestureDetector(
                                onTap: () =>
                                    setSheetState(() => selectedDate = ''),
                                child: const Text(
                                  'Clear',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.faint,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final initial =
                                DateTime.tryParse(selectedDate) ??
                                DateTime.now();
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: initial,
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2032),
                            );
                            if (picked != null) {
                              setSheetState(() {
                                selectedDate =
                                    '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.canvas,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 14,
                                  color: AppTheme.ink,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  selectedDate.isEmpty
                                      ? 'Select due date...'
                                      : DeadlineBadge.formatShortDate(
                                          selectedDate,
                                        ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selectedDate.isEmpty
                                        ? AppTheme.faint
                                        : AppTheme.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Action buttons
                  Row(
                    children: [
                      if (isEdit) ...[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<MemoCubit>().delete(
                                    widget.workspaceId,
                                    existingMemo.id,
                                  );
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.blush,
                              foregroundColor: AppTheme.coral,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            final trimmed = titleCtrl.text.trim();
                            if (trimmed.isEmpty) return;

                            if (isEdit) {
                              await context.read<MemoCubit>().updateMemo(
                                    widget.workspaceId,
                                    existingMemo.id,
                                    trimmed,
                                    noteCtrl.text.trim(),
                                    dueDate: selectedDate,
                                    status: selectedStatus,
                                    assignee: selectedAssignee,
                                    assigneeTone: selectedTone,
                                  );
                            } else {
                              await context.read<MemoCubit>().addMemo(
                                    workspaceId: widget.workspaceId,
                                    title: trimmed,
                                    content: noteCtrl.text.trim(),
                                    tag: widget.workspaceName,
                                    dueDate: selectedDate,
                                    status: selectedStatus,
                                    assignee: selectedAssignee,
                                    assigneeTone: selectedTone,
                                  );
                            }
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.ink,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            isEdit ? 'Save changes' : 'Add to board',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openTaskDetail(Memo memo, String columnTitle) {
    final currentStatus = _normalizeStatus(memo);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SheetFrame(
        title: memo.title.isEmpty ? 'Untitled task' : memo.title,
        description: '$columnTitle · Assigned to ${memo.assignee}',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [AppTheme.shadowSoft],
              ),
              child: Text(
                memo.content.trim().isNotEmpty
                    ? memo.content
                    : 'No additional notes for this card yet.',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.muted,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Quick Move Column Row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [AppTheme.shadowSoft],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MOVE TO COLUMN',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.faint,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _columnDefs.map((col) {
                      final colId = col['id'] as String;
                      final colName = col['title'] as String;
                      final isCurrent = currentStatus == colId;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(ctx);
                              _moveCardToColumn(memo, colId);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? AppTheme.ink
                                    : AppTheme.surface,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                colName,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isCurrent
                                      ? Colors.white
                                      : AppTheme.ink,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            if (memo.dueDate.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Deadline',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.muted,
                    ),
                  ),
                  DeadlineBadge(
                    date: memo.dueDate,
                    completed: currentStatus == 'done',
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openTaskFormSheet(
                        currentStatus,
                        existingMemo: memo,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.ink,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Quick edit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MemoEditorScreen(
                            memoId: memo.id,
                            workspaceId: widget.workspaceId,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.ink,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Open memo',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoCubit, MemoState>(
      builder: (context, state) {
        final allMemos =
            state is MemoLoaded ? state.memos : const <Memo>[];
        final workspaceMemos = allMemos
            .where((m) => m.workspaceId == widget.workspaceId)
            .toList();

        return Listener(
          onPointerMove: _handlePointerMoveWhileDragging,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            physics: _draggingMemoId != null
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _columnDefs.map((colDef) {
                  final colId = colDef['id'] as String;
                  final colTitle = colDef['title'] as String;
                  final dotColor = colDef['dotColor'] as Color;
                  final cards = workspaceMemos
                      .where((m) => _normalizeStatus(m) == colId)
                      .toList();

                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: DragTarget<Memo>(
                      onWillAcceptWithDetails: (details) =>
                          _normalizeStatus(details.data) != colId,
                      onAcceptWithDetails: (details) {
                        setState(() => _draggingMemoId = null);
                        _moveCardToColumn(details.data, colId);
                      },
                      builder: (context, candidateData, rejectedData) {
                        final isHovering = candidateData.isNotEmpty;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: 245,
                          constraints: const BoxConstraints(minHeight: 270),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isHovering
                                ? AppTheme.mint.withValues(alpha: 0.55)
                                : AppTheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: isHovering
                                ? Border.all(color: AppTheme.ink, width: 1.8)
                                : Border.all(
                                    color: Colors.transparent,
                                    width: 1.8,
                                  ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Column Header
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: dotColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          colTitle,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.ink,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${cards.length}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.muted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              if (isHovering)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'Lepas untuk pindah ke $colTitle',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.olive,
                                    ),
                                  ),
                                ),

                              if (cards.isEmpty && !isHovering)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Text(
                                    'Belum ada kartu di $colTitle.\nTarik kartu ke sini atau klik + Add card.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.faint,
                                      height: 1.4,
                                    ),
                                  ),
                                ),

                              // Cards List (Direct Draggable so mouse/touch drag works immediately)
                              ...cards.map((memo) {
                                return Draggable<Memo>(
                                  data: memo,
                                  onDragStarted: () => setState(
                                    () => _draggingMemoId = memo.id,
                                  ),
                                  onDragEnd: (_) => setState(
                                    () => _draggingMemoId = null,
                                  ),
                                  onDraggableCanceled: (_, __) => setState(
                                    () => _draggingMemoId = null,
                                  ),
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: Transform.rotate(
                                      angle: 0.025,
                                      child: SizedBox(
                                        width: 220,
                                        child: Opacity(
                                          opacity: 0.95,
                                          child: _buildKanbanCard(
                                            memo,
                                            colId,
                                            colTitle,
                                            isDraggingFeedback: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.3,
                                    child: _buildKanbanCard(
                                      memo,
                                      colId,
                                      colTitle,
                                    ),
                                  ),
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.grab,
                                    child: _buildKanbanCard(
                                      memo,
                                      colId,
                                      colTitle,
                                    ),
                                  ),
                                );
                              }),

                              // + Add card button
                              const SizedBox(height: 2),
                              GestureDetector(
                                onTap: () => _openTaskFormSheet(colId),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppTheme.line,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '+ Add card',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.muted,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKanbanCard(
    Memo memo,
    String colId,
    String colTitle, {
    bool isDraggingFeedback = false,
  }) {
    final dueDate = memo.dueDate;
    final tone = memo.assigneeTone.isEmpty ? 'dark' : memo.assigneeTone;
    final assignee = memo.assignee.isEmpty ? 'NA' : memo.assignee;
    final doneChecklist =
        memo.checklist.where((c) => c['done'] == true).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [AppTheme.shadowSoft],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: isDraggingFeedback
                ? null
                : () => _openTaskDetail(memo, colTitle),
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1, right: 6),
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        size: 14,
                        color: AppTheme.faint,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        memo.title.isEmpty ? 'Untitled task' : memo.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                          height: 1.35,
                        ),
                      ),
                    ),
                    if (!isDraggingFeedback) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () =>
                            _openTaskFormSheet(colId, existingMemo: memo),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: AppTheme.surface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 11,
                            color: AppTheme.muted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  memo.preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.muted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _avatarBgForTone(tone),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  assignee,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: _avatarTextColorForTone(tone),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              if (memo.checklist.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.mint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$doneChecklist/${memo.checklist.length}',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.olive,
                    ),
                  ),
                ),
              const Spacer(),
              if (dueDate.isNotEmpty)
                DeadlineBadge(
                  date: dueDate,
                  completed: colId == 'done',
                  onTap: isDraggingFeedback
                      ? null
                      : () => _openTaskFormSheet(colId, existingMemo: memo),
                )
              else if (!isDraggingFeedback)
                GestureDetector(
                  onTap: () => _openTaskFormSheet(colId, existingMemo: memo),
                  child: const Text(
                    'Add date',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.faint,
                    ),
                  ),
                ),
            ],
          ),

          // Quick move column buttons at bottom of card for instant 1-tap move
          if (!isDraggingFeedback) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(top: 6),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.line)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _columnDefs.map((col) {
                  final targetId = col['id'] as String;
                  final targetTitle = col['title'] as String;
                  final isCurrent = colId == targetId;
                  return GestureDetector(
                    onTap: isCurrent
                        ? null
                        : () => _moveCardToColumn(memo, targetId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isCurrent ? AppTheme.ink : AppTheme.canvas,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        targetTitle,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: isCurrent ? Colors.white : AppTheme.muted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

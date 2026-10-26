import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/features/memo/models/memo.dart';

enum KanbanStatus { planned, inProgress, completed }

class KanbanBoard extends StatefulWidget {
  final List<Memo> memos;
  final ValueChanged<Map<String, KanbanStatus>>? onStatusesChanged;
  final ValueChanged<Memo>? onMemoTap;

  const KanbanBoard({
    super.key,
    required this.memos,
    this.onStatusesChanged,
    this.onMemoTap,
  });

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  final Map<String, KanbanStatus> _statuses = {};
  KanbanStatus? _hoveredColumn;

  static const _columns = [
    (status: KanbanStatus.planned, title: 'Rencana'),
    (status: KanbanStatus.inProgress, title: 'Dikerjakan'),
    (status: KanbanStatus.completed, title: 'Selesai'),
  ];

  @override
  void didUpdateWidget(covariant KanbanBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentIds = widget.memos.map((memo) => memo.id).toSet();
    _statuses.removeWhere((id, _) => !currentIds.contains(id));
    for (final memo in widget.memos) {
      _statuses.putIfAbsent(memo.id, () => KanbanStatus.planned);
    }
  }

  void _moveMemo(Memo memo, KanbanStatus status) {
    if (_statuses[memo.id] == status) return;
    setState(() {
      _statuses[memo.id] = status;
      _hoveredColumn = null;
    });
    widget.onStatusesChanged?.call(Map.unmodifiable(_statuses));
  }

  @override
  Widget build(BuildContext context) {
    for (final memo in widget.memos) {
      _statuses.putIfAbsent(memo.id, () => KanbanStatus.planned);
    }

    return SizedBox(
      height: double.infinity,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _columns.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final column = _columns[index];
          final columnMemos = widget.memos
              .where((memo) => _statuses[memo.id] == column.status)
              .toList();
          return _buildColumn(column, columnMemos);
        },
      ),
    );
  }

  Widget _buildColumn(
    ({KanbanStatus status, String title}) column,
    List<Memo> memos,
  ) {
    final isHovered = _hoveredColumn == column.status;

    return SizedBox(
      width: 270,
      child: DragTarget<Memo>(
        onWillAcceptWithDetails: (details) {
          setState(() => _hoveredColumn = column.status);
          return _statuses[details.data.id] != column.status;
        },
        onLeave: (_) {
          if (_hoveredColumn == column.status) {
            setState(() => _hoveredColumn = null);
          }
        },
        onAcceptWithDetails: (details) =>
            _moveMemo(details.data, column.status),
        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isHovered
                  ? AppTheme.bgPill
                  : AppTheme.editorToolbarBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHovered ? AppTheme.primary : AppTheme.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        column.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '${memos.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: memos.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _buildDraggableMemo(memos[index]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDraggableMemo(Memo memo) {
    final card = _KanbanMemoCard(memo: memo);
    return Draggable<Memo>(
      data: memo,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 248, child: card),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: GestureDetector(
        onTap: widget.onMemoTap == null ? null : () => widget.onMemoTap!(memo),
        child: card,
      ),
    );
  }
}

class _KanbanMemoCard extends StatelessWidget {
  final Memo memo;

  const _KanbanMemoCard({required this.memo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            memo.category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            memo.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            memo.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${memo.author} • ${memo.time}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

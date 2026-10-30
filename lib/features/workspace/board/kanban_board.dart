import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/features/memo/models/memo.dart';
import 'board_memo_card.dart';

enum KanbanStatus { planned, inProgress, completed }

class KanbanBoard extends StatefulWidget {
  final List<Memo> memos;
  final void Function(Memo memo, KanbanStatus status)? onMemoMoved;
  final ValueChanged<Memo>? onMemoTap;

  const KanbanBoard({
    super.key,
    required this.memos,
    this.onMemoMoved,
    this.onMemoTap,
  });

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  static const _columns = [
    (status: KanbanStatus.planned, title: 'Rencana'),
    (status: KanbanStatus.inProgress, title: 'Dikerjakan'),
    (status: KanbanStatus.completed, title: 'Selesai'),
  ];

  final _pageController = PageController();
  int _page = 0;
  bool _dragging = false;
  KanbanStatus? _hoveredColumn;
  Timer? _edgeDelay;
  Timer? _edgeTimer;
  double _pageWidth = 320;

  @override
  void dispose() {
    _stopEdgeTimer();
    _pageController.dispose();
    super.dispose();
  }

  KanbanStatus _statusOf(Memo m) {
    for (final s in KanbanStatus.values) {
      if (s.name == m.boardStatus) return s;
    }
    return KanbanStatus.planned;
  }

  List<Memo> _memosIn(KanbanStatus s) =>
      widget.memos.where((m) => _statusOf(m) == s).toList();

  void _moveMemo(Memo memo, KanbanStatus status) {
    if (_statusOf(memo) != status) widget.onMemoMoved?.call(memo, status);
  }

  void _goToPage(int index) {
    if (index < 0 || index >= _columns.length) {
      _stopEdgeTimer();
      return;
    }
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _startEdgeTimer(int dir) {
    _stopEdgeTimer();
    _edgeDelay = Timer(const Duration(milliseconds: 350), () {
      _goToPage(_page + dir);
      _edgeTimer = Timer.periodic(
        const Duration(milliseconds: 800),
        (_) => _goToPage(_page + dir),
      );
    });
  }

  void _stopEdgeTimer() {
    _edgeDelay?.cancel();
    _edgeTimer?.cancel();
    _edgeDelay = null;
    _edgeTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _pageWidth = constraints.maxWidth;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTabs(),
          const SizedBox(height: 6),
          Text(
            _dragging
                ? 'Lepas di kolom tujuan'
                : 'Tahan kartu, lalu seret ke tepi layar atau ke tab untuk memindahkan',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _columns.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) =>
                      _KeepAlive(child: _buildColumn(_columns[i])),
                ),
                _edgeZone(isLeft: true),
                _edgeZone(isLeft: false),
              ],
            ),
          ),
        ],
      );
    });
  }

  // ---------- Tab di atas ----------
  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.editorToolbarBackground,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _columns.length; i++)
            Expanded(child: _buildTab(i)),
        ],
      ),
    );
  }

  Widget _buildTab(int i) {
    final col = _columns[i];
    final selected = _page == i;
    final count = _memosIn(col.status).length;

    return DragTarget<Memo>(
      onWillAcceptWithDetails: (d) => _statusOf(d.data) != col.status,
      onAcceptWithDetails: (d) {
        setState(() => _dragging = false);
        _moveMemo(d.data, col.status);
      },
      builder: (context, candidate, _) {
        final hovered = candidate.isNotEmpty;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _goToPage(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? AppTheme.primary
                  : (hovered ? AppTheme.bgPill : Colors.transparent),
              borderRadius: BorderRadius.circular(20),
              border: hovered ? Border.all(color: AppTheme.primary) : null,
            ),
            child: Text(
              '${col.title} ($count)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------- Satu kolom penuh ----------
  Widget _buildColumn(({KanbanStatus status, String title}) column) {
    final memos = _memosIn(column.status);
    final hovered = _hoveredColumn == column.status;

    return DragTarget<Memo>(
      onWillAcceptWithDetails: (d) {
        final ok = _statusOf(d.data) != column.status;
        if (ok) setState(() => _hoveredColumn = column.status);
        return ok;
      },
      onLeave: (_) {
        if (_hoveredColumn == column.status) {
          setState(() => _hoveredColumn = null);
        }
      },
      onAcceptWithDetails: (d) {
        setState(() {
          _hoveredColumn = null;
          _dragging = false;
        });
        _moveMemo(d.data, column.status);
      },
      builder: (context, _, __) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: hovered ? AppTheme.bgPill : AppTheme.editorToolbarBackground,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: hovered ? AppTheme.primary : AppTheme.border),
          ),
          child: memos.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada memo di kolom ini.\nSeret kartu ke sini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                )
              : ListView.separated(
                  itemCount: memos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _buildDraggableMemo(memos[i]),
                ),
        );
      },
    );
  }

  Widget _buildDraggableMemo(Memo memo) {
    final card = BoardMemoCard(memo: memo);
    return LongPressDraggable<Memo>(
      data: memo,
      delay: const Duration(milliseconds: 250),
      hapticFeedbackOnStart: true,
      onDragStarted: () => setState(() => _dragging = true),
      onDragEnd: (_) {
        _stopEdgeTimer();
        if (mounted) {
          setState(() {
            _dragging = false;
            _hoveredColumn = null;
          });
        }
      },
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: _pageWidth - 20,
          child: BoardMemoCard(memo: memo, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: GestureDetector(
        onTap: widget.onMemoTap == null ? null : () => widget.onMemoTap!(memo),
        child: card,
      ),
    );
  }

  // ---------- Zona tepi untuk auto-geser ----------
  Widget _edgeZone({required bool isLeft}) {
    final dir = isLeft ? -1 : 1;
    final target = _page + dir;
    if (!_dragging || target < 0 || target >= _columns.length) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      top: 0,
      bottom: 0,
      width: 56,
      child: DragTarget<Memo>(
        onWillAcceptWithDetails: (_) {
          _startEdgeTimer(dir);
          return true;
        },
        onLeave: (_) => _stopEdgeTimer(),
        onAcceptWithDetails: (_) => _stopEdgeTimer(),
        builder: (context, candidate, _) {
          final active = candidate.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
                end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
                colors: [
                  active ? const Color(0x80000000) : const Color(0x40000000),
                  const Color(0x00000000),
                ],
              ),
            ),
            alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              isLeft ? Icons.chevron_left : Icons.chevron_right,
              color: Colors.white,
              size: active ? 34 : 28,
            ),
          );
        },
      ),
    );
  }
}

// Menjaga ketiga halaman tetap hidup selama menyeret kartu
class _KeepAlive extends StatefulWidget {
  final Widget child;
  const _KeepAlive({required this.child});

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

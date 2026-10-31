import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/core/widgets/app_bottom_sheet.dart';
import 'package:memospace/features/memo/cubit/memo_cubit.dart';
import 'package:memospace/features/memo/models/memo.dart';

class CanvasBoard extends StatefulWidget {
  final String workspaceId;
  final String workspaceName;
  final List<Memo> memos;
  final void Function(Memo memo, Offset position)? onMemoMoved;
  final ValueChanged<Memo>? onMemoTap;

  const CanvasBoard({
    super.key,
    this.workspaceId = '',
    this.workspaceName = 'Workspace',
    required this.memos,
    this.onMemoMoved,
    this.onMemoTap,
  });

  @override
  State<CanvasBoard> createState() => _CanvasBoardState();
}

class _CanvasItem {
  final String id;
  final String title;
  final String body;
  Offset position;
  final Color cardColor;
  final Color accentColor;
  final IconData icon;
  final String initials;
  final Memo sourceMemo;

  _CanvasItem({
    required this.id,
    required this.title,
    required this.body,
    required this.position,
    required this.cardColor,
    required this.accentColor,
    required this.icon,
    required this.initials,
    required this.sourceMemo,
  });
}

class _CanvasBoardState extends State<CanvasBoard> {
  Offset _panOffset = const Offset(10, 10);
  double _scale = 0.9;
  final Map<String, Offset> _memoPositions = {};

  List<_CanvasItem> _allCanvasItems() {
    final items = <_CanvasItem>[];
    final palette = [
      (AppTheme.peach, AppTheme.caramel, Icons.auto_awesome_rounded),
      (AppTheme.mint, AppTheme.olive, Icons.check_circle_outline_rounded),
      (AppTheme.lilac, AppTheme.plum, Icons.menu_book_rounded),
      (Colors.white, AppTheme.muted, Icons.bolt_rounded),
    ];

    for (var i = 0; i < widget.memos.length; i++) {
      final memo = widget.memos[i];
      final style = palette[i % palette.length];
      final defaultPos = Offset(
        memo.boardX ?? (30.0 + (i % 2) * 205.0),
        memo.boardY ?? (55.0 + (i ~/ 2) * 185.0),
      );
      final pos = _memoPositions[memo.id] ?? defaultPos;
      final initials = memo.assignee.trim().isNotEmpty
          ? memo.assignee.trim()
          : (memo.authorName.trim().isNotEmpty
              ? memo.authorName
                  .trim()
                  .split(RegExp(r'\s+'))
                  .map((e) => e[0])
                  .take(2)
                  .join()
                  .toUpperCase()
              : 'NA');

      items.add(
        _CanvasItem(
          id: memo.id,
          title: memo.title.isEmpty ? 'Untitled memo' : memo.title,
          body: memo.preview.isEmpty ? memo.content : memo.preview,
          position: pos,
          cardColor: style.$1,
          accentColor: style.$2,
          icon: style.$3,
          initials: initials,
          sourceMemo: memo,
        ),
      );
    }
    return items;
  }

  void _zoomBy(double delta) {
    setState(() {
      _scale = (_scale + delta).clamp(0.5, 1.6);
    });
  }

  void _fitToScreen() {
    final items = _allCanvasItems();
    if (items.isEmpty) return;
    final minX = items.map((e) => e.position.dx).reduce(math.min);
    final minY = items.map((e) => e.position.dy).reduce(math.min);
    final maxX = items.map((e) => e.position.dx + 190).reduce(math.max);
    final maxY = items.map((e) => e.position.dy + 175).reduce(math.max);
    final contentW = (maxX - minX).clamp(200.0, 2000.0);
    final contentH = (maxY - minY).clamp(200.0, 2000.0);
    final nextScale =
        math.min(320.0 / contentW, 410.0 / contentH).clamp(0.5, 1.0);

    setState(() {
      _scale = nextScale;
      _panOffset = Offset(
        (340 - contentW * nextScale) / 2 - minX * nextScale,
        (460 - contentH * nextScale) / 2 - minY * nextScale,
      );
    });
  }

  void _showCanvasMenuSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => SheetFrame(
        title: 'Add to canvas',
        description: 'Create a new memo card or fit all cards into view.',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMenuCard(
              icon: Icons.description_outlined,
              iconBg: AppTheme.peach,
              iconFg: AppTheme.caramel,
              title: 'Add Sticky Note',
              subtitle: 'Capture a thought anywhere on the canvas.',
              onTap: () {
                Navigator.pop(sheetCtx);
                _showCreateCanvasCardSheet(isChecklist: false);
              },
            ),
            const SizedBox(height: 10),
            _buildMenuCard(
              icon: Icons.check_circle_outline_rounded,
              iconBg: AppTheme.mint,
              iconFg: AppTheme.olive,
              title: 'Add Checklist',
              subtitle: 'Add an actionable item to the canvas.',
              onTap: () {
                Navigator.pop(sheetCtx);
                _showCreateCanvasCardSheet(isChecklist: true);
              },
            ),
            const SizedBox(height: 10),
            _buildMenuCard(
              icon: Icons.grid_view_rounded,
              iconBg: AppTheme.surface,
              iconFg: AppTheme.muted,
              title: 'Fit to Screen',
              subtitle: 'Center every card at the best zoom level.',
              onTap: () {
                Navigator.pop(sheetCtx);
                _fitToScreen();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [AppTheme.shadowSoft],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconFg, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.faint,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppTheme.faint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateCanvasCardSheet({required bool isChecklist}) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final canSave = titleCtrl.text.trim().isNotEmpty;
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: SheetFrame(
              title: isChecklist ? 'Add checklist' : 'Add sticky note',
              description:
                  'This memo will be saved to your workspace and placed on the canvas.',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
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
                          'TITLE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.faint,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: titleCtrl,
                          autofocus: true,
                          onChanged: (_) => setSheetState(() {}),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                isChecklist ? 'Checklist title' : 'Note title',
                            hintStyle: const TextStyle(color: AppTheme.faint),
                            filled: false,
                            isDense: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
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
                        Text(
                          isChecklist ? 'FIRST ITEM' : 'NOTE',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.faint,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: bodyCtrl,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.muted,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Add details',
                            hintStyle: TextStyle(color: AppTheme.faint),
                            filled: false,
                            isDense: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(sheetCtx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [AppTheme.shadowSoft],
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.muted,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: !canSave
                            ? null
                            : () async {
                                final wsId = widget.workspaceId.isNotEmpty
                                    ? widget.workspaceId
                                    : (widget.memos.isNotEmpty
                                        ? widget.memos.first.workspaceId
                                        : 'personal-space');
                                final count = widget.memos.length;
                                final newX = 40.0 + (count % 2) * 200.0;
                                final newY = 60.0 + (count ~/ 2) * 180.0;

                                await context.read<MemoCubit>().addMemo(
                                      workspaceId: wsId,
                                      title: titleCtrl.text.trim(),
                                      content: isChecklist
                                          ? ''
                                          : bodyCtrl.text.trim(),
                                      tag: widget.workspaceName,
                                      dueDate: '',
                                      checklistTitle: isChecklist
                                          ? titleCtrl.text.trim()
                                          : '',
                                      boardX: newX,
                                      boardY: newY,
                                      checklist: isChecklist
                                          ? [
                                              {
                                                'id':
                                                    'chk-${DateTime.now().millisecondsSinceEpoch}',
                                                'text': bodyCtrl.text
                                                        .trim()
                                                        .isEmpty
                                                    ? 'First checklist item'
                                                    : bodyCtrl.text.trim(),
                                                'done': false,
                                              }
                                            ]
                                          : const [],
                                    );
                                if (!sheetCtx.mounted) return;
                                Navigator.pop(sheetCtx);
                              },
                        child: Opacity(
                          opacity: canSave ? 1.0 : 0.35,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.ink,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Text(
                              'Add to canvas',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
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

  @override
  Widget build(BuildContext context) {
    final items = _allCanvasItems();

    return Container(
      height: 500,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [AppTheme.shadowSoft],
      ),
      child: Stack(
        children: [
          // Pan & Dot Grid Area
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                setState(() {
                  _panOffset += details.delta;
                });
              },
              child: CustomPaint(
                painter: _DotGridPainter(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (items.isEmpty)
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.dashboard_customize_outlined,
                              size: 28,
                              color: AppTheme.faint,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Canvas masih kosong.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.muted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Klik "+ Add memo" di kiri bawah untuk menambahkan kartu.',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.faint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ...items.map((item) {
                      final screenX =
                          _panOffset.dx + item.position.dx * _scale;
                      final screenY =
                          _panOffset.dy + item.position.dy * _scale;

                      return Positioned(
                        left: screenX,
                        top: screenY,
                        child: Transform.scale(
                          scale: _scale,
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                final nextPos =
                                    item.position + details.delta / _scale;
                                item.position = nextPos;
                                _memoPositions[item.id] = nextPos;
                              });
                            },
                            onPanEnd: (_) {
                              final pos = _memoPositions[item.id];
                              if (pos != null) {
                                widget.onMemoMoved?.call(item.sourceMemo, pos);
                              }
                            },
                            onTap: () => widget.onMemoTap?.call(item.sourceMemo),
                            child: _buildStickyCard(item),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Top-left floating badge: "Drag empty space to pan"
          Positioned(
            left: 14,
            top: 14,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [AppTheme.shadowSoft],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.pan_tool_outlined,
                      size: 12,
                      color: AppTheme.muted,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Drag empty space to pan',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom-left floating button: "+ Add memo"
          Positioned(
            left: 14,
            bottom: 14,
            child: GestureDetector(
              onTap: _showCanvasMenuSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [AppTheme.shadowCard],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 14, color: AppTheme.ink),
                    SizedBox(width: 5),
                    Text(
                      'Add memo',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom-right floating dark zoom controls
          Positioned(
            right: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.ink,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [AppTheme.shadowCard],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _zoomBy(-0.1),
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.remove_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      _panOffset = const Offset(10, 10);
                      _scale = 1.0;
                    }),
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 38),
                      alignment: Alignment.center,
                      child: Text(
                        '${(_scale * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _zoomBy(0.1),
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.add_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyCard(_CanvasItem item) {
    return Container(
      width: 192,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [AppTheme.shadowCard],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, size: 15, color: item.accentColor),
              ),
              Icon(
                Icons.drag_indicator_rounded,
                size: 16,
                color: AppTheme.ink.withValues(alpha: 0.22),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.muted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.ink.withValues(alpha: 0.06),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.ink,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    item.initials,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Tap to open',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
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

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.ink.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    const spacing = 22.0;
    for (double x = 11; x < size.width; x += spacing) {
      for (double y = 11; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

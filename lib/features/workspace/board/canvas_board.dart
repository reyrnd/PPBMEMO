import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memospace/core/app_theme.dart';
import 'package:memospace/core/utils/attachment_picker.dart';
import 'package:memospace/core/widgets/app_bottom_sheet.dart';
import 'package:memospace/core/widgets/urgent_flame_card.dart';
import 'package:memospace/features/memo/cubit/memo_cubit.dart';
import 'package:memospace/features/memo/models/memo.dart';
import 'package:memospace/features/memo/screens/memo_editor_screen.dart';
import 'package:memospace/features/workspace/cubit/workspace_cubit.dart';

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
              title: 'Add Memo / Sticky Note',
              subtitle: 'Write notes, attach files/photos & set deadline.',
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
              subtitle: 'Create a multi-item checklist card on the canvas.',
              onTap: () {
                Navigator.pop(sheetCtx);
                _showCreateCanvasCardSheet(isChecklist: true);
              },
            ),
            const SizedBox(height: 10),
            _buildMenuCard(
              icon: Icons.open_in_full_rounded,
              iconBg: AppTheme.lilac,
              iconFg: AppTheme.plum,
              title: 'Open Full Memo Editor',
              subtitle: 'Use rich text formatting, camera & full attachments.',
              onTap: () {
                Navigator.pop(sheetCtx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MemoEditorScreen(
                      workspaceId: widget.workspaceId,
                    ),
                  ),
                );
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

  void _showCreateCanvasCardSheet({required bool isChecklist}) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    final checklistInputCtrl = TextEditingController();
    final List<Map<String, dynamic>> checklistItems = [];
    final List<Map<String, dynamic>> attachedFiles = [];
    final assignees = _resolveAssignees();
    final List<Map<String, String>> selectedAssignees = [
      Map<String, String>.from(assignees.first),
    ];
    String selectedDate = '';
    bool isPickingFile = false;

    bool isMemberSelected(String initials, String name) {
      return selectedAssignees.any(
        (m) =>
            m['initials'] == initials &&
            (m['name'] == name || m['name'] == initials),
      );
    }

    void toggleMember(Map<String, String> member, StateSetter setSheetState) {
      setSheetState(() {
        final idx = selectedAssignees.indexWhere(
          (m) =>
              m['initials'] == member['initials'] &&
              (m['name'] == member['name'] ||
                  m['name'] == member['initials']),
        );
        if (idx >= 0) {
          if (selectedAssignees.length > 1) {
            selectedAssignees.removeAt(idx);
          }
        } else {
          selectedAssignees.add(Map<String, String>.from(member));
        }
      });
    }

    void addCurrentChecklistItem(StateSetter setSheetState) {
      final text = checklistInputCtrl.text.trim();
      if (text.isEmpty) return;
      setSheetState(() {
        checklistItems.add({
          'id': 'chk-${DateTime.now().microsecondsSinceEpoch}',
          'text': text,
          'done': false,
        });
        checklistInputCtrl.clear();
      });
    }

    Future<void> pickCanvasAttachment(
      String type,
      StateSetter setSheetState, {
      bool useCamera = false,
    }) async {
      setSheetState(() => isPickingFile = true);
      try {
        final picked = await pickAttachmentFromDevice(
          context: context,
          type: type,
          useCamera: useCamera,
        );
        if (picked != null) {
          setSheetState(() {
            attachedFiles.add({
              'id': 'att-${DateTime.now().millisecondsSinceEpoch}',
              'type': picked.type,
              'name': picked.name,
              'meta': picked.sizeLabel,
              if (picked.dataUrl != null) 'dataUrl': picked.dataUrl,
            });
          });
        }
      } finally {
        setSheetState(() => isPickingFile = false);
      }
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final canSave = titleCtrl.text.trim().isNotEmpty;
          return SheetFrame(
            title: isChecklist ? 'Add checklist to canvas' : 'Add memo to canvas',
            description: isChecklist
                ? 'Tambahkan judul dan daftar item checklist yang ingin ditaruh di canvas.'
                : 'Isi catatan, lampirkan foto/dokumen, atau atur tenggat waktu memo.',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TITLE INPUT
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
                      const SizedBox(height: 6),
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
                              isChecklist ? 'Judul checklist...' : 'Judul memo...',
                          hintStyle: const TextStyle(color: AppTheme.faint),
                          filled: false,
                          isDense: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 2. NOTES OR MULTI-ITEM CHECKLIST BUILDER
                if (isChecklist) ...[
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'CHECKLIST ITEMS',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.faint,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              '${checklistItems.length} item',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.olive,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (checklistItems.isNotEmpty) ...[
                          ...checklistItems.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final item = entry.value;
                            final done = item['done'] == true;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.canvas,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => setSheetState(() {
                                        checklistItems[idx]['done'] = !done;
                                      }),
                                      child: Icon(
                                        done
                                            ? Icons.check_circle_rounded
                                            : Icons.radio_button_unchecked_rounded,
                                        size: 16,
                                        color: done
                                            ? AppTheme.olive
                                            : AppTheme.muted,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item['text'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.ink,
                                          decoration: done
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => setSheetState(() {
                                        checklistItems.removeAt(idx);
                                      }),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 15,
                                        color: AppTheme.faint,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 4),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: checklistInputCtrl,
                                onSubmitted: (_) =>
                                    addCurrentChecklistItem(setSheetState),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.ink,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Tulis item lalu klik + Add...',
                                  hintStyle: TextStyle(color: AppTheme.faint),
                                  filled: false,
                                  isDense: true,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 2,
                                    vertical: 6,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () =>
                                  addCurrentChecklistItem(setSheetState),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.mint,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add_rounded,
                                      size: 14,
                                      color: AppTheme.olive,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'Add item',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.olive,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Note / Description input (always available so both Memo and Checklist can have notes)
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
                        isChecklist ? 'ADDITIONAL NOTE (OPTIONAL)' : 'NOTE CONTENT',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.faint,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: bodyCtrl,
                        minLines: isChecklist ? 1 : 3,
                        maxLines: 4,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.ink,
                          height: 1.45,
                        ),
                        decoration: InputDecoration(
                          hintText: isChecklist
                              ? 'Catatan tambahan (opsional)...'
                              : 'Tulis isi memo atau detail ide Anda...',
                          hintStyle: const TextStyle(color: AppTheme.faint),
                          filled: false,
                          isDense: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 3. ATTACHMENTS & DEADLINE ROW
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
                            'ATTACHMENTS & DUE DATE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.faint,
                              letterSpacing: 0.8,
                            ),
                          ),
                          if (isPickingFile)
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.8,
                                color: AppTheme.ink,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildQuickAttachChip(
                              icon: Icons.camera_alt_outlined,
                              label: 'Camera',
                              bg: AppTheme.peach,
                              fg: AppTheme.caramel,
                              onTap: () => pickCanvasAttachment(
                                'Photo',
                                setSheetState,
                                useCamera: true,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _buildQuickAttachChip(
                              icon: Icons.image_outlined,
                              label: 'Photo',
                              bg: AppTheme.peach,
                              fg: AppTheme.caramel,
                              onTap: () => pickCanvasAttachment(
                                'Photo',
                                setSheetState,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _buildQuickAttachChip(
                              icon: Icons.videocam_outlined,
                              label: 'Video',
                              bg: AppTheme.lilac,
                              fg: AppTheme.plum,
                              onTap: () => pickCanvasAttachment(
                                'Video',
                                setSheetState,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _buildQuickAttachChip(
                              icon: Icons.picture_as_pdf_outlined,
                              label: 'PDF',
                              bg: AppTheme.mint,
                              fg: AppTheme.olive,
                              onTap: () => pickCanvasAttachment(
                                'PDF',
                                setSheetState,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _buildQuickAttachChip(
                              icon: Icons.calendar_today_rounded,
                              label: selectedDate.isEmpty
                                  ? 'Due date'
                                  : DeadlineBadge.formatShortDate(selectedDate),
                              bg: AppTheme.surface,
                              fg: AppTheme.ink,
                              onTap: () async {
                                final now = DateTime.now();
                                final today =
                                    DateTime(now.year, now.month, now.day);
                                final parsed = DateTime.tryParse(selectedDate);
                                final initial =
                                    (parsed != null && !parsed.isBefore(today))
                                        ? parsed
                                        : today;
                                final picked = await showDatePicker(
                                  context: ctx,
                                  initialDate: initial,
                                  firstDate: today,
                                  lastDate: DateTime(2032),
                                );
                                if (picked != null) {
                                  setSheetState(() {
                                    selectedDate =
                                        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      if (attachedFiles.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: attachedFiles.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final att = entry.value;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.canvas,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.attach_file_rounded,
                                    size: 12,
                                    color: AppTheme.ink,
                                  ),
                                  const SizedBox(width: 4),
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 130),
                                    child: Text(
                                      att['name'] as String? ?? 'File',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.ink,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  GestureDetector(
                                    onTap: () => setSheetState(() {
                                      attachedFiles.removeAt(idx);
                                    }),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 13,
                                      color: AppTheme.muted,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                // 3.5 ASSIGN TEAMMATES (MULTI-SELECT)
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
                          Text(
                            'ASSIGN TEAMMATES (${selectedAssignees.length} DIPILIH)',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.faint,
                              letterSpacing: 0.8,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setSheetState(() {
                              if (selectedAssignees.length == assignees.length) {
                                selectedAssignees
                                  ..clear()
                                  ..add(
                                    Map<String, String>.from(assignees.first),
                                  );
                              } else {
                                selectedAssignees
                                  ..clear()
                                  ..addAll(
                                    assignees.map(
                                      (e) => Map<String, String>.from(e),
                                    ),
                                  );
                              }
                            }),
                            child: Text(
                              selectedAssignees.length == assignees.length
                                  ? 'Reset'
                                  : 'Pilih semua',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.olive,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: assignees.map((a) {
                          final initials = a['initials']!;
                          final name = a['name']!;
                          final tone = a['tone']!;
                          final isSelected = isMemberSelected(initials, name);
                          return GestureDetector(
                            onTap: () => toggleMember(a, setSheetState),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.ink
                                    : AppTheme.surface,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: _avatarBgForTone(tone),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      initials,
                                      style: TextStyle(
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.w700,
                                        color: _avatarTextColorForTone(tone),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
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
                                  if (isSelected) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 12,
                                      color: AppTheme.mint,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. ACTION BUTTONS
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
                              final trimmedTitle = titleCtrl.text.trim();
                              // Jika masih ada teks di input checklist yang belum di-klik + Add, masukkan otomatis
                              final pendingItem =
                                  checklistInputCtrl.text.trim();
                              if (isChecklist && pendingItem.isNotEmpty) {
                                checklistItems.add({
                                  'id':
                                      'chk-${DateTime.now().microsecondsSinceEpoch}',
                                  'text': pendingItem,
                                  'done': false,
                                });
                              }

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
                                    title: trimmedTitle,
                                    content: bodyCtrl.text.trim(),
                                    tag: widget.workspaceName,
                                    dueDate: selectedDate,
                                    checklistTitle:
                                        isChecklist ? trimmedTitle : '',
                                    assignee: selectedAssignees
                                        .map((a) => a['initials'] ?? 'NA')
                                        .join(', '),
                                    assigneeTone:
                                        selectedAssignees.first['tone'] ??
                                            'dark',
                                    assignees: List<Map<String, String>>.from(
                                      selectedAssignees,
                                    ),
                                    boardX: newX,
                                    boardY: newY,
                                    attachments: List<Map<String, dynamic>>.from(
                                      attachedFiles,
                                    ),
                                    checklist: isChecklist
                                        ? List<Map<String, dynamic>>.from(
                                            checklistItems,
                                          )
                                        : const [],
                                  );
                              if (!sheetCtx.mounted) return;
                              Navigator.pop(sheetCtx);
                              if (mounted) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Memo "$trimmedTitle" berhasil ditambahkan ke Canvas!',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppTheme.ink,
                                  ),
                                );
                              }
                            },
                      child: Opacity(
                        opacity: canSave ? 1.0 : 0.35,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
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
          );
        },
      ),
    );
  }

  Widget _buildQuickAttachChip({
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
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

  Uint8List? _decodeAttachmentImage(String? dataUrl) {
    if (dataUrl == null || !dataUrl.startsWith('data:image/')) return null;
    final commaIdx = dataUrl.indexOf(',');
    if (commaIdx == -1 || commaIdx + 1 >= dataUrl.length) return null;
    try {
      return base64Decode(dataUrl.substring(commaIdx + 1));
    } catch (_) {
      return null;
    }
  }

  Widget _buildAttachmentPreviewBox(Map<String, dynamic> att, int totalCount) {
    final name = (att['name'] as String? ?? 'Attachment').trim();
    final rawType = (att['type'] as String? ?? 'Document').toLowerCase();
    final dataUrl = att['dataUrl'] as String?;
    final imageBytes = _decodeAttachmentImage(dataUrl);

    IconData fileIcon = Icons.insert_drive_file_rounded;
    String badgeLabel = 'DOC';
    Color badgeBg = AppTheme.surface;
    Color badgeFg = AppTheme.ink;

    if (rawType.contains('photo') || rawType.contains('image')) {
      fileIcon = Icons.image_rounded;
      badgeLabel = 'PHOTO';
      badgeBg = AppTheme.peach;
      badgeFg = AppTheme.caramel;
    } else if (rawType.contains('video')) {
      fileIcon = Icons.videocam_rounded;
      badgeLabel = 'VIDEO';
      badgeBg = AppTheme.lilac;
      badgeFg = AppTheme.plum;
    } else if (rawType.contains('pdf')) {
      fileIcon = Icons.picture_as_pdf_rounded;
      badgeLabel = 'PDF';
      badgeBg = AppTheme.mint;
      badgeFg = AppTheme.olive;
    }

    if (imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Image.memory(
              imageBytes,
              width: double.infinity,
              height: 108,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
            if (totalCount > 1)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.ink.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '+${totalCount - 1} more',
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(fileIcon, size: 12, color: badgeFg),
                    const SizedBox(width: 4),
                    Text(
                      badgeLabel,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: badgeFg,
                      ),
                    ),
                  ],
                ),
              ),
              if (totalCount > 1)
                Text(
                  '$totalCount files',
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.muted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
            ),
          ),
          if ((att['meta'] as String? ?? '').isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              att['meta'] as String,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: AppTheme.faint,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCanvasAssigneeAvatars(
    List<Map<String, String>> assignees, {
    required bool isUrgent,
  }) {
    final visible = assignees.take(4).toList();
    final extraCount = assignees.length - visible.length;
    final totalWidth =
        24.0 + (visible.length - 1) * 14.0 + (extraCount > 0 ? 16.0 : 0.0);

    return SizedBox(
      width: totalWidth,
      height: 24,
      child: Stack(
        children: [
          for (int i = 0; i < visible.length; i++)
            Positioned(
              left: i * 14.0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _avatarBgForTone(visible[i]['tone'] ?? 'dark'),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isUrgent ? const Color(0xFF7F1D1D) : Colors.white,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  visible[i]['initials'] ?? 'NA',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: _avatarTextColorForTone(
                      visible[i]['tone'] ?? 'dark',
                    ),
                  ),
                ),
              ),
            ),
          if (extraCount > 0)
            Positioned(
              left: visible.length * 14.0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isUrgent ? const Color(0xFFFDE68A) : AppTheme.ink,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isUrgent ? const Color(0xFF7F1D1D) : Colors.white,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$extraCount',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: isUrgent ? const Color(0xFF7F1D1D) : Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStickyCard(_CanvasItem item) {
    final attachments = item.sourceMemo.attachments;
    final checklist = item.sourceMemo.checklist;
    final hasAttachments = attachments.isNotEmpty;
    final visualState = UrgentFlameHelper.getVisualState(item.sourceMemo);
    final hasEffect = visualState != MemoCardVisualState.normal;
    final isDarkFire = visualState == MemoCardVisualState.urgentFire;
    final assignees = item.sourceMemo.effectiveAssignees;

    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasEffect) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: UrgentFlameBadge(
              dueDate: item.sourceMemo.dueDate,
              visualState: visualState,
            ),
          ),
        ],
        if (hasAttachments) ...[
          // Attachment Card preview at the top, followed by memo title below
          _buildAttachmentPreviewBox(attachments.first, attachments.length),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDarkFire ? Colors.white : AppTheme.ink,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.drag_indicator_rounded,
                size: 15,
                color: isDarkFire
                    ? Colors.white.withValues(alpha: 0.65)
                    : AppTheme.ink.withValues(alpha: 0.25),
              ),
            ],
          ),
          if (item.sourceMemo.content.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isDarkFire
                    ? Colors.white.withValues(alpha: 0.85)
                    : AppTheme.muted,
                height: 1.4,
              ),
            ),
          ],
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDarkFire
                      ? Colors.white.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  checklist.isNotEmpty ? Icons.checklist_rounded : item.icon,
                  size: 15,
                  color:
                      isDarkFire ? const Color(0xFFFDE68A) : item.accentColor,
                ),
              ),
              Icon(
                Icons.drag_indicator_rounded,
                size: 16,
                color: isDarkFire
                    ? Colors.white.withValues(alpha: 0.65)
                    : AppTheme.ink.withValues(alpha: 0.22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isDarkFire ? Colors.white : AppTheme.ink,
            ),
          ),
          const SizedBox(height: 6),
          if (checklist.isNotEmpty)
            ...checklist.take(3).map((chk) {
              final done = chk['done'] == true;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      done
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 12,
                      color: isDarkFire
                          ? (done ? const Color(0xFFFDE68A) : Colors.white70)
                          : (done ? AppTheme.olive : AppTheme.muted),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        chk['text']?.toString() ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDarkFire ? Colors.white : AppTheme.ink,
                          decoration: done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })
          else
            Text(
              item.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isDarkFire
                    ? Colors.white.withValues(alpha: 0.85)
                    : AppTheme.muted,
                height: 1.5,
              ),
            ),
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDarkFire
                    ? Colors.white.withValues(alpha: 0.18)
                    : AppTheme.ink.withValues(alpha: 0.06),
              ),
            ),
          ),
          child: Row(
            children: [
              _buildCanvasAssigneeAvatars(assignees, isUrgent: isDarkFire),
              const Spacer(),
              Text(
                'Tap to open',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isDarkFire
                      ? Colors.white.withValues(alpha: 0.85)
                      : AppTheme.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (hasEffect) {
      return UrgentFlameCard(
        visualState: visualState,
        width: 198,
        padding: const EdgeInsets.all(14),
        borderRadius: 22,
        child: cardContent,
      );
    }

    return Container(
      width: 198,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [AppTheme.shadowCard],
      ),
      child: cardContent,
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

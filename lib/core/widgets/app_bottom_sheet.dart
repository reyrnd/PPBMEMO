import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_theme.dart';
import '../utils/date_formatter.dart';
import '../../features/activity/data/activity_repository.dart';
import '../../features/activity/models/activity.dart';
import '../../features/memo/cubit/memo_cubit.dart';
import '../../features/memo/models/memo.dart';
import '../../features/workspace/cubit/workspace_cubit.dart';
import '../../features/workspace/models/workspace.dart';
import '../../features/workspace/screens/workspace_detail_screen.dart';
import '../../features/memo/screens/memo_editor_screen.dart';

final Set<String> _readNotificationIds = <String>{};

/// Frame penampung dasar modal bottom sheet yang konsisten dengan
/// spesifikasi Tailwind/Figma pada index.css dan App.tsx
class SheetFrame extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const SheetFrame({
    super.key,
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.canvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [AppTheme.shadowCard],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header: Title, Description & Close Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.muted,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [AppTheme.shadowSoft],
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: AppTheme.ink, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

/// Generic options action sheet matching `ActionSheet` from App.tsx
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required String title,
  String description = '',
  double? heightFactor,
  required Widget child,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => SheetFrame(
      title: title,
      description: description,
      child: heightFactor != null
          ? SizedBox(
              height: MediaQuery.of(ctx).size.height * heightFactor,
              child: child,
            )
          : child,
    ),
  );
}

class ActionBottomSheet extends StatefulWidget {
  final String title;
  final String description;
  final List<String> options;
  final String? initialSelected;
  final String primaryButtonLabel;
  final ValueChanged<String>? onApplied;

  const ActionBottomSheet({
    super.key,
    required this.title,
    required this.description,
    required this.options,
    this.initialSelected,
    this.primaryButtonLabel = 'Done',
    this.onApplied,
  });

  @override
  State<ActionBottomSheet> createState() => _ActionBottomSheetState();
}

class _ActionBottomSheetState extends State<ActionBottomSheet> {
  late String _selected;
  bool _applied = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected ??
        (widget.options.isNotEmpty ? widget.options.first : '');
  }

  @override
  Widget build(BuildContext context) {
    return SheetFrame(
      title: widget.title,
      description: widget.description,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // White container with radio-style list
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [AppTheme.shadowSoft],
            ),
            child: Column(
              children: List.generate(widget.options.length, (index) {
                final option = widget.options[index];
                final isSelected = option == _selected;
                final isLast = index == widget.options.length - 1;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selected = option;
                      _applied = false;
                    });
                  },
                  borderRadius: BorderRadius.vertical(
                    top: index == 0 ? const Radius.circular(22) : Radius.zero,
                    bottom: isLast ? const Radius.circular(22) : Radius.zero,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 15),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : const Border(
                              bottom: BorderSide(
                                  color: AppTheme.line, width: 0.8)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppTheme.ink : AppTheme.line,
                              width: 1.5,
                            ),
                            color:
                                isSelected ? AppTheme.ink : Colors.transparent,
                          ),
                          alignment: Alignment.center,
                          child: isSelected
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 12)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          if (_applied) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.mint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_rounded,
                      color: AppTheme.olive, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '$_selected applied',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.olive,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (_applied || widget.onApplied == null) {
                  widget.onApplied?.call(_selected);
                  Navigator.pop(context, _selected);
                } else {
                  setState(() => _applied = true);
                  widget.onApplied?.call(_selected);
                  Future.delayed(const Duration(milliseconds: 400), () {
                    if (mounted) Navigator.pop(context, _selected);
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.ink,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                _applied ? 'Done' : widget.primaryButtonLabel,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER BOTTOM SHEET FUNCTIONS
// -----------------------------------------------------------------------------

/// Tampilkan generic action sheet
Future<String?> showActionSheet({
  required BuildContext context,
  required String title,
  required String description,
  required List<String> options,
  String? initialSelected,
  String primaryButtonLabel = 'Done',
  ValueChanged<String>? onApplied,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ActionBottomSheet(
      title: title,
      description: description,
      options: options,
      initialSelected: initialSelected,
      primaryButtonLabel: primaryButtonLabel,
      onApplied: onApplied,
    ),
  );
}

/// 1. WORKSPACE CHOICE SHEET
/// Sesuai `WorkspaceChoiceSheet` di App.tsx (pilihan Create Workspace atau Join Workspace)
void showWorkspaceChoiceSheet({
  required BuildContext context,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => SheetFrame(
      title: 'Workspace',
      description:
          'Create a new team space or join one with an invitation code.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Material(
                  color: AppTheme.ink,
                  borderRadius: BorderRadius.circular(22),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      showCreateWorkspaceSheet(context: context);
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add_rounded,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Create workspace',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Start a new space and invite your team.',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white54,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      showJoinWorkspaceSheet(context: context);
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [AppTheme.shadowSoft],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.mint,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.login_rounded,
                                color: AppTheme.olive, size: 20),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Join workspace',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Enter a unique workspace invite code.',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppTheme.faint,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

/// 2. CREATE WORKSPACE SHEET
/// Form bottom sheet membuat ruang kerja baru
void showCreateWorkspaceSheet({
  required BuildContext context,
}) {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  bool isSubmitting = false;
  String? error;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => SheetFrame(
        title: 'Create workspace',
        description: 'Start a focused space for your team or project.',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name input card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [AppTheme.shadowSoft],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WORKSPACE NAME',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.faint,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: nameController,
                    maxLength: 32,
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Product Launch',
                      hintStyle: TextStyle(color: AppTheme.faint),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                      counterText: '',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Description input card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [AppTheme.shadowSoft],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DESCRIPTION',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.faint,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: descController,
                    maxLength: 72,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.ink,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'What will your team work on?',
                      hintStyle: TextStyle(color: AppTheme.faint),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                      counterText: '',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Owner note banner (mint style)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.mint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.people_alt_rounded,
                        color: AppTheme.olive, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "You'll be the owner",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'An invite code will be generated automatically.',
                          style: TextStyle(fontSize: 10, color: AppTheme.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error!,
                style: const TextStyle(fontSize: 11, color: AppTheme.danger),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) {
                          setModalState(
                              () => error = 'Please enter a workspace name');
                          return;
                        }
                        setModalState(() {
                          isSubmitting = true;
                          error = null;
                        });
                        try {
                          await context.read<WorkspaceCubit>().create(
                                name,
                                descController.text.trim(),
                                'team',
                                false,
                              );
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          setModalState(() {
                            isSubmitting = false;
                            error = e.toString();
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.ink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Create workspace',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// 3. JOIN WORKSPACE SHEET
/// Form bottom sheet gabung ruang kerja dengan kode unik
void showJoinWorkspaceSheet({
  required BuildContext context,
}) {
  final codeController = TextEditingController();
  bool isSubmitting = false;
  String? error;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => SheetFrame(
        title: 'Join workspace',
        description: 'Enter the unique code shared by a workspace owner.',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [AppTheme.shadowSoft],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'INVITATION CODE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.faint,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: codeController,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 14,
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                      color: AppTheme.ink,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'e.g. NORTH-24Q',
                      hintStyle:
                          TextStyle(color: AppTheme.faint, letterSpacing: 1.0),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                      counterText: '',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppTheme.muted, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ask your team lead or workspace owner for their 6–10 character invite code.',
                      style: TextStyle(
                          fontSize: 10, color: AppTheme.muted, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error!,
                style: const TextStyle(fontSize: 11, color: AppTheme.danger),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final code = codeController.text.trim().toUpperCase();
                        if (code.isEmpty) {
                          setModalState(() =>
                              error = 'Please enter a valid invitation code');
                          return;
                        }
                        setModalState(() {
                          isSubmitting = true;
                          error = null;
                        });
                        try {
                          await context.read<WorkspaceCubit>().join(code);
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          setModalState(() {
                            isSubmitting = false;
                            error = e.toString().replaceFirst('Exception: ', '');
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.ink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Join workspace',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// 4. NOTIFICATIONS SHEET (Dinamis & Interaktif)
/// Terhubung ke ActivityRepository, MemoCubit, dan WorkspaceCubit
void showNotificationsSheet({
  required BuildContext context,
}) {
  final memoState = context.read<MemoCubit>().state;
  final memos = memoState is MemoLoaded ? memoState.memos : <Memo>[];
  final workspaces = context.read<WorkspaceCubit>().state;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => StreamBuilder<List<Activity>>(
        stream: ActivityRepository().watchAllMyActivities(),
        builder: (context, snapshot) {
          final streamActivities = snapshot.data ?? <Activity>[];

          // Bangun daftar notifikasi dari aktivitas nyata + memo terbaru
          final notifItems = <Map<String, dynamic>>[];

          for (final act in streamActivities.take(8)) {
            final id = act.id.isNotEmpty
                ? act.id
                : 'act-${act.target}-${act.time.millisecondsSinceEpoch}';
            notifItems.add({
              'id': id,
              'icon': act.type == ActivityType.comment
                  ? Icons.chat_bubble_outline_rounded
                  : act.type == ActivityType.file
                      ? Icons.attach_file_rounded
                      : Icons.description_outlined,
              'title': act.workspaceName.isNotEmpty
                  ? act.workspaceName
                  : 'Workspace update',
              'text': '${act.action} "${act.target}"',
              'time': DateFormatter.getRelativeTimeText(act.time),
              'memoId': act.memoId,
              'workspaceId': act.workspaceId,
              'targetTitle': act.target,
            });
          }

          if (notifItems.isEmpty) {
            for (final memo in memos.take(5)) {
              final wsMatch =
                  workspaces.where((w) => w.id == memo.workspaceId).toList();
              final wsName = wsMatch.isNotEmpty ? wsMatch.first.name : memo.tag;
              final id = 'memo-notif-${memo.id}';
              notifItems.add({
                'id': id,
                'icon': memo.checklist.isNotEmpty
                    ? Icons.check_circle_outline_rounded
                    : memo.attachments.isNotEmpty
                        ? Icons.attach_file_rounded
                        : Icons.description_outlined,
                'title': wsName.isEmpty ? 'Memo update' : wsName,
                'text':
                    '${memo.authorName.isEmpty ? 'You' : memo.authorName} updated "${memo.title}"',
                'time': DateFormatter.getRelativeTimeText(memo.updatedAt),
                'memoId': memo.id,
                'workspaceId': memo.workspaceId,
                'targetTitle': memo.title,
              });
            }
          }

          final unreadCount = notifItems
              .where((item) => !_readNotificationIds.contains(item['id']))
              .length;

          return SheetFrame(
            title: 'Notifications',
            description: unreadCount > 0
                ? '$unreadCount unread updates across your workspaces. Tap an item to open it.'
                : 'All caught up! Tap any update below to jump to its memo or workspace.',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (notifItems.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RECENT UPDATES (${notifItems.length})',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.faint,
                            letterSpacing: 0.8,
                          ),
                        ),
                        if (unreadCount > 0)
                          GestureDetector(
                            onTap: () {
                              setModalState(() {
                                for (final item in notifItems) {
                                  _readNotificationIds
                                      .add(item['id'] as String);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.mint,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text(
                                'Mark all as read',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.olive,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                if (notifItems.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 28, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [AppTheme.shadowSoft],
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.notifications_none_rounded,
                            color: AppTheme.faint, size: 28),
                        SizedBox(height: 8),
                        Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Activity from your memos and workspaces will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: AppTheme.muted),
                        ),
                      ],
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: SingleChildScrollView(
                      child: Column(
                        children: notifItems.map((item) {
                          final id = item['id'] as String;
                          final unread = !_readNotificationIds.contains(id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  _readNotificationIds.add(id);
                                  Navigator.pop(ctx);

                                  final memoId =
                                      (item['memoId'] as String?) ?? '';
                                  final workspaceId =
                                      (item['workspaceId'] as String?) ?? '';
                                  final targetTitle =
                                      (item['targetTitle'] as String?) ?? '';

                                  Memo? targetMemo;
                                  if (memoId.isNotEmpty) {
                                    final matches =
                                        memos.where((m) => m.id == memoId);
                                    if (matches.isNotEmpty) {
                                      targetMemo = matches.first;
                                    }
                                  }
                                  if (targetMemo == null &&
                                      targetTitle.isNotEmpty) {
                                    final matches = memos.where((m) =>
                                        m.title.toLowerCase() ==
                                        targetTitle.toLowerCase());
                                    if (matches.isNotEmpty) {
                                      targetMemo = matches.first;
                                    }
                                  }

                                  if (targetMemo != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MemoEditorScreen(
                                          memoId: targetMemo!.id,
                                          workspaceId: targetMemo.workspaceId,
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  Workspace? targetWs;
                                  if (workspaceId.isNotEmpty) {
                                    final matches = workspaces
                                        .where((w) => w.id == workspaceId);
                                    if (matches.isNotEmpty) {
                                      targetWs = matches.first;
                                    }
                                  }
                                  if (targetWs != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => WorkspaceDetailScreen(
                                          workspace: targetWs!,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: unread
                                          ? AppTheme.peach
                                          : Colors.transparent,
                                      width: 1.2,
                                    ),
                                    boxShadow: const [AppTheme.shadowSoft],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: unread
                                              ? AppTheme.peach
                                              : AppTheme.soft,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Icon(
                                          item['icon'] as IconData,
                                          color: unread
                                              ? AppTheme.caramel
                                              : AppTheme.muted,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['title'] as String,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.ink,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              item['text'] as String,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: AppTheme.muted,
                                                height: 1.35,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            item['time'] as String,
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: AppTheme.faint,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          if (unread)
                                            Container(
                                              width: 7,
                                              height: 7,
                                              decoration: const BoxDecoration(
                                                color: AppTheme.caramel,
                                                shape: BoxShape.circle,
                                              ),
                                            )
                                          else
                                            const Icon(
                                              Icons.chevron_right_rounded,
                                              size: 14,
                                              color: AppTheme.faint,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    ),
  );
}

/// 4B. WEEKLY SUMMARY SHEET ("Share weekly summary")
void showWeeklySummarySheet({
  required BuildContext context,
}) {
  final memoState = context.read<MemoCubit>().state;
  final memos = memoState is MemoLoaded ? memoState.memos : <Memo>[];
  final workspaces = context.read<WorkspaceCubit>().state;

  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));
  final weeklyMemos =
      memos.where((m) => m.updatedAt.isAfter(weekAgo)).toList();

  final todoCount = memos.where((m) => m.status == 'todo').length;
  final doingCount = memos.where((m) => m.status == 'doing').length;
  final doneCount = memos
      .where((m) => m.status == 'done' || (m.progress ?? 0.0) >= 1.0)
      .length;

  int totalChecklistDone = 0;
  int totalChecklistItems = 0;
  for (final m in memos) {
    totalChecklistItems += m.checklist.length;
    totalChecklistDone +=
        m.checklist.where((c) => c['done'] == true).length;
  }

  final summaryLines = <String>[
    '📋 MemoSpace Weekly Summary',
    '• Active Workspaces: ${workspaces.length}',
    '• Memos Updated This Week: ${weeklyMemos.length} (Total: ${memos.length})',
    '• Board Progress: $doneCount Done · $doingCount Working · $todoCount To do',
    if (totalChecklistItems > 0)
      '• Checklist Tasks: $totalChecklistDone/$totalChecklistItems completed',
    if (weeklyMemos.isNotEmpty) ...[
      '',
      'Top Highlights:',
      ...weeklyMemos.take(4).map((m) => '  - ${m.title} (${m.tag})'),
    ],
  ];
  final summaryText = summaryLines.join('\n');

  bool copied = false;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => SheetFrame(
        title: 'Share weekly summary',
        description:
            'Real-time digest of your memos, checklists, and workspace board progress this week.',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.ink,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'WEEKLY DIGEST',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white54,
                          letterSpacing: 1.4,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.mint,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${weeklyMemos.length} updated',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.olive,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildSummaryStatPill(
                        '${memos.length}',
                        'Memos',
                        AppTheme.peach,
                        AppTheme.caramel,
                      ),
                      const SizedBox(width: 8),
                      _buildSummaryStatPill(
                        '$doneCount',
                        'Done',
                        AppTheme.mint,
                        AppTheme.olive,
                      ),
                      const SizedBox(width: 8),
                      _buildSummaryStatPill(
                        '$doingCount',
                        'Working',
                        AppTheme.lilac,
                        AppTheme.plum,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [AppTheme.shadowSoft],
              ),
              child: SelectableText(
                summaryText,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppTheme.ink,
                  height: 1.55,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: summaryText));
                      setModalState(() => copied = true);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Weekly summary copied to clipboard!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      copied ? Icons.check_rounded : Icons.copy_rounded,
                      size: 16,
                    ),
                    label: Text(
                      copied ? 'Copied!' : 'Copy summary',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.ink,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MemoEditorScreen(
                            workspaceId: workspaces.isNotEmpty
                                ? workspaces.first.id
                                : null,
                            initialTitle:
                                'Weekly Summary (${now.day}/${now.month}/${now.year})',
                            initialContent: summaryText,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.note_add_outlined, size: 16),
                    label: const Text(
                      'Save as memo',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.ink,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildSummaryStatPill(
  String value,
  String label,
  Color bg,
  Color textColor,
) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

/// 4C. SPACE DETAILS SHEET ("View space details")
void showSpaceDetailsSheet({
  required BuildContext context,
}) {
  final memoState = context.read<MemoCubit>().state;
  final memos = memoState is MemoLoaded ? memoState.memos : <Memo>[];
  final workspaces = context.read<WorkspaceCubit>().state;

  final totalAttachments =
      memos.fold<int>(0, (sum, m) => sum + m.attachments.length);
  final totalChecklists =
      memos.fold<int>(0, (sum, m) => sum + m.checklist.length);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => SheetFrame(
      title: 'Space overview',
      description: 'Live breakdown of your workspaces, memos, and attachments.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [AppTheme.shadowSoft],
            ),
            child: Column(
              children: [
                _buildSpaceDetailMetricRow(
                  icon: Icons.grid_view_rounded,
                  label: 'Active workspaces',
                  value: '${workspaces.length}',
                ),
                const Divider(color: AppTheme.line, height: 20),
                _buildSpaceDetailMetricRow(
                  icon: Icons.description_outlined,
                  label: 'Total memos',
                  value: '${memos.length}',
                ),
                const Divider(color: AppTheme.line, height: 20),
                _buildSpaceDetailMetricRow(
                  icon: Icons.attach_file_rounded,
                  label: 'Attached files & media',
                  value: '$totalAttachments',
                ),
                const Divider(color: AppTheme.line, height: 20),
                _buildSpaceDetailMetricRow(
                  icon: Icons.check_box_outlined,
                  label: 'Checklist items',
                  value: '$totalChecklists',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                showWeeklySummarySheet(context: context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.ink,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Share weekly summary',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSpaceDetailMetricRow({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Row(
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 16, color: AppTheme.ink),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.ink,
          ),
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppTheme.ink,
        ),
      ),
    ],
  );
}

/// 5. EDIT PROFILE SHEET
/// Bottom sheet menggantikan full-screen EditProfileScreen
void showEditProfileSheet({
  required BuildContext context,
  required VoidCallback onProfileUpdated,
}) {
  final user = FirebaseAuth.instance.currentUser;
  final nameController =
      TextEditingController(text: user?.displayName ?? 'Naya Anindita');
  final bioController = TextEditingController(
      text: 'Product designer & thinker. Organizing ideas in MemoSpace.');
  bool isSaving = false;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => SheetFrame(
        title: 'Edit profile',
        description: 'Update how your name and details appear across spaces.',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar picker row
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.ink,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.line, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      (nameController.text.isNotEmpty
                              ? nameController.text[0]
                              : 'U')
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: AppTheme.caramel,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Name field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [AppTheme.shadowSoft],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DISPLAY NAME',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.faint,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Your name',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Bio field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [AppTheme.shadowSoft],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BIO / TITLE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.faint,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: bioController,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.ink,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Share a quick intro...',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final newName = nameController.text.trim();
                        if (newName.isEmpty) return;
                        setModalState(() => isSaving = true);
                        try {
                          await FirebaseAuth.instance.currentUser
                              ?.updateDisplayName(newName);
                          onProfileUpdated();
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          setModalState(() => isSaving = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.ink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Save changes',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// 6. NOTIFICATION SETTINGS SHEET
void showNotificationSettingsSheet({
  required BuildContext context,
}) {
  bool mentions = true;
  bool invitations = true;
  bool updates = false;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => SheetFrame(
        title: 'Notifications',
        description: 'Choose which updates you receive across workspaces.',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [AppTheme.shadowSoft],
              ),
              child: Column(
                children: [
                  _buildToggleRow(
                    title: 'Mentions and replies',
                    subtitle: 'Notify when teammates mention or reply to you',
                    value: mentions,
                    onChanged: (v) => setModalState(() => mentions = v),
                    isFirst: true,
                  ),
                  _buildToggleRow(
                    title: 'Workspace invitations',
                    subtitle: 'Notify when added or invited to a new space',
                    value: invitations,
                    onChanged: (v) => setModalState(() => invitations = v),
                  ),
                  _buildToggleRow(
                    title: 'Task updates',
                    subtitle: 'Changes in board task statuses or assignments',
                    value: updates,
                    onChanged: (v) => setModalState(() => updates = v),
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.ink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('Save preferences',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildToggleRow({
  required String title,
  required String subtitle,
  required bool value,
  required ValueChanged<bool> onChanged,
  bool isFirst = false,
  bool isLast = false,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      border: isLast
          ? null
          : const Border(bottom: BorderSide(color: AppTheme.line, width: 0.8)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: AppTheme.muted),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.ink,
        ),
      ],
    ),
  );
}

/// 7. ACCOUNT SETTINGS SHEET
void showAccountSettingsSheet({
  required BuildContext context,
  required VoidCallback onLogout,
}) {
  final user = FirebaseAuth.instance.currentUser;
  final email = user?.email ?? 'naya@memospace.app';

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => SheetFrame(
      title: 'Account settings',
      description: 'Profile identity, security & session management.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [AppTheme.shadowSoft],
            ),
            child: Column(
              children: [
                _buildActionRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Personal information',
                  trailing: user?.displayName ?? 'Naya Anindita',
                  onTap: () {
                    Navigator.pop(ctx);
                    showEditProfileSheet(
                        context: context, onProfileUpdated: () {});
                  },
                ),
                _buildActionRow(
                  icon: Icons.email_outlined,
                  label: 'Email address',
                  trailing: email,
                  onTap: () {},
                ),
                _buildActionRow(
                  icon: Icons.lock_outline_rounded,
                  label: 'Reset password link',
                  trailing: 'Send email',
                  onTap: () async {
                    try {
                      if (user?.email != null) {
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(email: user!.email!);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Reset link sent to $email')),
                          );
                        }
                      }
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                ),
                _buildActionRow(
                  icon: Icons.logout_rounded,
                  label: 'Sign out',
                  iconColor: AppTheme.danger,
                  textColor: AppTheme.danger,
                  isLast: true,
                  onTap: () {
                    Navigator.pop(ctx);
                    onLogout();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

Widget _buildActionRow({
  required IconData icon,
  required String label,
  String? trailing,
  Color? iconColor,
  Color? textColor,
  bool isLast = false,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppTheme.line, width: 0.8)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor ?? AppTheme.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor ?? AppTheme.ink,
              ),
            ),
          ),
          if (trailing != null) ...[
            Text(
              trailing,
              style: const TextStyle(fontSize: 11, color: AppTheme.faint),
            ),
            const SizedBox(width: 6),
          ],
          const Icon(Icons.chevron_right_rounded,
              color: AppTheme.faint, size: 18),
        ],
      ),
    ),
  );
}

/// 8. INVITE WORKSPACE SHEET
void showInviteWorkspaceSheet({
  required BuildContext context,
  required Workspace workspace,
}) {
  bool copied = false;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => SheetFrame(
        title: 'Invite teammates',
        description: 'Share this unique code to join ${workspace.name}.',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dark code card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.ink,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [AppTheme.shadowCard],
              ),
              child: Column(
                children: [
                  const Text(
                    'WORKSPACE CODE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white54,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    workspace.inviteCode,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 4.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Codes are unique to each workspace.',
                    style: TextStyle(fontSize: 9, color: Colors.white54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: workspace.inviteCode));
                      setModalState(() => copied = true);
                      Future.delayed(const Duration(seconds: 2), () {
                        if (ctx.mounted) setModalState(() => copied = false);
                      });
                    },
                    icon: Icon(
                      copied ? Icons.check_rounded : Icons.copy_rounded,
                      size: 16,
                    ),
                    label: Text(copied ? 'Copied!' : 'Copy code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.ink,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Trigger regenerate code
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code is active and ready to share.')),
                      );
                    },
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: const Text('Share code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.mint,
                      foregroundColor: AppTheme.olive,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [AppTheme.shadowSoft],
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: AppTheme.muted, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invite as member',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'New people can view, create, and edit memos.',
                          style: TextStyle(fontSize: 10, color: AppTheme.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.ink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('Done',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// 9. UPGRADE PROMO SHEET
void showUpgradeSheet({
  required BuildContext context,
}) {
  showActionSheet(
    context: context,
    title: 'Choose a plan',
    description:
        'MemoSpace Plus is billed monthly and can be cancelled anytime.',
    options: [
      'Individual · \$6/month',
      'Team · \$12/member',
    ],
    primaryButtonLabel: 'Continue',
  );
}

/// 10. LANGUAGE SHEET
void showLanguageSheet({
  required BuildContext context,
  required String currentLanguage,
  required ValueChanged<String> onSelected,
}) {
  showActionSheet(
    context: context,
    title: 'Language',
    description: 'Select your preferred app language.',
    options: [
      'English',
      'Bahasa Indonesia',
      'Español',
    ],
    initialSelected: currentLanguage,
    primaryButtonLabel: 'Apply language',
    onApplied: onSelected,
  );
}

/// Backward compatibility class for AppBottomSheet
class AppBottomSheet extends StatelessWidget {
  final String title;
  final String description;
  final List<String> options;
  final String selectedOption;
  final String primaryButtonLabel;
  final ValueChanged<String> onOptionSelected;
  final VoidCallback onPrimaryPressed;

  const AppBottomSheet({
    super.key,
    required this.title,
    required this.description,
    required this.options,
    required this.selectedOption,
    required this.primaryButtonLabel,
    required this.onOptionSelected,
    required this.onPrimaryPressed,
  });

  static void show({
    required BuildContext context,
    required String title,
    required String description,
    required List<String> options,
    required String selectedOption,
    required String primaryButtonLabel,
    required ValueChanged<String> onOptionSelected,
    required VoidCallback onPrimaryPressed,
  }) {
    showActionSheet(
      context: context,
      title: title,
      description: description,
      options: options,
      initialSelected: selectedOption,
      primaryButtonLabel: primaryButtonLabel,
      onApplied: (opt) {
        onOptionSelected(opt);
        onPrimaryPressed();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ActionBottomSheet(
      title: title,
      description: description,
      options: options,
      initialSelected: selectedOption,
      primaryButtonLabel: primaryButtonLabel,
      onApplied: (opt) {
        onOptionSelected(opt);
        onPrimaryPressed();
      },
    );
  }
}

